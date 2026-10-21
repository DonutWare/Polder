package files

import (
	"context"
	"fmt"
	"strings"
	"unicode/utf8"

	"polder-server/internal/storage"
	"polder-server/internal/users"
)

type TreeTag struct {
	MaxRev int64
	Count  int64
}

func (t TreeTag) ETag() string {
	return fmt.Sprintf(`"t%d-%d"`, t.MaxRev, t.Count)
}

func (t *TreeTag) include(rev int64) {
	t.MaxRev = max(t.MaxRev, rev)
	t.Count++
}

func (s *Service) TreeTags(ctx context.Context, owner users.User, directory Entry) (TreeTag, map[string]TreeTag, error) {
	self := TreeTag{}
	prefix := storage.RootPath
	if directory.Path != storage.RootPath {
		self.include(directory.Rev)
		prefix = directory.Path + "/"
	}
	children := map[string]TreeTag{}
	rows, err := s.db.QueryContext(ctx,
		`SELECT path, rev FROM files WHERE user_id = $1 AND SUBSTR(path, 1, $2) = $3`,
		owner.ID, utf8.RuneCountInString(prefix), prefix)
	if err != nil {
		return TreeTag{}, nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var filePath string
		var rev int64
		if err := rows.Scan(&filePath, &rev); err != nil {
			return TreeTag{}, nil, err
		}
		self.include(rev)
		child, _, _ := strings.Cut(strings.TrimPrefix(filePath, prefix), "/")
		tag := children[child]
		tag.include(rev)
		children[child] = tag
	}
	return self, children, rows.Err()
}
