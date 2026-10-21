package webdav

import (
	"mime"
	"net/http"
	"net/url"
	"strings"

	"polder-server/internal/files"
)

func (h *Handler) get(req *request) error {
	if err := req.space.Access.RequireDownload(); err != nil {
		return err
	}
	file, entry, err := h.files.Open(req.r.Context(), req.space.Access.Owner, req.absolute)
	if err != nil {
		if current, exists, statErr := h.stat(req, req.absolute); statErr == nil && exists && current.IsDir {
			req.w.Header().Set("Allow", allowedMethods)
			return withStatus(http.StatusMethodNotAllowed, "collections cannot be downloaded")
		}
		return err
	}
	defer file.Close()
	header := req.w.Header()
	header.Set("ETag", fileETag(entry))
	header.Set("Content-Type", contentType(entry))
	header.Set("Content-Disposition", mime.FormatMediaType("attachment", map[string]string{"filename": entry.Name}))
	header.Set("X-Content-Type-Options", "nosniff")
	header.Set("Content-Security-Policy", contentPolicy)
	http.ServeContent(req.w, req.r, entry.Name, entry.Mtime, file)
	return nil
}

func (h *Handler) put(req *request) error {
	if req.r.Header.Get("Content-Range") != "" {
		return withStatus(http.StatusBadRequest, "partial uploads are not supported")
	}
	current, exists, err := h.stat(req, req.absolute)
	if err != nil {
		return err
	}
	if exists && current.IsDir {
		req.w.Header().Set("Allow", allowedMethods)
		return withStatus(http.StatusMethodNotAllowed, "cannot replace a collection with a file")
	}
	if err := h.requireWritable(req, exists); err != nil {
		return err
	}
	if err := h.requireParent(req, req.absolute); err != nil {
		return err
	}
	if err := h.checkLocks(req, req.absolute, false, !exists); err != nil {
		return err
	}
	baseRev, err := baseRevision(req, current, exists)
	if err != nil {
		return err
	}
	if !exists && !req.space.Access.CanEdit {
		baseRev = files.BaseRevMustNotExist
	}
	entry, err := h.files.Write(req.r.Context(), req.space.Access.Owner, files.WriteRequest{
		Path:    req.absolute,
		BaseRev: baseRev,
		Content: req.r.Body,
	})
	if err != nil {
		return err
	}
	header := req.w.Header()
	header.Set("ETag", fileETag(entry))
	header.Set("Content-Length", "0")
	if exists {
		req.w.WriteHeader(http.StatusNoContent)
	} else {
		req.w.WriteHeader(http.StatusCreated)
	}
	return nil
}

func (h *Handler) requireWritable(req *request, exists bool) error {
	if exists {
		return req.space.Access.RequireEdit()
	}
	return req.space.Access.RequireCreate()
}

func (h *Handler) mkcol(req *request) error {
	if req.r.ContentLength > 0 || len(req.r.TransferEncoding) > 0 {
		return withStatus(http.StatusUnsupportedMediaType, "MKCOL does not take a body")
	}
	if _, exists, err := h.stat(req, req.absolute); err != nil || exists {
		if err != nil {
			return err
		}
		req.w.Header().Set("Allow", allowedMethods)
		return withStatus(http.StatusMethodNotAllowed, "the resource already exists")
	}
	if err := req.space.Access.RequireCreate(); err != nil {
		return err
	}
	if _, err := req.space.Access.Inner(req.relative); err != nil {
		return err
	}
	if err := h.requireParent(req, req.absolute); err != nil {
		return err
	}
	if err := h.checkLocks(req, req.absolute, false, true); err != nil {
		return err
	}
	if _, err := h.files.Mkdir(req.r.Context(), req.space.Access.Owner, req.absolute); err != nil {
		return err
	}
	req.w.Header().Set("Content-Length", "0")
	req.w.WriteHeader(http.StatusCreated)
	return nil
}

func (h *Handler) delete(req *request) error {
	if req.absolute == req.space.Access.Root.Path {
		return withStatus(http.StatusForbidden, "the root of this space cannot be deleted")
	}
	if err := req.space.Access.RequireDelete(); err != nil {
		return err
	}
	current, exists, err := h.stat(req, req.absolute)
	if err != nil {
		return err
	}
	if !exists {
		return withStatus(http.StatusNotFound, "no such resource")
	}
	if err := h.checkLocks(req, req.absolute, current.IsDir, true); err != nil {
		return err
	}
	baseRev, err := baseRevision(req, current, true)
	if err != nil {
		return err
	}
	if current.IsDir {
		baseRev = files.BaseRevAny
	}
	if err := h.files.Delete(req.r.Context(), req.space.Access.Owner, req.absolute, baseRev); err != nil {
		return err
	}
	h.locks.Release(req.space.key(req.absolute))
	req.w.WriteHeader(http.StatusNoContent)
	return nil
}

func (h *Handler) destination(req *request) (string, string, error) {
	raw := req.r.Header.Get("Destination")
	if raw == "" {
		return "", "", withStatus(http.StatusBadRequest, "missing Destination header")
	}
	parsed, err := url.Parse(raw)
	if err != nil {
		return "", "", withStatus(http.StatusBadRequest, "invalid Destination header")
	}
	if parsed.Host != "" && !strings.EqualFold(parsed.Host, req.r.Host) {
		return "", "", withStatus(http.StatusBadGateway, "the destination is on another server")
	}
	relative, found := req.space.relativePath(parsed.Path)
	if !found {
		return "", "", withStatus(http.StatusBadGateway, "the destination is outside this space")
	}
	absolute, err := req.space.Access.Inner(relative)
	return relative, absolute, err
}

func (h *Handler) moveOrCopy(req *request, copying bool) error {
	access := req.space.Access
	if _, err := access.Inner(req.relative); err != nil {
		return withStatus(http.StatusForbidden, "the root of this space cannot be moved or copied")
	}
	_, to, err := h.destination(req)
	if err != nil {
		return err
	}
	if to == req.absolute {
		return withStatus(http.StatusForbidden, "source and destination are the same")
	}
	if err := access.RequireMove(req.absolute, to, copying); err != nil {
		return err
	}
	source, exists, err := h.stat(req, req.absolute)
	if err != nil {
		return err
	}
	if !exists {
		return withStatus(http.StatusNotFound, "no such resource")
	}
	target, targetExists, err := h.stat(req, to)
	if err != nil {
		return err
	}
	if targetExists && strings.EqualFold(strings.TrimSpace(req.r.Header.Get("Overwrite")), "F") {
		return withStatus(http.StatusPreconditionFailed, "the destination exists and Overwrite is F")
	}
	if err := h.requireParent(req, to); err != nil {
		return err
	}
	if !copying {
		if err := h.checkLocks(req, req.absolute, source.IsDir, true); err != nil {
			return err
		}
	}
	if err := h.checkLocks(req, to, targetExists && target.IsDir, true); err != nil {
		return err
	}
	if targetExists {
		err = h.replace(req, source, target, copying)
	} else {
		err = h.transfer(req, source, to, copying)
	}
	if err != nil {
		return err
	}
	if !copying {
		h.locks.Release(req.space.key(req.absolute))
	}
	if targetExists {
		req.w.WriteHeader(http.StatusNoContent)
	} else {
		req.w.WriteHeader(http.StatusCreated)
	}
	return nil
}

func (h *Handler) transfer(req *request, source files.Entry, to string, copying bool) error {
	ctx := req.r.Context()
	owner := req.space.Access.Owner
	switch {
	case copying && source.IsDir && req.r.Header.Get("Depth") == "0":
		_, err := h.files.Mkdir(ctx, owner, to)
		return err
	case copying:
		_, err := h.files.Copy(ctx, owner, source.Path, to)
		return err
	}
	_, err := h.files.Move(ctx, owner, source.Path, to, files.BaseRevAny)
	return err
}

func (h *Handler) replace(req *request, source, target files.Entry, copying bool) error {
	access := req.space.Access
	if !source.IsDir && !target.IsDir {
		if err := access.RequireEdit(); err != nil {
			return err
		}
		return h.replaceContent(req, source, target, copying)
	}
	if err := access.RequireDelete(); err != nil {
		return err
	}
	if err := h.files.Delete(req.r.Context(), access.Owner, target.Path, files.BaseRevAny); err != nil {
		return err
	}
	h.locks.Release(req.space.key(target.Path))
	return h.transfer(req, source, target.Path, copying)
}

func (h *Handler) replaceContent(req *request, source, target files.Entry, copying bool) error {
	ctx := req.r.Context()
	owner := req.space.Access.Owner
	file, _, err := h.files.Open(ctx, owner, source.Path)
	if err != nil {
		return err
	}
	_, err = h.files.Write(ctx, owner, files.WriteRequest{
		Path:    target.Path,
		BaseRev: target.Rev,
		Mtime:   source.Mtime,
		Content: file,
	})
	file.Close()
	if err != nil || copying {
		return err
	}
	return h.files.Delete(ctx, owner, source.Path, source.Rev)
}
