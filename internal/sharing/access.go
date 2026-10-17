package sharing

import (
	"errors"
	"path"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type Access struct {
	Owner       users.User
	Root        files.Entry
	CanRead     bool
	CanDownload bool
	CanCreate   bool
	CanEdit     bool
	CanDelete   bool
	CanDrop     bool
	ExpiresAt   *time.Time
	Via         string
}

func (a Access) Permissions() SharePermissions {
	return SharePermissions{Create: a.CanCreate, Edit: a.CanEdit, Delete: a.CanDelete}
}

func (a Access) Path(relative string) (string, error) {
	clean, err := storage.CleanPath(relative)
	if err != nil {
		return "", err
	}
	if !a.Root.IsDir && clean != storage.RootPath {
		return "", apperr.NotFound("%s does not exist", clean)
	}
	joined := path.Join(a.Root.Path, clean)
	if !storage.IsSameOrDescendant(joined, a.Root.Path) {
		return "", apperr.NotFound("%s does not exist", clean)
	}
	return joined, nil
}

func (a Access) Scrub(errp *error) {
	var appErr *apperr.Error
	if !errors.As(*errp, &appErr) {
		return
	}
	scrubbed := *appErr
	scrubbed.Message = a.relativeText(appErr.Message)
	if entry, ok := appErr.Current.(files.Entry); ok {
		scrubbed.Current = a.Relative(entry)
	} else {
		scrubbed.Current = nil
	}
	*errp = &scrubbed
}

func (a Access) relativeText(text string) string {
	if a.Root.Path == storage.RootPath {
		return text
	}
	text = strings.ReplaceAll(text, a.Root.Path+"/", "/")
	text = strings.ReplaceAll(text, a.Root.Path+" ", "/ ")
	if strings.HasSuffix(text, a.Root.Path) {
		text = strings.TrimSuffix(text, a.Root.Path) + "/"
	}
	return text
}

func (a Access) Inner(relative string) (string, error) {
	joined, err := a.Path(relative)
	if err != nil {
		return "", err
	}
	if joined == a.Root.Path {
		return "", apperr.Invalid("the shared item itself cannot be changed")
	}
	return joined, nil
}

func (a Access) Relative(entry files.Entry) files.Entry {
	entry.Path = a.RelativePath(entry.Path)
	return entry
}

func (a Access) RelativePath(ownerPath string) string {
	if ownerPath == a.Root.Path {
		return storage.RootPath
	}
	return "/" + strings.TrimPrefix(ownerPath, a.Root.Path+"/")
}

func (a Access) RelativeEntries(entries []files.Entry) []files.Entry {
	relative := make([]files.Entry, len(entries))
	for i, entry := range entries {
		relative[i] = a.Relative(entry)
	}
	return relative
}

func (a Access) RequireRead() error {
	if !a.CanRead {
		return apperr.Forbidden("this link only accepts uploads")
	}
	return nil
}

func (a Access) RequireDownload() error {
	if !a.CanDownload {
		return apperr.Forbidden("this link does not allow downloads")
	}
	return nil
}

func (a Access) RequireCreate() error {
	if !a.CanCreate {
		return apperr.Forbidden("this share does not allow adding files")
	}
	return nil
}

func (a Access) RequireEdit() error {
	if !a.CanEdit {
		return apperr.Forbidden("this share does not allow changing files")
	}
	return nil
}

func (a Access) RequireDelete() error {
	if !a.CanDelete {
		return apperr.Forbidden("this share does not allow deleting files")
	}
	return nil
}

func (a Access) RequireMove(from, to string, copying bool) error {
	switch {
	case copying:
		return a.RequireCreate()
	case storage.ParentPath(from) == storage.ParentPath(to):
		return a.RequireEdit()
	}
	return errors.Join(a.RequireCreate(), a.RequireDelete())
}

func (a Access) RequireDrop() error {
	if !a.CanDrop {
		return apperr.Forbidden("this share does not accept uploads")
	}
	return nil
}
