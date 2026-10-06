package app

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"io/fs"
	"log/slog"
	"net/http"
	"os"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/auth"
	"polder-server/internal/config"
	"polder-server/internal/database"
	"polder-server/internal/files"
	"polder-server/internal/httpapi"
	"polder-server/internal/preview"
	"polder-server/internal/scanner"
	"polder-server/internal/search"
	"polder-server/internal/settings"
	"polder-server/internal/storage"
	"polder-server/internal/syncing"
	"polder-server/internal/users"
	"polder-server/internal/webui"
)

const (
	uploadCleanupInterval = time.Hour
	trashPurgeInterval    = time.Hour
	activityPurgeInterval = time.Hour
)

type App struct {
	Config   config.Config
	Handler  http.Handler
	Files    *files.Service
	Users    *users.Store
	Settings *settings.Store
	Activity *activity.Hub
	Search   *search.Service
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
	serverSettings := settings.NewStore(db, settings.ServerSettings{TrashRetentionDays: cfg.TrashRetentionDays})
	fileService := files.NewService(db, disk)
	syncService := syncing.NewService(db, fileService)
	previews := preview.NewWorker(fileService, userStore, cfg.PreviewCacheDir())
	fileService.OnContentChanged(previews.Enqueue)
	fileService.OnContentRemoved(previews.RequestCleanup)
	activityHub := activity.NewHub(activity.NewStore(db))
	fileService.OnMutation(activityHub.FileMutation)
	searchService, err := search.Open(cfg.SearchIndexDir(), fileService, userStore)
	if err != nil {
		return nil, err
	}
	fileService.OnMutation(searchService.FileMutation)
	authService := auth.NewService(userService, sessions, tokens)
	authService.OnSession(func(ctx context.Context, user users.User, session auth.Session, event auth.SessionEvent) {
		activityHub.Session(ctx, user, session.ID, session.DeviceName, event == auth.SessionStarted)
	})
	web, err := webClient(cfg)
	if err != nil {
		searchService.Close()
		return nil, err
	}

	handler := httpapi.NewRouter(httpapi.Dependencies{
		Auth:                   authService,
		Sessions:               sessions,
		Users:                  userService,
		Files:                  fileService,
		Settings:               serverSettings,
		Sync:                   syncService,
		Previews:               previews,
		Activity:               activityHub,
		Search:                 searchService,
		LoginAttemptsPerMinute: cfg.LoginRateLimit,
		Web:                    web,
	})
	return &App{
		Config:   cfg,
		Handler:  handler,
		Files:    fileService,
		Users:    userStore,
		Settings: serverSettings,
		Activity: activityHub,
		Search:   searchService,
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
	return errors.Join(a.Search.Close(), a.db.Close())
}

func (a *App) StartBackgroundWork(ctx context.Context) {
	go a.scanner.Run(ctx)
	go a.previews.Run(ctx)
	go a.Search.Run(ctx)
	go repeat(ctx, uploadCleanupInterval, "remove expired uploads", a.sync.RemoveExpiredUploads)
	go repeat(ctx, trashPurgeInterval, "purge expired trash", func(ctx context.Context) error {
		return a.PurgeExpiredTrash(ctx, time.Now())
	})
	go a.Activity.Run(ctx)
	go repeat(ctx, activityPurgeInterval, "purge old activity", func(ctx context.Context) error {
		_, err := a.Activity.Store().PurgeOlderThan(ctx, time.Now().Add(-activity.Retention))
		return err
	})
}

func repeat(ctx context.Context, interval time.Duration, task string, work func(context.Context) error) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		if err := work(ctx); err != nil && ctx.Err() == nil {
			slog.Warn(task, "error", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}

func (a *App) PurgeExpiredTrash(ctx context.Context, now time.Time) error {
	server, err := a.Settings.Get(ctx)
	if err != nil {
		return err
	}
	allUsers, err := a.Users.List(ctx)
	if err != nil {
		return err
	}
	var failures []error
	for _, user := range allUsers {
		cutoff, expires := settings.ResolveTrashRetention(server, user).Cutoff(now)
		if !expires {
			continue
		}
		purged, err := a.Files.PurgeTrash(ctx, user, cutoff)
		if err != nil {
			failures = append(failures, err)
		}
		if purged > 0 {
			slog.Info("purged expired trash", "user", user.Username, "items", purged)
		}
	}
	return errors.Join(failures...)
}
