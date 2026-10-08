package versions

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
	"time"

	"polder-server/internal/chunker"
	"polder-server/internal/chunkstore"
	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

var logger = logging.For("versions")

const (
	backlogInterval     = time.Minute
	maintenanceInterval = time.Hour
	pendingBatchSize    = 50
)

type Worker struct {
	files               *files.Service
	users               *users.Store
	settings            *settings.Store
	ingestRequests      chan struct{}
	maintenanceRequests chan struct{}
	now                 func() time.Time
}

func NewWorker(fileService *files.Service, userStore *users.Store, serverSettings *settings.Store) *Worker {
	worker := &Worker{
		files:               fileService,
		users:               userStore,
		settings:            serverSettings,
		ingestRequests:      make(chan struct{}, 1),
		maintenanceRequests: make(chan struct{}, 1),
		now:                 time.Now,
	}
	fileService.SetVersioningPolicy(worker.keepsHistory)
	fileService.OnVersionsChanged(worker.RequestIngest)
	fileService.OnRescanned(worker.RequestMaintenance)
	return worker
}

func (w *Worker) keepsHistory(ctx context.Context, owner users.User) bool {
	retention, err := w.Retention(ctx, owner)
	if err != nil {
		logger.Warn("load history settings", "user", owner.Username, "error", err)
		return false
	}
	return retention.Enabled
}

func (w *Worker) Retention(ctx context.Context, owner users.User) (settings.VersionRetention, error) {
	server, err := w.settings.Get(ctx)
	if err != nil {
		return settings.VersionRetention{}, err
	}
	return settings.ResolveVersionRetention(server, owner), nil
}

func (w *Worker) RequestIngest() {
	select {
	case w.ingestRequests <- struct{}{}:
	default:
	}
}

func (w *Worker) RequestMaintenance() {
	select {
	case w.maintenanceRequests <- struct{}{}:
	default:
	}
}

func (w *Worker) Run(ctx context.Context) {
	backlog := time.NewTicker(backlogInterval)
	defer backlog.Stop()
	maintenance := time.NewTicker(maintenanceInterval)
	defer maintenance.Stop()
	w.ingestPending(ctx)
	w.Maintain(ctx)
	for {
		select {
		case <-ctx.Done():
			return
		case <-w.ingestRequests:
			w.ingestPending(ctx)
		case <-backlog.C:
			w.ingestPending(ctx)
		case <-maintenance.C:
			w.Maintain(ctx)
		case <-w.maintenanceRequests:
			w.Maintain(ctx)
		}
	}
}

func (w *Worker) ingestPending(ctx context.Context) {
	touched := map[int64]bool{}
	for ctx.Err() == nil {
		pending, err := w.files.PendingVersions(ctx, pendingBatchSize)
		if err != nil {
			logger.Warn("load pending versions", "error", err)
			return
		}
		if len(pending) == 0 {
			break
		}
		for _, version := range pending {
			if err := w.Ingest(ctx, version); err != nil {
				logger.Warn("store version", "user", version.Username, "version", version.ID, "error", err)
				if err := w.files.DropVersion(ctx, version); err != nil {
					logger.Warn("drop version", "version", version.ID, "error", err)
				}
			}
			touched[version.UserID] = true
		}
	}
	for userID := range touched {
		owner, err := w.users.ByID(ctx, userID)
		if err != nil {
			continue
		}
		if err := w.ApplyRetention(ctx, owner); err != nil {
			logger.Warn("thin out history", "user", owner.Username, "error", err)
		}
	}
}

func (w *Worker) Ingest(ctx context.Context, version files.PendingVersion) error {
	disk := w.files.Disk()
	pendingPath := disk.PendingVersionPath(version.Username, version.ID)
	source, err := os.Open(pendingPath)
	if err != nil {
		return err
	}
	defer source.Close()

	hasher := sha256.New()
	var chunks []files.VersionChunk
	written := map[string]files.VersionChunk{}
	err = chunker.Split(io.TeeReader(source, hasher), func(chunk chunker.Chunk, data []byte) error {
		stored, err := w.storeChunk(ctx, version, chunk, data, written)
		if err != nil {
			return err
		}
		chunks = append(chunks, stored)
		return nil
	})
	if err != nil {
		return err
	}
	if hex.EncodeToString(hasher.Sum(nil)) != version.Hash {
		return errors.New("content changed before it was stored")
	}
	if err := w.files.CompleteVersion(ctx, version, chunks); err != nil {
		return err
	}
	source.Close()
	return os.Remove(pendingPath)
}

func (w *Worker) storeChunk(ctx context.Context, version files.PendingVersion, chunk chunker.Chunk, data []byte, written map[string]files.VersionChunk) (files.VersionChunk, error) {
	if stored, done := written[chunk.Hash]; done {
		return stored, nil
	}
	chunkPath := w.files.Disk().VersionChunkPath(version.Username, chunk.Hash)
	stored, found, err := w.files.StoredChunk(ctx, version.UserID, chunk.Hash)
	if err != nil {
		return files.VersionChunk{}, err
	}
	if !found || !chunkstore.Exists(chunkPath) {
		result, err := chunkstore.Write(chunkPath, data)
		if err != nil {
			return files.VersionChunk{}, err
		}
		stored = files.VersionChunk{StoredSize: result.Size, Compressed: result.Compressed}
	}
	stored.Hash, stored.Size = chunk.Hash, chunk.Size
	written[chunk.Hash] = stored
	return stored, nil
}

func (w *Worker) Maintain(ctx context.Context) {
	allUsers, err := w.users.List(ctx)
	if err != nil {
		logger.Warn("list users for history upkeep", "error", err)
		return
	}
	for _, owner := range allUsers {
		if ctx.Err() != nil {
			return
		}
		if _, err := w.files.ReconcileTrash(ctx, owner); err != nil {
			logger.Warn("reconcile trash with disk", "user", owner.Username, "error", err)
		}
		referenced, err := w.files.ReconcileHistory(ctx, owner)
		if err != nil {
			logger.Warn("reconcile history with disk", "user", owner.Username, "error", err)
			continue
		}
		if err := w.ApplyRetention(ctx, owner); err != nil {
			logger.Warn("thin out history", "user", owner.Username, "error", err)
		}
		if err := w.files.RemoveOrphanedPendingVersions(ctx, owner); err != nil {
			logger.Warn("remove orphaned pending versions", "user", owner.Username, "error", err)
		}
		if err := w.removeOrphanedChunks(ctx, owner, referenced); err != nil {
			logger.Warn("remove orphaned history chunks", "user", owner.Username, "error", err)
		}
	}
}

func (w *Worker) ApplyRetention(ctx context.Context, owner users.User) error {
	retention, err := w.Retention(ctx, owner)
	if err != nil {
		return err
	}
	versions, err := w.files.AllVersions(ctx, owner.ID)
	if err != nil || len(versions) == 0 {
		return err
	}
	var removed []int64
	if !retention.Enabled {
		for _, version := range versions {
			removed = append(removed, version.ID)
		}
		return w.files.DeleteVersions(ctx, owner, removed)
	}
	histories := map[string][]files.Version{}
	for _, version := range versions {
		histories[version.HistoryID] = append(histories[version.HistoryID], version)
	}
	limits := Limits{KeepAll: retention.KeepAll(), MaxAge: retention.MaxAge(), MaxPerFile: retention.MaxPerFile}
	now := w.now()
	for _, history := range histories {
		removed = append(removed, ToRemove(history, limits, now)...)
	}
	return w.files.DeleteVersions(ctx, owner, removed)
}

func (w *Worker) removeOrphanedChunks(ctx context.Context, owner users.User, referenced map[string]bool) error {
	stored, err := w.files.StoredChunkHashes(ctx, owner.ID)
	if err != nil {
		return err
	}
	root := w.files.Disk().VersionChunksDir(owner.Username)
	err = filepath.WalkDir(root, func(current string, entry fs.DirEntry, err error) error {
		if errors.Is(err, fs.ErrNotExist) {
			return nil
		}
		if err != nil || entry.IsDir() {
			return err
		}
		if strings.HasPrefix(entry.Name(), ".") || (!stored[entry.Name()] && !referenced[entry.Name()]) {
			return os.Remove(current)
		}
		return nil
	})
	return err
}
