package app

import (
	"context"
	"database/sql"
	"fmt"
	"io/fs"
	"log/slog"
	"net/http"
	"os"
	"time"

	"nomad-server/internal/auth"
	"nomad-server/internal/config"
	"nomad-server/internal/database"
	"nomad-server/internal/files"
	"nomad-server/internal/httpapi"
	"nomad-server/internal/preview"
	"nomad-server/internal/scanner"
	"nomad-server/internal/storage"
	"nomad-server/internal/syncing"
	"nomad-server/internal/users"
	"nomad-server/internal/webui"
)

const uploadCleanupInterval = time.Hour

type App struct {
	Config   config.Config
	Handler  http.Handler
	Files    *files.Service
	Users    *users.Store
	db       *sql.DB
	scanner  *scanner.Scanner
	previews *preview.Worker
	sync     *syncing.Service
}

func New(cfg config.Config) (*App, error) {
	db, err := database.Open(cfg)
	if err != nil {
		return nil, err
	}
	built, err := wire(cfg, db)
	if err != nil {
		db.Close()
		return nil, err
	}
	return built, nil
}

func wire(cfg config.Config, db *sql.DB) (*App, error) {
	disk, err := storage.NewDisk(cfg.DataDir)
	if err != nil {
		return nil, err
	}
	tokens, err := auth.LoadOrCreateSigningKey(cfg.JWTKeyPath())
	if err != nil {
		return nil, err
	}

	userStore := users.NewStore(db)
	userService := users.NewService(userStore, auth.Argon2Hasher{}, disk)
	sessions := auth.NewSessions(db)
	fileService := files.NewService(db, disk)
	syncService := syncing.NewService(db, fileService)
	previews := preview.NewWorker(fileService, userStore, cfg.PreviewCacheDir())
	fileService.OnContentChanged(previews.Enqueue)
	web, err := webClient(cfg)
	if err != nil {
		return nil, err
	}

	handler := httpapi.NewRouter(httpapi.Dependencies{
		Auth:                   auth.NewService(userService, sessions, tokens),
		Sessions:               sessions,
		Users:                  userService,
		Files:                  fileService,
		Sync:                   syncService,
		Previews:               previews,
		LoginAttemptsPerMinute: cfg.LoginRateLimit,
		Web:                    web,
	})
	return &App{
		Config:   cfg,
		Handler:  handler,
		Files:    fileService,
		Users:    userStore,
		db:       db,
		scanner:  scanner.New(fileService, userStore, cfg.RescanInterval, cfg.WatchFiles),
		previews: previews,
		sync:     syncService,
	}, nil
}

// webClient picks the browser client to serve: a directory from the config, the one built into
// the binary, or none (API only).
func webClient(cfg config.Config) (http.Handler, error) {
	if !cfg.ServeWeb {
		return nil, nil
	}
	var client fs.FS
	switch {
	case cfg.WebDir != "":
		client = os.DirFS(cfg.WebDir)
		if !webui.HasClient(client) {
			return nil, fmt.Errorf("web client directory %s has no index.html", cfg.WebDir)
		}
	default:
		embedded, ok := webui.Embedded()
		if !ok {
			slog.Info("no web client built into this binary; serving the API only")
			return nil, nil
		}
		client = embedded
	}
	return webui.Handler(client)
}

func (a *App) Close() error {
	return a.db.Close()
}

func (a *App) StartBackgroundWork(ctx context.Context) {
	go a.scanner.Run(ctx)
	go a.previews.Run(ctx)
	go a.removeExpiredUploadsPeriodically(ctx)
}

func (a *App) removeExpiredUploadsPeriodically(ctx context.Context) {
	ticker := time.NewTicker(uploadCleanupInterval)
	defer ticker.Stop()
	for {
		if err := a.sync.RemoveExpiredUploads(ctx); err != nil && ctx.Err() == nil {
			slog.Warn("remove expired uploads", "error", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}
