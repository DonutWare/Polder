package httpapi

import (
	"context"
	"errors"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/tags"
	"polder-server/internal/users"
)

type tagRequest struct {
	Name  string `json:"name" minLength:"1" maxLength:"64"`
	Color string `json:"color,omitempty" required:"false" doc:"Hex color such as #3e63dd; empty picks the next palette color"`
}

type tagPath struct {
	TagID int64 `path:"tagID"`
}

type updateTagInput struct {
	TagID int64 `path:"tagID"`
	Body  tags.TagChange
}

type tagAssignment struct {
	Paths []string `json:"paths" minItems:"1" maxItems:"500" doc:"Items to change, as paths in the user's files"`
	Names []string `json:"names" minItems:"1" maxItems:"20"`
}

type tagAssignmentResult struct {
	Path  string `json:"path"`
	Error string `json:"error,omitempty" required:"false" doc:"Why this item was left unchanged"`
}

type tagAssignmentResponse struct {
	Results []tagAssignmentResult `json:"results"`
}

type unusedTagsResponse struct {
	Removed int64 `json:"removed" doc:"How many tags were deleted"`
}

func (a *API) listTags(ctx context.Context, _ *struct{}) (*jsonBody[[]tags.UserTag], error) {
	list, err := a.tags.List(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createTag(ctx context.Context, input *jsonBody[tagRequest]) (*jsonBody[tags.UserTag], error) {
	tag, err := a.tags.Create(ctx, currentUser(ctx), input.Body.Name, input.Body.Color)
	if err != nil {
		return nil, err
	}
	return respond(tag), nil
}

func (a *API) updateTag(ctx context.Context, input *updateTagInput) (*jsonBody[tags.UserTag], error) {
	tag, err := a.tags.Update(ctx, currentUser(ctx), input.TagID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(tag), nil
}

func (a *API) deleteTag(ctx context.Context, input *tagPath) (*struct{}, error) {
	return nil, a.tags.Delete(ctx, currentUser(ctx), input.TagID)
}

func (a *API) deleteUnusedTags(ctx context.Context, _ *struct{}) (*jsonBody[unusedTagsResponse], error) {
	removed, err := a.tags.DeleteUnused(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(unusedTagsResponse{Removed: removed}), nil
}

func (a *API) assignTags(ctx context.Context, input *jsonBody[tagAssignment]) (*jsonBody[tagAssignmentResponse], error) {
	return a.changeTags(ctx, input.Body, a.tags.Assign)
}

func (a *API) unassignTags(ctx context.Context, input *jsonBody[tagAssignment]) (*jsonBody[tagAssignmentResponse], error) {
	return a.changeTags(ctx, input.Body, a.tags.Unassign)
}

type tagChange func(ctx context.Context, viewer users.User, targets []tags.Target, names []string) []error

func (a *API) changeTags(ctx context.Context, request tagAssignment, change tagChange) (*jsonBody[tagAssignmentResponse], error) {
	viewer := currentUser(ctx)
	results := make([]tagAssignmentResult, len(request.Paths))
	var targets []tags.Target
	var resolved []int
	for i, raw := range request.Paths {
		results[i].Path = raw
		target, err := a.tagTarget(ctx, viewer, raw)
		if err != nil {
			results[i].Error = tagErrorMessage(err)
			continue
		}
		targets = append(targets, target)
		resolved = append(resolved, i)
	}
	for i, err := range change(ctx, viewer, targets, request.Names) {
		if err != nil {
			results[resolved[i]].Error = tagErrorMessage(err)
		}
	}
	return respond(tagAssignmentResponse{Results: results}), nil
}

func (a *API) tagTarget(ctx context.Context, viewer users.User, raw string) (_ tags.Target, err error) {
	at, err := a.mountAt(ctx, viewer, raw)
	if err != nil {
		return tags.Target{}, err
	}
	if at == nil {
		clean, err := storage.CleanPath(raw)
		return tags.Target{Owner: viewer, Path: clean, CanEdit: true}, err
	}
	if at.federated() {
		return tags.Target{}, apperr.Invalid("items in a share from another server cannot be tagged")
	}
	_, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return tags.Target{}, err
	}
	defer access.Scrub(&err)
	if err := access.RequireRead(); err != nil {
		return tags.Target{}, err
	}
	absolute, err := access.Path(at.relative)
	return tags.Target{Owner: access.Owner, Path: absolute, CanEdit: access.CanEdit}, err
}

func tagErrorMessage(err error) string {
	var appErr *apperr.Error
	if errors.As(err, &appErr) {
		return appErr.Message
	}
	logger.Warn("change tags", "error", err)
	return "the tags could not be changed"
}

func (a *API) attachTags(ctx context.Context, entries []files.Entry) error {
	ids := make([]int64, 0, len(entries))
	for _, entry := range entries {
		if entry.ID != 0 {
			ids = append(ids, entry.ID)
		}
	}
	if len(ids) == 0 {
		return nil
	}
	found, err := a.tags.Store().ForFiles(ctx, currentUser(ctx).ID, ids)
	if err != nil {
		return err
	}
	for i := range entries {
		entries[i].TagIDs = found.TagIDs[entries[i].ID]
		entries[i].OtherTags = found.OtherTags[entries[i].ID]
	}
	return nil
}
