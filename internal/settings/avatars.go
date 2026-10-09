package settings

import (
	"errors"
	"os"
	"path/filepath"
	"strconv"

	"polder-server/internal/apperr"
)

type Avatars struct {
	dir string
}

func NewAvatars(dir string) *Avatars {
	return &Avatars{dir: dir}
}

func (a *Avatars) Save(userID int64, content []byte) (ImageInfo, error) {
	if err := checkImage(content); err != nil {
		return ImageInfo{}, err
	}
	if err := write(a.path(userID), content); err != nil {
		return ImageInfo{}, err
	}
	return infoOf(content), nil
}

func (a *Avatars) Read(userID int64, info ImageInfo) (Image, error) {
	image, err := read(info, a.path(userID))
	if errors.Is(err, os.ErrNotExist) {
		return Image{}, apperr.NotFound("no such icon")
	}
	return image, err
}

func (a *Avatars) Remove(userID int64) error {
	if err := os.Remove(a.path(userID)); err != nil && !errors.Is(err, os.ErrNotExist) {
		return err
	}
	return nil
}

func (a *Avatars) path(userID int64) string {
	return filepath.Join(a.dir, strconv.FormatInt(userID, 10))
}
