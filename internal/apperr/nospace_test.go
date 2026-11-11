package apperr

import (
	"errors"
	"fmt"
	"os"
	"syscall"
	"testing"
)

type fakeSQLiteError int

func (e fakeSQLiteError) Error() string { return "sqlite error" }
func (e fakeSQLiteError) Code() int     { return int(e) }

func TestIsNoSpace(t *testing.T) {
	cases := map[string]struct {
		err  error
		want bool
	}{
		"nil":                {nil, false},
		"plain":              {errors.New("boom"), false},
		"enospc":             {&os.PathError{Op: "write", Path: "/x", Err: syscall.ENOSPC}, true},
		"wrapped enospc":     {fmt.Errorf("store: %w", syscall.ENOSPC), true},
		"sqlite full":        {fmt.Errorf("commit: %w", fakeSQLiteError(13)), true},
		"sqlite extended":    {fakeSQLiteError(13 | 1<<8), true},
		"sqlite other error": {fakeSQLiteError(5), false},
	}
	for name, tc := range cases {
		if got := IsNoSpace(tc.err); got != tc.want {
			t.Errorf("%s: IsNoSpace = %v, want %v", name, got, tc.want)
		}
	}
}
