package storage

import (
	"errors"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"syscall"
)

func Move(source, target string) error {
	err := os.Rename(source, target)
	if !errors.Is(err, syscall.EXDEV) {
		return err
	}
	if err := copyTree(source, target); err != nil {
		_ = os.RemoveAll(target)
		return fmt.Errorf("copy across filesystems: %w", err)
	}
	return os.RemoveAll(source)
}

func copyTree(source, target string) error {
	info, err := os.Lstat(source)
	if err != nil {
		return err
	}
	switch {
	case info.Mode()&fs.ModeSymlink != 0:
		return copySymlink(source, target)
	case info.IsDir():
		return copyDirectory(source, target, info)
	default:
		return copyRegularFile(source, target, info)
	}
}

func copySymlink(source, target string) error {
	destination, err := os.Readlink(source)
	if err != nil {
		return err
	}
	return os.Symlink(destination, target)
}

func copyDirectory(source, target string, info fs.FileInfo) error {
	if err := os.Mkdir(target, info.Mode().Perm()); err != nil {
		return err
	}
	children, err := os.ReadDir(source)
	if err != nil {
		return err
	}
	for _, child := range children {
		if err := copyTree(filepath.Join(source, child.Name()), filepath.Join(target, child.Name())); err != nil {
			return err
		}
	}
	return os.Chtimes(target, info.ModTime(), info.ModTime())
}

func copyRegularFile(source, target string, info fs.FileInfo) error {
	input, err := os.Open(source)
	if err != nil {
		return err
	}
	defer input.Close()
	output, err := os.OpenFile(target, os.O_WRONLY|os.O_CREATE|os.O_EXCL, info.Mode().Perm())
	if err != nil {
		return err
	}
	_, copyErr := io.Copy(output, input)
	syncErr := output.Sync()
	closeErr := output.Close()
	if err := errors.Join(copyErr, syncErr, closeErr); err != nil {
		return err
	}
	return os.Chtimes(target, info.ModTime(), info.ModTime())
}
