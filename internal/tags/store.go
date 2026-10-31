package tags

import (
	"context"
	"database/sql"
	"errors"
	"slices"
	"strconv"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
)

const (
	selectTags = `SELECT t.id, t.name, t.color,
	(SELECT COUNT(*) FROM file_tags ft WHERE ft.tag_id = t.id) +
	(SELECT COUNT(*) FROM note_tags n JOIN files f ON f.id = n.file_id
	 WHERE f.user_id = t.user_id AND n.name_key = t.name_key
	   AND NOT EXISTS (SELECT 1 FROM file_tags ft WHERE ft.tag_id = t.id AND ft.file_id = n.file_id))
	FROM tags t`
	idBatch = 500
)

type UserTag struct {
	ID    int64  `json:"id"`
	Name  string `json:"name"`
	Color string `json:"color" doc:"Hex color such as #3e63dd"`
	Count int    `json:"count" doc:"How many of your files, folders and notes carry the tag"`
}

type FileTags struct {
	TagIDs    map[int64][]int64
	OtherTags map[int64][]string
}

type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

func notFound() error {
	return apperr.NotFound("tag not found")
}

func nameTaken(name string) error {
	return apperr.AlreadyExists("a tag named %s already exists", name)
}

func scanTag(row database.RowScanner) (UserTag, error) {
	var tag UserTag
	err := row.Scan(&tag.ID, &tag.Name, &tag.Color, &tag.Count)
	return tag, err
}

func (s *Store) List(ctx context.Context, userID int64) ([]UserTag, error) {
	return database.QueryAll(ctx, s.db, scanTag, selectTags+` WHERE t.user_id = $1 ORDER BY t.name_key`, userID)
}

func (s *Store) ByID(ctx context.Context, userID, id int64) (UserTag, error) {
	tag, err := scanTag(s.db.QueryRowContext(ctx, selectTags+` WHERE t.user_id = $1 AND t.id = $2`, userID, id))
	if errors.Is(err, sql.ErrNoRows) {
		return UserTag{}, notFound()
	}
	return tag, err
}

func (s *Store) ByKeys(ctx context.Context, userID int64, keys []string) (map[string]UserTag, error) {
	found := map[string]UserTag{}
	if len(keys) == 0 {
		return found, nil
	}
	args := []any{userID}
	list := inList(&args, keys)
	listed, err := database.QueryAll(ctx, s.db, scanTag, selectTags+` WHERE t.user_id = $1 AND t.name_key IN (`+list+`)`, args...)
	for _, tag := range listed {
		found[Key(tag.Name)] = tag
	}
	return found, err
}

func (s *Store) Insert(ctx context.Context, userID int64, name, color string) (UserTag, error) {
	if color == "" {
		next, err := s.nextColor(ctx, userID)
		if err != nil {
			return UserTag{}, err
		}
		color = next
	}
	var id int64
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO tags (user_id, name, name_key, color, created_at) VALUES ($1, $2, $3, $4, $5) RETURNING id`,
		userID, name, Key(name), color, time.Now().Unix()).Scan(&id)
	if database.IsUniqueViolation(err) {
		return UserTag{}, nameTaken(name)
	}
	if err != nil {
		return UserTag{}, err
	}
	return s.ByID(ctx, userID, id)
}

func (s *Store) nextColor(ctx context.Context, userID int64) (string, error) {
	var count int
	err := s.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM tags WHERE user_id = $1`, userID).Scan(&count)
	return paletteColor(count), err
}

func (s *Store) EnsureNames(ctx context.Context, userID int64, names []string) error {
	keys := make([]string, 0, len(names))
	for _, name := range names {
		keys = append(keys, Key(name))
	}
	existing, err := s.ByKeys(ctx, userID, keys)
	if err != nil {
		return err
	}
	for _, name := range names {
		if _, ok := existing[Key(name)]; ok {
			continue
		}
		if _, err := s.Insert(ctx, userID, name, ""); err != nil && !apperr.Is(err, apperr.KindAlreadyExists) {
			return err
		}
	}
	return nil
}

func (s *Store) Update(ctx context.Context, userID, id int64, name, color string) error {
	err := database.RequireAffected(notFound())(s.db.ExecContext(ctx,
		`UPDATE tags SET name = $1, name_key = $2, color = $3 WHERE user_id = $4 AND id = $5`,
		name, Key(name), color, userID, id))
	if database.IsUniqueViolation(err) {
		return nameTaken(name)
	}
	return err
}

func (s *Store) Delete(ctx context.Context, userID, id int64) error {
	return database.RequireAffected(notFound())(s.db.ExecContext(ctx, `DELETE FROM tags WHERE user_id = $1 AND id = $2`, userID, id))
}

func (s *Store) DeleteUnused(ctx context.Context, userID int64) (int64, error) {
	result, err := s.db.ExecContext(ctx,
		`DELETE FROM tags WHERE user_id = $1
		   AND NOT EXISTS (SELECT 1 FROM file_tags ft WHERE ft.tag_id = tags.id)
		   AND NOT EXISTS (SELECT 1 FROM note_tags n JOIN files f ON f.id = n.file_id
		                   WHERE f.user_id = tags.user_id AND n.name_key = tags.name_key)`, userID)
	if err != nil {
		return 0, err
	}
	return result.RowsAffected()
}

func (s *Store) AddManual(ctx context.Context, userID, fileID, tagID int64) error {
	_, err := s.db.ExecContext(ctx,
		`INSERT INTO file_tags (user_id, file_id, tag_id) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`,
		userID, fileID, tagID)
	return err
}

func (s *Store) RemoveManual(ctx context.Context, userID, fileID, tagID int64) error {
	_, err := s.db.ExecContext(ctx,
		`DELETE FROM file_tags WHERE user_id = $1 AND file_id = $2 AND tag_id = $3`, userID, fileID, tagID)
	return err
}

func (s *Store) ForFiles(ctx context.Context, viewerID int64, fileIDs []int64) (FileTags, error) {
	found := FileTags{TagIDs: map[int64][]int64{}, OtherTags: map[int64][]string{}}
	for len(fileIDs) > 0 {
		batch := fileIDs[:min(len(fileIDs), idBatch)]
		fileIDs = fileIDs[len(batch):]
		if err := s.manualTags(ctx, viewerID, batch, found); err != nil {
			return found, err
		}
		if err := s.noteTags(ctx, viewerID, batch, found); err != nil {
			return found, err
		}
	}
	return found, nil
}

func (s *Store) manualTags(ctx context.Context, viewerID int64, fileIDs []int64, found FileTags) error {
	args := []any{viewerID}
	list := inList(&args, fileIDs)
	rows, err := s.db.QueryContext(ctx,
		`SELECT ft.file_id, ft.tag_id FROM file_tags ft JOIN tags t ON t.id = ft.tag_id
		 WHERE ft.user_id = $1 AND ft.file_id IN (`+list+`) ORDER BY t.name_key`, args...)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var fileID, tagID int64
		if err := rows.Scan(&fileID, &tagID); err != nil {
			return err
		}
		found.TagIDs[fileID] = append(found.TagIDs[fileID], tagID)
	}
	return rows.Err()
}

func (s *Store) noteTags(ctx context.Context, viewerID int64, fileIDs []int64, found FileTags) error {
	args := []any{viewerID}
	list := inList(&args, fileIDs)
	rows, err := s.db.QueryContext(ctx,
		`SELECT n.file_id, n.name, t.id FROM note_tags n LEFT JOIN tags t ON t.user_id = $1 AND t.name_key = n.name_key
		 WHERE n.file_id IN (`+list+`) ORDER BY n.name_key`, args...)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var fileID int64
		var name string
		var tagID sql.NullInt64
		if err := rows.Scan(&fileID, &name, &tagID); err != nil {
			return err
		}
		switch {
		case !tagID.Valid:
			found.OtherTags[fileID] = append(found.OtherTags[fileID], name)
		case !slices.Contains(found.TagIDs[fileID], tagID.Int64):
			found.TagIDs[fileID] = append(found.TagIDs[fileID], tagID.Int64)
		}
	}
	return rows.Err()
}

func (s *Store) FileIDsWithTag(ctx context.Context, viewerID int64, key string) ([]int64, error) {
	return database.QueryAll(ctx, s.db, database.ScanInt64,
		`SELECT ft.file_id FROM file_tags ft JOIN tags t ON t.id = ft.tag_id WHERE ft.user_id = $1 AND t.name_key = $2
		 UNION
		 SELECT n.file_id FROM note_tags n JOIN files f ON f.id = n.file_id WHERE f.user_id = $1 AND n.name_key = $2`,
		viewerID, key)
}

func (s *Store) NotesWithTag(ctx context.Context, ownerID int64, key string) ([]int64, error) {
	return database.QueryAll(ctx, s.db, database.ScanInt64,
		`SELECT n.file_id FROM note_tags n JOIN files f ON f.id = n.file_id WHERE f.user_id = $1 AND n.name_key = $2 ORDER BY n.file_id`,
		ownerID, key)
}

func (s *Store) ReplaceNoteTags(ctx context.Context, fileID int64, hash string, names []string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	var currentHash string
	err = tx.QueryRowContext(ctx, `SELECT hash FROM files WHERE id = $1`, fileID).Scan(&currentHash)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && currentHash != hash) {
		return nil
	}
	if err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM note_tags WHERE file_id = $1`, fileID); err != nil {
		return err
	}
	for _, name := range names {
		if _, err := tx.ExecContext(ctx, `INSERT INTO note_tags (file_id, name_key, name) VALUES ($1, $2, $3)`,
			fileID, Key(name), name); err != nil {
			return err
		}
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO tag_sources (source_id, hash) VALUES ($1, $2) ON CONFLICT (source_id) DO UPDATE SET hash = excluded.hash`,
		fileID, hash); err != nil {
		return err
	}
	return tx.Commit()
}

func (s *Store) ForgetNote(ctx context.Context, fileID int64) error {
	if _, err := s.db.ExecContext(ctx, `DELETE FROM note_tags WHERE file_id = $1`, fileID); err != nil {
		return err
	}
	_, err := s.db.ExecContext(ctx, `DELETE FROM tag_sources WHERE source_id = $1`, fileID)
	return err
}

type staleNote struct {
	userID int64
	path   string
}

func (s *Store) staleNotes(ctx context.Context, limit int, mime string) ([]staleNote, error) {
	return database.QueryAll(ctx, s.db, func(row database.RowScanner) (staleNote, error) {
		var note staleNote
		err := row.Scan(&note.userID, &note.path)
		return note, err
	}, `SELECT f.user_id, f.path FROM files f LEFT JOIN tag_sources s ON s.source_id = f.id
		WHERE f.is_dir = FALSE AND f.mime = $1 AND (s.hash IS NULL OR s.hash <> f.hash)
		ORDER BY f.id LIMIT $2`, mime, limit)
}

func inList[T any](args *[]any, values []T) string {
	placeholders := make([]string, 0, len(values))
	for _, value := range values {
		*args = append(*args, value)
		placeholders = append(placeholders, "$"+strconv.Itoa(len(*args)))
	}
	return strings.Join(placeholders, ",")
}
