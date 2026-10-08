package httpapi

import (
	"context"
	"io"
	"strconv"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/files"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

type versionListing struct {
	Path      string                    `json:"path"`
	Current   files.Entry               `json:"current"`
	Versions  []versionView             `json:"versions" doc:"Earlier versions, newest first"`
	Retention settings.VersionRetention `json:"retention"`
}

type versionView struct {
	files.Version
	HasPreview bool `json:"hasPreview" doc:"Whether GET /files/versions/{versionID}/preview has a thumbnail"`
}

type versionPath struct {
	VersionID int64 `path:"versionID"`
}

type versionPreviewInput struct {
	VersionID int64       `path:"versionID"`
	Size      previewSize `query:"size" default:"256" doc:"Thumbnail width and height in pixels"`
}

type versionRestoreRequest struct {
	BaseRev int64 `json:"baseRev" required:"false" doc:"Revision the client last saw of the current file; 0 skips the check"`
}

type versionRestoreInput struct {
	VersionID int64 `path:"versionID"`
	Body      versionRestoreRequest
}

type versionDownloadOutput struct {
	ContentType        string `header:"Content-Type"`
	ContentLength      string `header:"Content-Length"`
	ContentDisposition string `header:"Content-Disposition"`
	Body               func(huma.Context)
}

func (a *API) listVersions(ctx context.Context, input *pathQuery) (*jsonBody[versionListing], error) {
	owner := currentUser(ctx)
	current, versions, err := a.files.ListVersions(ctx, owner, input.Path)
	if err != nil {
		return nil, err
	}
	retention, err := a.versionRetention(ctx, owner)
	if err != nil {
		return nil, err
	}
	listing := versionListing{Path: current.Path, Current: current, Versions: make([]versionView, 0, len(versions)), Retention: retention}
	for _, version := range versions {
		listing.Versions = append(listing.Versions, versionView{Version: version, HasPreview: a.previews.HasThumbnail(version.Hash, defaultPreviewSize)})
	}
	return respond(listing), nil
}

const defaultPreviewSize = 256

func (a *API) downloadVersion(ctx context.Context, input *versionPath) (*versionDownloadOutput, error) {
	content, version, entry, err := a.files.OpenVersion(ctx, currentUser(ctx), input.VersionID)
	if err != nil {
		return nil, err
	}
	return &versionDownloadOutput{
		ContentType:        entry.Mime,
		ContentLength:      strconv.FormatInt(version.Size, 10),
		ContentDisposition: attachment(entry.Name),
		Body: func(humaCtx huma.Context) {
			defer content.Close()
			if _, err := io.Copy(humaCtx.BodyWriter(), content); err != nil {
				logger.Warn("send version", "version", version.ID, "error", err)
			}
		},
	}, nil
}

func (a *API) previewVersion(ctx context.Context, input *versionPreviewInput) (*previewOutput, error) {
	version, _, err := a.files.FindVersion(ctx, currentUser(ctx), input.VersionID)
	if err != nil {
		return nil, err
	}
	return a.thumbnail(version.Hash, files.PreviewReady, int(input.Size))
}

func (a *API) restoreVersion(ctx context.Context, input *versionRestoreInput) (*jsonBody[files.Entry], error) {
	entry, err := a.files.RestoreVersion(ctx, currentUser(ctx), input.VersionID, input.Body.BaseRev)
	if err != nil {
		return nil, err
	}
	return respond(entry), nil
}

func (a *API) deleteVersion(ctx context.Context, input *versionPath) (*struct{}, error) {
	return nil, a.files.DeleteVersion(ctx, currentUser(ctx), input.VersionID)
}

func (a *API) getVersionSettings(ctx context.Context, _ *struct{}) (*jsonBody[settings.VersionRetention], error) {
	retention, err := a.versionRetention(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(retention), nil
}

func (a *API) setVersionSettings(ctx context.Context, input *jsonBody[users.VersionPreferences]) (*jsonBody[settings.VersionRetention], error) {
	owner := currentUser(ctx)
	preferences := input.Body
	server, err := a.settings.Get(ctx)
	if err != nil {
		return nil, err
	}
	if err := settings.ValidateVersionPreferences(server, preferences); err != nil {
		return nil, err
	}
	if err := a.users.Store().SetVersionPreferences(ctx, owner.ID, preferences); err != nil {
		return nil, err
	}
	owner.Versions = preferences
	retention := settings.ResolveVersionRetention(server, owner)
	if err := a.versions.ApplyRetention(ctx, owner); err != nil {
		return nil, err
	}
	return respond(retention), nil
}

func (a *API) versionRetention(ctx context.Context, owner users.User) (settings.VersionRetention, error) {
	server, err := a.settings.Get(ctx)
	if err != nil {
		return settings.VersionRetention{}, err
	}
	return settings.ResolveVersionRetention(server, owner), nil
}
