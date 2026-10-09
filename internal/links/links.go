package links

import (
	"context"
	"database/sql"
	"errors"
	"io"
	"slices"
	"strconv"
	"strings"
	"sync"
	"time"

	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/users"
)

var logger = logging.For("links")

const (
	queueCapacity   = 1024
	backlogInterval = time.Minute
	backlogBatch    = 20
)

type Link struct {
	Title      string
	TargetPath string
	TargetID   int64
}

type Extractor interface {
	Kind() string
	Mimes() []string
	Extract(entry files.Entry, content io.Reader) ([]Link, error)
}

type Outgoing struct {
	Kind       string       `json:"kind" doc:"What made the link, such as markdown"`
	Title      string       `json:"title"`
	TargetPath string       `json:"targetPath" doc:"Where the link points; the target's current path when it still exists"`
	Target     *files.Entry `json:"target,omitempty" required:"false" doc:"The linked file; absent when it no longer exists"`
}

type Incoming struct {
	Kind   string      `json:"kind" doc:"What made the link, such as markdown"`
	Title  string      `json:"title"`
	Source files.Entry `json:"source" doc:"The file that holds the link"`
}

type job struct {
	userID int64
	path   string
}

type move struct {
	userID int64
	path   string
	from   string
}

type Graph struct {
	db         *sql.DB
	files      *files.Service
	users      *users.Store
	extractors []Extractor
	queue      chan job

	movesMutex sync.Mutex
	moves      []move
	movesReady chan struct{}
}

func NewGraph(db *sql.DB, fileService *files.Service, userStore *users.Store, extractors ...Extractor) *Graph {
	return &Graph{
		db:         db,
		files:      fileService,
		users:      userStore,
		extractors: extractors,
		queue:      make(chan job, queueCapacity),
		movesReady: make(chan struct{}, 1),
	}
}

func (g *Graph) Enqueue(userID int64, cleanPath string) {
	select {
	case g.queue <- job{userID: userID, path: cleanPath}:
	default:
	}
}

func (g *Graph) Run(ctx context.Context) {
	sweep := time.NewTimer(0)
	defer sweep.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case next := <-g.queue:
			g.indexPath(ctx, next.userID, next.path)
		case <-g.movesReady:
			for _, moved := range g.takeMoves() {
				g.relinkAfterMove(ctx, moved)
			}
		case <-sweep.C:
			if g.sweep(ctx) {
				sweep.Reset(0)
			} else {
				sweep.Reset(backlogInterval)
			}
		}
	}
}

func (g *Graph) sweep(ctx context.Context) (more bool) {
	for _, extractor := range g.extractors {
		stale, err := g.staleSources(ctx, extractor, everyUser, backlogBatch)
		if err != nil {
			logger.Warn("load files whose links are not read", "kind", extractor.Kind(), "error", err)
			return false
		}
		for _, source := range stale {
			if ctx.Err() != nil {
				return false
			}
			g.indexPath(ctx, source.userID, source.path)
		}
		if len(stale) == backlogBatch {
			return true
		}
	}
	return false
}

const everyUser = 0

func (g *Graph) staleSources(ctx context.Context, extractor Extractor, userID int64, limit int) ([]job, error) {
	args := []any{extractor.Kind(), userID, limit}
	placeholders := make([]string, 0, len(extractor.Mimes()))
	for _, mimeType := range extractor.Mimes() {
		args = append(args, mimeType)
		placeholders = append(placeholders, "$"+strconv.Itoa(len(args)))
	}
	rows, err := g.db.QueryContext(ctx,
		`SELECT f.user_id, f.path FROM files f LEFT JOIN link_sources s ON s.source_id = f.id AND s.kind = $1
		 WHERE ($2 = 0 OR f.user_id = $2) AND f.is_dir = FALSE AND f.mime IN (`+strings.Join(placeholders, ",")+`)
		   AND (s.hash IS NULL OR s.hash <> f.hash)
		 ORDER BY f.id LIMIT $3`, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var stale []job
	for rows.Next() {
		var source job
		if err := rows.Scan(&source.userID, &source.path); err != nil {
			return nil, err
		}
		stale = append(stale, source)
	}
	return stale, rows.Err()
}

func (g *Graph) indexPath(ctx context.Context, userID int64, cleanPath string) {
	owner, err := g.users.ByID(ctx, userID)
	if err != nil {
		return
	}
	entry, err := g.files.Stat(ctx, owner, cleanPath)
	if err != nil || entry.IsDir {
		return
	}
	for _, extractor := range g.extractors {
		if !slices.Contains(extractor.Mimes(), entry.Mime) {
			if err := g.forget(ctx, entry.ID, extractor.Kind()); err != nil {
				logger.Warn("remove links", "path", entry.Path, "kind", extractor.Kind(), "error", err)
			}
			continue
		}
		found, err := g.extract(ctx, owner, entry, extractor)
		if err != nil {
			logger.Warn("read links", "path", entry.Path, "kind", extractor.Kind(), "error", err)
			continue
		}
		if err := g.store(ctx, owner, entry, extractor.Kind(), found); err != nil {
			logger.Warn("store links", "path", entry.Path, "kind", extractor.Kind(), "error", err)
		}
	}
}

func (g *Graph) forget(ctx context.Context, sourceID int64, kind string) error {
	if _, err := g.db.ExecContext(ctx, `DELETE FROM file_links WHERE source_id = $1 AND kind = $2`, sourceID, kind); err != nil {
		return err
	}
	_, err := g.db.ExecContext(ctx, `DELETE FROM link_sources WHERE source_id = $1 AND kind = $2`, sourceID, kind)
	return err
}

func (g *Graph) extract(ctx context.Context, owner users.User, entry files.Entry, extractor Extractor) ([]Link, error) {
	file, _, err := g.files.Open(ctx, owner, entry.Path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	return extractor.Extract(entry, file)
}

type storedLink struct {
	Link
	targetID sql.NullInt64
}

func (g *Graph) store(ctx context.Context, owner users.User, entry files.Entry, kind string, found []Link) error {
	resolved := make([]storedLink, 0, len(found))
	for _, link := range found {
		resolved = append(resolved, g.resolve(ctx, owner, link))
	}
	tx, err := g.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer func() { _ = tx.Rollback() }()
	var currentHash string
	err = tx.QueryRowContext(ctx, `SELECT hash FROM files WHERE id = $1`, entry.ID).Scan(&currentHash)
	if errors.Is(err, sql.ErrNoRows) || (err == nil && currentHash != entry.Hash) {
		return nil
	}
	if err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM file_links WHERE source_id = $1 AND kind = $2`, entry.ID, kind); err != nil {
		return err
	}
	for _, link := range resolved {
		if _, err := tx.ExecContext(ctx,
			`INSERT INTO file_links (user_id, source_id, kind, target_id, target_path, title) VALUES ($1, $2, $3, $4, $5, $6)`,
			owner.ID, entry.ID, kind, link.targetID, link.TargetPath, link.Title); err != nil {
			return err
		}
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO link_sources (source_id, kind, hash) VALUES ($1, $2, $3)
		 ON CONFLICT (source_id, kind) DO UPDATE SET hash = excluded.hash`, entry.ID, kind, entry.Hash); err != nil {
		return err
	}
	return tx.Commit()
}

func (g *Graph) resolve(ctx context.Context, owner users.User, link Link) storedLink {
	if link.TargetID != 0 {
		if target, err := g.files.EntryByID(ctx, owner.ID, link.TargetID); err == nil {
			link.TargetPath = target.Path
			return storedLink{Link: link, targetID: sql.NullInt64{Int64: target.ID, Valid: true}}
		}
	}
	if link.TargetPath == "" {
		return storedLink{Link: link}
	}
	target, err := g.files.Stat(ctx, owner, link.TargetPath)
	if err != nil {
		return storedLink{Link: link}
	}
	return storedLink{Link: link, targetID: sql.NullInt64{Int64: target.ID, Valid: true}}
}

func (g *Graph) Outgoing(ctx context.Context, owner users.User, sourceID int64) ([]Outgoing, error) {
	rows, err := g.db.QueryContext(ctx,
		`SELECT kind, title, target_path, target_id FROM file_links WHERE user_id = $1 AND source_id = $2 ORDER BY id`, owner.ID, sourceID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var links []Outgoing
	var targetIDs []int64
	var linkTargets []int64
	for rows.Next() {
		var link Outgoing
		var targetID sql.NullInt64
		if err := rows.Scan(&link.Kind, &link.Title, &link.TargetPath, &targetID); err != nil {
			return nil, err
		}
		links = append(links, link)
		linkTargets = append(linkTargets, targetID.Int64)
		if targetID.Valid {
			targetIDs = append(targetIDs, targetID.Int64)
		}
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	targets, err := g.files.EntriesByID(ctx, owner.ID, targetIDs)
	if err != nil {
		return nil, err
	}
	for i := range links {
		if target, ok := targets[linkTargets[i]]; ok {
			links[i].Target = &target
			links[i].TargetPath = target.Path
		}
	}
	return links, nil
}

func (g *Graph) Incoming(ctx context.Context, owner users.User, target files.Entry) ([]Incoming, error) {
	rows, err := g.db.QueryContext(ctx,
		`SELECT kind, title, source_id FROM file_links
		 WHERE user_id = $1 AND source_id <> $2 AND (target_id = $2 OR (target_id IS NULL AND target_path = $3))
		 ORDER BY id`, owner.ID, target.ID, target.Path)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	type row struct {
		kind, title string
		sourceID    int64
	}
	var found []row
	var sourceIDs []int64
	for rows.Next() {
		var r row
		if err := rows.Scan(&r.kind, &r.title, &r.sourceID); err != nil {
			return nil, err
		}
		found = append(found, r)
		sourceIDs = append(sourceIDs, r.sourceID)
	}
	if err := rows.Err(); err != nil {
		return nil, err
	}
	sources, err := g.files.EntriesByID(ctx, owner.ID, sourceIDs)
	if err != nil {
		return nil, err
	}
	var links []Incoming
	for _, r := range found {
		if source, ok := sources[r.sourceID]; ok {
			links = append(links, Incoming{Kind: r.kind, Title: r.title, Source: source})
		}
	}
	return links, nil
}
