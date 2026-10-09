package links

import (
	"context"
	"path"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/users"
)

const (
	attachmentsFolder = "attachments"
	attachmentGrace   = 24 * time.Hour
)

type attachment struct {
	path string
	rev  int64
}

func (g *Graph) TrashUnlinkedAttachments(ctx context.Context, owner users.User, now time.Time) (int, error) {
	unread, err := g.hasUnreadSources(ctx, owner.ID)
	if err != nil || unread {
		return 0, err
	}
	unlinked, err := g.unlinkedAttachments(ctx, owner.ID, now.Add(-attachmentGrace))
	if err != nil {
		return 0, err
	}
	besideNotes := map[string]bool{}
	trashed := 0
	for _, file := range unlinked {
		noteFolder := path.Dir(path.Dir(file.path))
		if _, checked := besideNotes[noteFolder]; !checked {
			if besideNotes[noteFolder], err = g.holdsNotes(ctx, owner, noteFolder); err != nil {
				return trashed, err
			}
		}
		if !besideNotes[noteFolder] {
			continue
		}
		err := g.files.Delete(ctx, owner, file.path, file.rev)
		if apperr.Is(err, apperr.KindNotFound) || apperr.Is(err, apperr.KindConflict) {
			continue
		}
		if err != nil {
			return trashed, err
		}
		trashed++
	}
	return trashed, nil
}

func (g *Graph) hasUnreadSources(ctx context.Context, userID int64) (bool, error) {
	for _, extractor := range g.extractors {
		stale, err := g.staleSources(ctx, extractor, userID, 1)
		if err != nil || len(stale) > 0 {
			return len(stale) > 0, err
		}
	}
	return false, nil
}

func (g *Graph) holdsNotes(ctx context.Context, owner users.User, folder string) (bool, error) {
	_, entries, err := g.files.List(ctx, owner, folder)
	if err != nil {
		return false, err
	}
	for _, entry := range entries {
		if entry.Mime == files.MarkdownMime {
			return true, nil
		}
	}
	return false, nil
}

func (g *Graph) unlinkedAttachments(ctx context.Context, userID int64, changedBefore time.Time) ([]attachment, error) {
	rows, err := g.db.QueryContext(ctx,
		`SELECT f.path, f.rev FROM files f LEFT JOIN changes c ON c.id = f.rev
		 WHERE f.user_id = $1 AND f.is_dir = FALSE AND f.path LIKE $2
		   AND (c.created_at IS NULL OR c.created_at < $3)
		   AND NOT EXISTS (SELECT 1 FROM file_links l WHERE l.user_id = f.user_id
		     AND (l.target_id = f.id OR (l.target_id IS NULL AND l.target_path = f.path)))`,
		userID, "%/"+attachmentsFolder+"/%", changedBefore.Unix())
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var unlinked []attachment
	for rows.Next() {
		var file attachment
		if err := rows.Scan(&file.path, &file.rev); err != nil {
			return nil, err
		}
		if path.Base(path.Dir(file.path)) == attachmentsFolder {
			unlinked = append(unlinked, file)
		}
	}
	return unlinked, rows.Err()
}
