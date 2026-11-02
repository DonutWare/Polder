package httpapi

import (
	"archive/zip"
	"errors"
	"io"
	"io/fs"
	"mime"
	"os"
	"path"
	"path/filepath"
	"strings"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/sharing"
	"polder-server/internal/storage"
)

const maxConcurrentArchives = 4

type attachmentOutput struct {
	ContentType        string `header:"Content-Type"`
	ContentDisposition string `header:"Content-Disposition"`
	Body               func(huma.Context)
}

func attachment(name string) string {
	return mime.FormatMediaType("attachment", map[string]string{"filename": name})
}

type noteRewriter func(name string, content []byte) []byte

func writeZip(w io.Writer, root string, notes noteRewriter) error {
	archive := zip.NewWriter(w)
	err := filepath.WalkDir(root, func(current string, entry fs.DirEntry, err error) error {
		if err != nil || current == root {
			return err
		}
		if storage.IsReservedName(entry.Name()) || storage.IsSystemFile(entry.Name()) {
			if entry.IsDir() {
				return fs.SkipDir
			}
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
		if notes != nil && strings.EqualFold(filepath.Ext(name), ".md") {
			return addVisitorNote(archive, current, name, entry, notes)
		}
		return addZipFile(archive, current, name, entry)
	})
	return errors.Join(err, archive.Close())
}

func addVisitorNote(archive *zip.Writer, absolute, name string, entry fs.DirEntry, notes noteRewriter) error {
	info, err := entry.Info()
	if err != nil {
		return err
	}
	file, err := os.Open(absolute)
	if err != nil {
		return err
	}
	defer file.Close()
	content, err := readVisitorNote(file, name)
	if apperr.Is(err, apperr.KindInvalid) {
		return nil
	}
	if err != nil {
		return err
	}
	header := &zip.FileHeader{Name: name, Method: zip.Deflate, Modified: info.ModTime()}
	target, err := archive.CreateHeader(header)
	if err != nil {
		return err
	}
	_, err = target.Write(notes(name, content))
	return err
}

func readVisitorNote(note io.Reader, name string) ([]byte, error) {
	content, err := io.ReadAll(io.LimitReader(note, sharing.MaxVisitorNoteBytes+1))
	if err == nil && len(content) > sharing.MaxVisitorNoteBytes {
		return nil, apperr.Invalid("%s is too large to share", path.Base(name))
	}
	return content, err
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
