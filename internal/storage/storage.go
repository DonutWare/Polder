package storage

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"

	"polder-server/internal/apperr"
)

const (
	internalDirName = ".polder"
	tempFilePrefix  = ".polder-tmp-"
	dirPermissions  = 0o750
)

type Disk struct {
	dataDir string
}

func NewDisk(dataDir string) (*Disk, error) {
	disk := &Disk{dataDir: dataDir}
	for _, dir := range []string{dataDir, disk.UploadsDir(), disk.trashRoot(), disk.deletedUsersDir()} {
		if err := os.MkdirAll(dir, dirPermissions); err != nil {
			return nil, fmt.Errorf("create %s: %w", dir, err)
		}
	}
	return disk, nil
}

func (d *Disk) DataDir() string { return d.dataDir }

func (d *Disk) UserRoot(username string) string {
	return filepath.Join(d.dataDir, username)
}

func (d *Disk) UploadsDir() string {
	return filepath.Join(d.dataDir, internalDirName, "uploads")
}

func (d *Disk) trashRoot() string {
	return filepath.Join(d.dataDir, internalDirName, "trash")
}

func (d *Disk) deletedUsersDir() string {
	return filepath.Join(d.dataDir, internalDirName, "deleted-users")
}

func (d *Disk) EnsureUserRoot(username string) error {
	return os.MkdirAll(d.UserRoot(username), dirPermissions)
}

func (d *Disk) Resolve(username, cleanPath string) (string, error) {
	root := d.UserRoot(username)
	if cleanPath == RootPath {
		return root, nil
	}
	relative := filepath.FromSlash(strings.TrimPrefix(cleanPath, "/"))
	if err := rejectSymlinks(root, relative); err != nil {
		return "", err
	}
	return filepath.Join(root, relative), nil
}

func rejectSymlinks(root, relative string) error {
	current := root
	for _, segment := range strings.Split(relative, string(filepath.Separator)) {
		current = filepath.Join(current, segment)
		info, err := os.Lstat(current)
		if errors.Is(err, fs.ErrNotExist) {
			return nil
		}
		if err != nil {
			return err
		}
		if info.Mode()&fs.ModeSymlink != 0 {
			return apperr.Forbidden("symbolic links are not supported")
		}
	}
	return nil
}

func (d *Disk) CreateTempFile(directory string) (*os.File, error) {
	if err := os.MkdirAll(directory, dirPermissions); err != nil {
		return nil, err
	}
	return os.CreateTemp(directory, tempFilePrefix+"*")
}

func (d *Disk) TrashItemPath(username, storageID, name string) string {
	return filepath.Join(d.trashRoot(), username, storageID, name)
}

func (d *Disk) MoveToTrash(username, absolutePath, storageID, name string) error {
	target := d.TrashItemPath(username, storageID, name)
	if err := os.MkdirAll(filepath.Dir(target), dirPermissions); err != nil {
		return err
	}
	return os.Rename(absolutePath, target)
}

func (d *Disk) RemoveTrashItem(username, storageID string) error {
	return os.RemoveAll(filepath.Join(d.trashRoot(), username, storageID))
}

func (d *Disk) ArchiveUserRoot(username string) error {
	archive := filepath.Join(d.deletedUsersDir(), username+"-"+time.Now().UTC().Format("20060102T150405"))
	if err := renameIfExists(d.UserRoot(username), archive); err != nil {
		return err
	}
	return renameIfExists(filepath.Join(d.trashRoot(), username), archive+"-trash")
}

func renameIfExists(source, target string) error {
	if _, err := os.Stat(source); errors.Is(err, fs.ErrNotExist) {
		return nil
	}
	return os.Rename(source, target)
}

func NewID() string {
	buffer := make([]byte, 16)
	_, _ = rand.Read(buffer)
	return hex.EncodeToString(buffer)
}

func MakeDirs(absolutePath string) error {
	return os.MkdirAll(absolutePath, dirPermissions)
}
