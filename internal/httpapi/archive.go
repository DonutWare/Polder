package httpapi

import (
	"archive/zip"
	"errors"
	"io"
	"io/fs"
	"mime"
	"os"
	"path/filepath"

	"github.com/danielgtaylor/huma/v2"

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

func writeZip(w io.Writer, root string) error {
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
