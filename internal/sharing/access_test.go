package sharing

import (
	"testing"

	"polder-server/internal/files"
)

func TestAccessKeepsPathsInsideTheRoot(t *testing.T) {
	folder := Access{Root: files.Entry{Path: "/Photos/Summer", IsDir: true}}
	file := Access{Root: files.Entry{Path: "/Docs/a.txt"}}
	cases := []struct {
		name     string
		access   Access
		relative string
		want     string
		fails    bool
	}{
		{"root", folder, "/", "/Photos/Summer", false},
		{"empty", folder, "", "/Photos/Summer", false},
		{"child", folder, "/beach.jpg", "/Photos/Summer/beach.jpg", false},
		{"without slash", folder, "Day 1/a.jpg", "/Photos/Summer/Day 1/a.jpg", false},
		{"parent", folder, "/..", "", true},
		{"climbing", folder, "/a/../../Winter", "", true},
		{"file root", file, "/", "/Docs/a.txt", false},
		{"inside a file", file, "/x", "", true},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := tc.access.Path(tc.relative)
			if (err != nil) != tc.fails || got != tc.want {
				t.Fatalf("Path(%q) = %q, %v", tc.relative, got, err)
			}
		})
	}
	if _, err := folder.Inner("/"); err == nil {
		t.Fatal("Inner must reject the root")
	}
	if got := folder.RelativePath("/Photos/Summer/Day 1/a.jpg"); got != "/Day 1/a.jpg" {
		t.Fatalf("RelativePath = %q", got)
	}
	if got := folder.RelativePath("/Photos/Summer"); got != "/" {
		t.Fatalf("RelativePath of root = %q", got)
	}
}

func TestCodesUseTheAlphabet(t *testing.T) {
	for range 100 {
		code, err := newCode()
		if err != nil || !validCode(code) || len(code) != codeLength {
			t.Fatalf("bad code %q %v", code, err)
		}
	}
}
