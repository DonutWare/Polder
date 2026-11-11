package apperr

import (
	"errors"
	"syscall"
)

const sqliteFull = 13

type sqliteCoder interface {
	Code() int
}

func IsNoSpace(err error) bool {
	if err == nil {
		return false
	}
	if errors.Is(err, syscall.ENOSPC) || errors.Is(err, syscall.EDQUOT) {
		return true
	}
	var coded sqliteCoder
	return errors.As(err, &coded) && coded.Code()&0xff == sqliteFull
}

func FromNoSpace(err error) (*Error, bool) {
	if !IsNoSpace(err) {
		return nil, false
	}
	return StorageFull("the server has run out of disk space and could not save the change"), true
}
