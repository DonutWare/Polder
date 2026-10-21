package app

import (
	"context"
	"crypto/x509"
	"database/sql"
	"errors"
	"fmt"
	"io/fs"
	"net/http"
	"os"
	"sync"
	"time"

	"polder-server/internal/activity"
	"polder-server/internal/auth"
	"polder-server/internal/config"
	"polder-server/internal/database"
	"polder-server/internal/extract"
	"polder-server/internal/federation"
	"polder-server/internal/files"
	"polder-server/internal/groups"
	"polder-server/internal/httpapi"
	"polder-server/internal/links"
	"polder-server/internal/logging"
	"polder-server/internal/office"
	"polder-server/internal/preview"
	"polder-server/internal/scanner"
	"polder-server/internal/search"
	"polder-server/internal/settings"
	"polder-server/internal/sharing"
	"polder-server/internal/storage"
	"polder-server/internal/syncing"
	"polder-server/internal/users"
	"polder-server/internal/versions"
	"polder-server/internal/webdav"
	"polder-server/internal/webui"
)

var logger = logging.For("app")

const (
	uploadCleanupInterval = time.Hour
	trashPurgeInterval    = time.Hour
	activityPurgeInterval = time.Hour
	logPurgeInterval      = 24 * time.Hour

	attachmentCleanupInterval = 24 * time.Hour
)

type App struct {
	Config    config.Config
	Handler   http.Handler
	Files     *files.Service
	Users     *users.Store
	Settings  *settings.Store
	Activity  *activity.Hub
	Search    *search.Service
	Logs      *logging.Files
	db        *sql.DB
	scanner   *scanner.Scanner
	previews  *preview.Worker
	extractor *extract.Worker
	sync      *syncing.Service
	versions  *versions.Worker
	links     *links.Graph

	federation         *federation.Service
	trashPurgeRequests chan struct{}
	background         sync.WaitGroup
}

var federationRootCAs *x509.CertPool

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
	images, err := settings.OpenImages(cfg.BrandingDir())
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
	serverSettings := settings.NewStore(db, settings.ServerSettings{
		TrashEnabled:         true,
		TrashRetentionDays:   cfg.TrashRetentionDays,
		SearchContentEnabled: true,
		OCREnabled:           true,
		OCRLanguages:         extract.DefaultOCRLanguages,
		OCRMaxPages:          extract.DefaultOCRMaxPages,
		VersionsEnabled:      true,
		VersionsKeepAllHours: settings.DefaultVersionKeepAllHours,
		VersionsMaxAgeDays:   settings.DefaultVersionMaxAgeDays,
		VersionsMaxPerFile:   settings.DefaultVersionMaxPerFile,
	})
	fileService := files.NewService(db, disk)
	fileService.SetTrashPolicy(func(ctx context.Context, owner users.User) bool {
		server, err := serverSettings.Get(ctx)
		if err != nil {
			logger.Warn("load trash settings", "user", owner.Username, "error", err)
			return true
		}
		return settings.ResolveTrashRetention(server, owner).Enabled
	})
	trashPurgeRequests := make(chan struct{}, 1)
	syncService := syncing.NewService(db, fileService)
	versionWorker := versions.NewWorker(fileService, userStore, serverSettings)
	activityHub := activity.NewHub(activity.NewStore(db))
	fileService.OnMutation(activityHub.FileMutation)
	extractor, err := extract.NewWorker(fileService, userStore, serverSettings, extract.Options{
		CacheDir:      cfg.SearchTextDir(),
		ModelDir:      cfg.OCRModelDir(),
		TesseractPath: cfg.TesseractPath,
		ModelURL:      cfg.OCRModelURL,
	})
	if err != nil {
		return nil, err
	}
	fileService.OnContentChanged(extractor.Enqueue)
	fileService.OnContentRemoved(extractor.RequestCleanup)
	databaseID, err := database.ID(context.Background(), db)
	if err != nil {
		return nil, err
	}
	searchService, err := search.Open(cfg.SearchIndexDir(), databaseID, fileService, userStore, serverSettings, extractor.Cache())
	if err != nil {
		return nil, err
	}
	fileService.OnMutation(searchService.FileMutation)
	extractor.OnExtracted(searchService.IndexText)
	fileScanner := scanner.New(fileService, userStore, cfg.RescanInterval, cfg.WatchFiles)
	userService.OnCreated(func(user users.User) { fileScanner.Request(user.Username) })
	authService := auth.NewService(userService, sessions, auth.NewAppPasswords(db), tokens)
	authService.OnSession(func(ctx context.Context, user users.User, session auth.Session, event auth.SessionEvent) {
		activityHub.Session(ctx, user, session.ID, session.DeviceName, event == auth.SessionStarted)
	})
	web, err := webClient(cfg)
	if err != nil {
		searchService.Close()
		return nil, err
	}

	trustedProxies, err := cfg.TrustedProxyRanges()
	if err != nil {
		searchService.Close()
		return nil, err
	}
	officeService, err := office.New(office.Options{
		CollaboraURL:  cfg.CollaboraURL,
		EuroOfficeURL: cfg.EuroOfficeURL,
		WOPIBaseURL:   cfg.WOPIBaseURL(),
	}, fileService, authService, tokens)
	if err != nil {
		searchService.Close()
		return nil, err
	}
	previews := preview.NewWorker(fileService, userStore, cfg.PreviewCacheDir(), preview.FFmpegOptions{
		Path:          cfg.FFmpegPath,
		HWAccel:       cfg.VideoHWAccel,
		HWAccelDevice: cfg.VideoHWAccelDevice,
	}, officeService)
	fileService.OnContentChanged(previews.Enqueue)
	linkGraph := links.NewGraph(db, fileService, userStore, links.Markdown{})
	fileService.OnContentChanged(linkGraph.Enqueue)
	fileService.OnMutation(linkGraph.FileMutation)
	fileService.OnContentRemoved(previews.RequestCleanup)
	logs := logging.NewFiles(cfg.LogDir())
	groupService := groups.NewService(groups.NewStore(db), userStore)
	sharingService := sharing.NewService(db, fileService, userStore, groupService, auth.Argon2Hasher{}, tokens.DerivedKey(sharing.LinkKeyPurpose))
	fileService.OnMutation(sharingService.FileMutation)
	federationService, err := federation.New(db, fileService, userStore, serverSettings, federation.Options{
		PublicURL: cfg.PublicBaseURL(),
		KeyPath:   cfg.FederationKeyPath(),
		SecretKey: tokens.DerivedKey(federation.SecretKeyPurpose),
		RootCAs:   federationRootCAs,
	})
	if err != nil {
		searchService.Close()
		return nil, err
	}
	fileService.OnMutation(federationService.FileMutation)
	handler := httpapi.NewRouter(httpapi.Dependencies{
		Auth:                   authService,
		Sessions:               sessions,
		Users:                  userService,
		Files:                  fileService,
		Settings:               serverSettings,
		Images:                 images,
		Avatars:                settings.NewAvatars(cfg.AvatarDir()),
		Sync:                   syncService,
		Previews:               previews,
		Activity:               activityHub,
		Search:                 searchService,
		Extractor:              extractor,
		Logs:                   logs,
		Office:                 officeService,
		Versions:               versionWorker,
		Links:                  linkGraph,
		Groups:                 groupService,
		Sharing:                sharingService,
		WebDAV:                 webdav.NewHandler(fileService),
		Federation:             federationService,
		WebDAVAllowInsecure:    cfg.WebDAVAllowInsecure,
		RequestTrashPurge:      func() { requestWork(trashPurgeRequests) },
		LoginAttemptsPerMinute: cfg.LoginRateLimit,
		TrustedProxies:         trustedProxies,
		Web:                    web,
	})
	return &App{
		Config:    cfg,
		Handler:   handler,
		Files:     fileService,
		Users:     userStore,
		Settings:  serverSettings,
		Activity:  activityHub,
		Search:    searchService,
		Logs:      logs,
		db:        db,
		scanner:   fileScanner,
		previews:  previews,
		extractor: extractor,
		sync:      syncService,
		versions:  versionWorker,
		links:     linkGraph,

		federation:         federationService,
		trashPurgeRequests: trashPurgeRequests,
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
			logger.Info("no web client built into this binary; serving the API only")
			return nil, nil
		}
		client = embedded
	}
	return webui.Handler(client)
}

func (a *App) Close() error {
	a.background.Wait()
	return errors.Join(a.Search.Close(), a.db.Close())
}

func (a *App) StartBackgroundWork(ctx context.Context) {
	a.background.Go(func() { a.scanner.Run(ctx) })
	a.background.Go(func() { a.previews.Run(ctx) })
	a.background.Go(func() { a.extractor.Run(ctx) })
	a.background.Go(func() { a.Search.Run(ctx) })
	a.background.Go(func() { a.versions.Run(ctx) })
	a.background.Go(func() { a.links.Run(ctx) })
	a.background.Go(func() { a.federation.Run(ctx) })
	a.background.Go(func() { repeat(ctx, uploadCleanupInterval, "remove expired uploads", a.sync.RemoveExpiredUploads) })
	a.background.Go(func() {
		repeatOnRequest(ctx, trashPurgeInterval, a.trashPurgeRequests, "purge expired trash", func(ctx context.Context) error {
			return a.PurgeExpiredTrash(ctx, time.Now())
		})
	})
	a.background.Go(func() {
		repeat(ctx, attachmentCleanupInterval, "trash attachments no note links to", func(ctx context.Context) error {
			return a.TrashUnlinkedAttachments(ctx, time.Now())
		})
	})
	a.background.Go(func() { a.Activity.Run(ctx) })
	a.background.Go(func() {
		repeat(ctx, activityPurgeInterval, "purge old activity", func(ctx context.Context) error {
			_, err := a.Activity.Store().PurgeOlderThan(ctx, time.Now().Add(-activity.Retention))
			return err
		})
	})
	a.background.Go(func() {
		repeat(ctx, logPurgeInterval, "purge old logs", func(context.Context) error {
			removed, err := a.Logs.PurgeOlderThan(time.Now().AddDate(0, 0, 1-a.Config.LogRetentionDays))
			if removed > 0 {
				logger.Info("purged old log files", "files", removed)
			}
			return err
		})
	})
}

func repeat(ctx context.Context, interval time.Duration, task string, work func(context.Context) error) {
	repeatOnRequest(ctx, interval, nil, task, work)
}

func repeatOnRequest(ctx context.Context, interval time.Duration, requests <-chan struct{}, task string, work func(context.Context) error) {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		if err := work(ctx); err != nil && ctx.Err() == nil {
			logger.Warn(task, "error", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		case <-requests:
		}
	}
}

func requestWork(requests chan<- struct{}) {
	select {
	case requests <- struct{}{}:
	default:
	}
}

func (a *App) TrashUnlinkedAttachments(ctx context.Context, now time.Time) error {
	allUsers, err := a.Users.List(ctx)
	if err != nil {
		return err
	}
	var failures []error
	for _, user := range allUsers {
		trashed, err := a.links.TrashUnlinkedAttachments(ctx, user, now)
		if err != nil {
			failures = append(failures, err)
		}
		if trashed > 0 {
			logger.Info("moved attachments no note links to into the trash", "user", user.Username, "files", trashed)
		}
	}
	return errors.Join(failures...)
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
			logger.Info("purged expired trash", "user", user.Username, "items", purged)
		}
	}
	return errors.Join(failures...)
}
