package httpapi

import (
	"context"
	"net/http"
	"os"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"polder-server/internal/files"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

type trashListing struct {
	Items      []files.TrashItem       `json:"items"`
	TotalBytes int64                   `json:"totalBytes"`
	Retention  settings.TrashRetention `json:"retention"`
}

type trashItemPath struct {
	ItemID int64 `path:"itemID"`
}

type trashPreviewInput struct {
	ItemID int64       `path:"itemID"`
	Size   previewSize `query:"size" default:"256" doc:"Thumbnail width and height in pixels"`
}

type restoreRequest struct {
	OnConflict files.RestoreMode `json:"onConflict" required:"false" default:"fail" doc:"What to do when something already exists at the original path: fail with already_exists, overwrite it (it moves to the trash), or keep both by restoring under a new name"`
}

type restoreInput struct {
	ItemID int64 `path:"itemID"`
	Body   restoreRequest
}

func (a *API) listTrash(ctx context.Context, _ *struct{}) (*jsonBody[trashListing], error) {
	owner := currentUser(ctx)
	retention, err := a.trashRetention(ctx, owner)
	if err != nil {
		return nil, err
	}
	items, err := a.files.ListTrash(ctx, owner)
	if err != nil {
		return nil, err
	}
	listing := trashListing{Items: items, Retention: retention}
	for i := range listing.Items {
		item := &listing.Items[i]
		listing.TotalBytes += item.Size
		if expiresAt, expires := retention.ExpiresAt(item.DeletedAt); expires {
			item.ExpiresAt = &expiresAt
		}
	}
	return respond(listing), nil
}

func (a *API) restoreTrashItem(ctx context.Context, input *restoreInput) (*jsonBody[files.Entry], error) {
	entry, err := a.files.RestoreFromTrash(ctx, currentUser(ctx), input.ItemID, input.Body.OnConflict)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) downloadTrashItem(ctx context.Context, input *trashItemPath) (*attachmentOutput, error) {
	item, absolute, err := a.files.OpenTrashItem(ctx, currentUser(ctx), input.ItemID)
	if err != nil {
		return nil, err
	}
	if item.IsDir {
		return &attachmentOutput{
			ContentType:        "application/zip",
			ContentDisposition: attachment(item.Name + ".zip"),
			Body: func(ctx huma.Context) {
				if err := writeZip(ctx.BodyWriter(), absolute); err != nil {
					logger.Warn("zip trashed directory", "name", item.Name, "error", err)
				}
			},
		}, nil
	}
	file, err := os.Open(absolute)
	if err != nil {
		return nil, err
	}
	return &attachmentOutput{
		ContentType:        item.Mime,
		ContentDisposition: attachment(item.Name),
		Body: func(ctx huma.Context) {
			defer file.Close()
			r, w := humachi.Unwrap(ctx)
			http.ServeContent(w, r, item.Name, item.DeletedAt, file)
		},
	}, nil
}

func (a *API) previewTrashItem(ctx context.Context, input *trashPreviewInput) (*previewOutput, error) {
	item, err := a.files.TrashItem(ctx, currentUser(ctx), input.ItemID)
	if err != nil {
		return nil, err
	}
	return a.thumbnail(item.Hash, item.PreviewState, int(input.Size))
}

func (a *API) deleteTrashItem(ctx context.Context, input *trashItemPath) (*struct{}, error) {
	return nil, a.files.DeleteFromTrash(ctx, currentUser(ctx), input.ItemID)
}

func (a *API) emptyTrash(ctx context.Context, _ *struct{}) (*struct{}, error) {
	return nil, a.files.EmptyTrash(ctx, currentUser(ctx))
}

func (a *API) getTrashRetention(ctx context.Context, _ *struct{}) (*jsonBody[settings.TrashRetention], error) {
	retention, err := a.trashRetention(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(retention), nil
}

func (a *API) setTrashRetention(ctx context.Context, input *jsonBody[users.TrashPreferences]) (*jsonBody[settings.TrashRetention], error) {
	owner := currentUser(ctx)
	preferences := input.Body
	server, err := a.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	if err := settings.ValidateTrashPreferences(server, preferences); err != nil {
		return nil, err
	}
	if err := a.users.Store().SetTrashPreferences(ctx, owner.ID, preferences); err != nil {
		return nil, err
	}
	owner.Trash = preferences
	retention := settings.ResolveTrashRetention(server, owner)
	if !retention.Enabled {
		if err := a.files.EmptyTrash(ctx, owner); err != nil {
			return nil, err
		}
	}
	return respond(retention), nil
}

func (a *API) trashRetention(ctx context.Context, owner users.User) (settings.TrashRetention, error) {
	server, err := a.settings.Get(ctx)
	if err != nil {
		return settings.TrashRetention{}, err
	}
	return settings.ResolveTrashRetention(server, owner), nil
}
