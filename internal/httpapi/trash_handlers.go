package httpapi

import (
	"archive/zip"
	"context"
	"errors"
	"io"
	"io/fs"
	"log/slog"
	"mime"
	"net/http"
	"os"
	"path/filepath"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"polder-server/internal/files"
	"polder-server/internal/settings"
	"polder-server/internal/storage"
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

type trashDownloadOutput struct {
	ContentType        string `header:"Content-Type"`
	ContentDisposition string `header:"Content-Disposition"`
	Body               func(huma.Context)
}

type retentionRequest struct {
	Days *int `json:"days" required:"false" doc:"Days to keep trashed items, 0 keeps them forever; null or absent follows the server default"`
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

func (a *API) downloadTrashItem(ctx context.Context, input *trashItemPath) (*trashDownloadOutput, error) {
	item, absolute, err := a.files.OpenTrashItem(ctx, currentUser(ctx), input.ItemID)
	if err != nil {
		return nil, err
	}
	if item.IsDir {
		return &trashDownloadOutput{
			ContentType:        "application/zip",
			ContentDisposition: attachment(item.Name + ".zip"),
			Body: func(ctx huma.Context) {
				if err := writeZip(ctx.BodyWriter(), absolute); err != nil {
					slog.Warn("zip trashed directory", "name", item.Name, "error", err)
				}
			},
		}, nil
	}
	file, err := os.Open(absolute)
	if err != nil {
		return nil, err
	}
	return &trashDownloadOutput{
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

func attachment(name string) string {
	return mime.FormatMediaType("attachment", map[string]string{"filename": name})
}

func writeZip(w io.Writer, root string) error {
	archive := zip.NewWriter(w)
	err := filepath.WalkDir(root, func(current string, entry fs.DirEntry, err error) error {
		if err != nil || current == root {
			return err
		}
		if storage.IsReservedName(entry.Name()) || storage.IsSystemFile(entry.Name()) {
			return nil
		}
		relative, _ := filepath.Rel(root, current)
		name := filepath.ToSlash(relative)
		if entry.IsDir() {
			_, err := archive.Create(name + "/")
			return err
		}
		if !entry.Type().IsRegular() {
			return nil
		}
		return addZipFile(archive, current, name, entry)
	})
	return errors.Join(err, archive.Close())
}

func addZipFile(archive *zip.Writer, absolute, name string, entry fs.DirEntry) error {
	info, err := entry.Info()
	if err != nil {
		return err
	}
	header, err := zip.FileInfoHeader(info)
	if err != nil {
		return err
	}
	header.Name, header.Method = name, zip.Deflate
	target, err := archive.CreateHeader(header)
	if err != nil {
		return err
	}
	file, err := os.Open(absolute)
	if err != nil {
		return err
	}
	defer file.Close()
	_, err = io.Copy(target, file)
	return err
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

func (a *API) setTrashRetention(ctx context.Context, input *jsonBody[retentionRequest]) (*jsonBody[settings.TrashRetention], error) {
	owner := currentUser(ctx)
	if days := input.Body.Days; days != nil {
		if err := users.ValidateRetentionDays(*days); err != nil {
			return nil, err
		}
	}
	if err := a.users.Store().SetTrashRetention(ctx, owner.ID, input.Body.Days); err != nil {
		return nil, err
	}
	owner.TrashRetentionDays = input.Body.Days
	retention, err := a.trashRetention(ctx, owner)
	if err != nil {
		return nil, err
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
