package config

import (
	"errors"
	"fmt"
	"net"
	"net/netip"
	"net/url"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"unicode"

	"gopkg.in/yaml.v3"
)

const (
	DriverSQLite   = "sqlite"
	DriverPostgres = "postgres"
)

type Config struct {
	ListenAddress  string        `yaml:"listen"`
	ConfigDir      string        `yaml:"-"`
	DataDir        string        `yaml:"-"`
	CacheDir       string        `yaml:"-"`
	DatabaseDriver string        `yaml:"databaseDriver"`
	DatabaseDSN    string        `yaml:"databaseDsn"`
	RescanInterval time.Duration `yaml:"rescanInterval"`
	WatchFiles     bool          `yaml:"watchFiles"`
	LoginRateLimit int           `yaml:"loginAttemptsPerMinute"`
	// TrashRetentionDays is the default until an administrator changes it in the app; 0 keeps the trash forever.
	TrashRetentionDays int `yaml:"trashRetentionDays"`
	LogRetentionDays   int `yaml:"logRetentionDays"`
	// WebDir serves the web client from disk instead of the copy built into the binary.
	WebDir string `yaml:"webDir"`
	// ServeWeb turns the bundled web client off when false, leaving only the API.
	ServeWeb bool `yaml:"serveWeb"`
	// TesseractPath is the OCR program, looked up on PATH unless it is a path. Without it there is no OCR.
	TesseractPath string `yaml:"tesseractPath"`
	// OCRModelURL is where OCR models are downloaded from, as <OCRModelURL>/<model>.traineddata.
	OCRModelURL string `yaml:"ocrModelUrl"`
	// TrustedProxies are the addresses or ranges of reverse proxies whose X-Forwarded-For and
	// X-Real-IP headers name the client. Requests from anywhere else are taken at their address.
	TrustedProxies []string `yaml:"trustedProxies"`
	// CollaboraURL is where Collabora Online listens, as seen from this server. Without it there is no document editor.
	CollaboraURL string `yaml:"collaboraUrl"`
	// WOPIURL is where Collabora reaches this server; it defaults to the listen address on localhost.
	WOPIURL string `yaml:"wopiUrl"`
}

func Default() Config {
	return Config{
		ListenAddress:      ":6060",
		ConfigDir:          "/config",
		DataDir:            "/data",
		DatabaseDriver:     DriverSQLite,
		RescanInterval:     15 * time.Minute,
		WatchFiles:         true,
		LoginRateLimit:     10,
		TrashRetentionDays: 30,
		LogRetentionDays:   14,
		ServeWeb:           true,
		TesseractPath:      "tesseract",
		OCRModelURL:        "https://github.com/tesseract-ocr/tessdata_fast/raw/main",
	}
}

func Load() (Config, error) {
	cfg := Default()
	cfg.ConfigDir = envOr("POLDER_CONFIG_DIR", cfg.ConfigDir)
	cfg.DataDir = envOr("POLDER_DATA_DIR", cfg.DataDir)
	cfg.CacheDir = envOr("POLDER_CACHE_DIR", cfg.CacheDir)

	if err := cfg.mergeFile(filepath.Join(cfg.ConfigDir, "config.yaml")); err != nil {
		return Config{}, err
	}
	if err := cfg.mergeEnvironment(); err != nil {
		return Config{}, err
	}
	return cfg, cfg.validate()
}

func (cfg *Config) mergeFile(path string) error {
	content, err := os.ReadFile(path)
	if errors.Is(err, os.ErrNotExist) {
		return nil
	}
	if err != nil {
		return fmt.Errorf("read config file: %w", err)
	}
	if err := yaml.Unmarshal(content, cfg); err != nil {
		return fmt.Errorf("parse config file %s: %w", path, err)
	}
	return nil
}

func (cfg *Config) mergeEnvironment() error {
	cfg.ListenAddress = envOr("POLDER_LISTEN", cfg.ListenAddress)
	cfg.DatabaseDriver = envOr("POLDER_DB_DRIVER", cfg.DatabaseDriver)
	cfg.DatabaseDSN = envOr("POLDER_DB_DSN", cfg.DatabaseDSN)
	cfg.WebDir = envOr("POLDER_WEB_DIR", cfg.WebDir)
	cfg.TesseractPath = envOr("POLDER_TESSERACT", cfg.TesseractPath)
	cfg.OCRModelURL = envOr("POLDER_OCR_MODEL_URL", cfg.OCRModelURL)
	cfg.CollaboraURL = envOr("POLDER_COLLABORA_URL", cfg.CollaboraURL)
	cfg.WOPIURL = envOr("POLDER_WOPI_URL", cfg.WOPIURL)
	if value, ok := os.LookupEnv("POLDER_TRUSTED_PROXIES"); ok {
		cfg.TrustedProxies = strings.FieldsFunc(value, func(r rune) bool { return r == ',' || unicode.IsSpace(r) })
	}

	if value, ok := os.LookupEnv("POLDER_RESCAN_INTERVAL"); ok {
		interval, err := time.ParseDuration(value)
		if err != nil {
			return fmt.Errorf("POLDER_RESCAN_INTERVAL: %w", err)
		}
		cfg.RescanInterval = interval
	}
	if value, ok := os.LookupEnv("POLDER_TRASH_RETENTION_DAYS"); ok {
		days, err := strconv.Atoi(value)
		if err != nil {
			return fmt.Errorf("POLDER_TRASH_RETENTION_DAYS: %w", err)
		}
		cfg.TrashRetentionDays = days
	}
	if value, ok := os.LookupEnv("POLDER_LOG_RETENTION_DAYS"); ok {
		days, err := strconv.Atoi(value)
		if err != nil {
			return fmt.Errorf("POLDER_LOG_RETENTION_DAYS: %w", err)
		}
		cfg.LogRetentionDays = days
	}
	if value, ok := os.LookupEnv("POLDER_SERVE_WEB"); ok {
		serve, err := strconv.ParseBool(value)
		if err != nil {
			return fmt.Errorf("POLDER_SERVE_WEB: %w", err)
		}
		cfg.ServeWeb = serve
	}
	if value, ok := os.LookupEnv("POLDER_WATCH_FILES"); ok {
		watch, err := strconv.ParseBool(value)
		if err != nil {
			return fmt.Errorf("POLDER_WATCH_FILES: %w", err)
		}
		cfg.WatchFiles = watch
	}
	return nil
}

func (cfg Config) validate() error {
	if cfg.TrashRetentionDays < 0 {
		return errors.New("trashRetentionDays cannot be negative")
	}
	if cfg.LogRetentionDays < 1 {
		return errors.New("logRetentionDays must be at least 1")
	}
	if _, err := cfg.TrustedProxyRanges(); err != nil {
		return err
	}
	for name, value := range map[string]string{"collaboraUrl": cfg.CollaboraURL, "wopiUrl": cfg.WOPIURL} {
		if value == "" {
			continue
		}
		if parsed, err := url.Parse(value); err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") || parsed.Host == "" {
			return fmt.Errorf("%s: %q is not an http(s) URL", name, value)
		}
	}
	switch cfg.DatabaseDriver {
	case DriverSQLite:
		return nil
	case DriverPostgres:
		if cfg.DatabaseDSN == "" {
			return errors.New("POLDER_DB_DSN is required for the postgres driver")
		}
		return nil
	default:
		return fmt.Errorf("unknown database driver %q (use %q or %q)", cfg.DatabaseDriver, DriverSQLite, DriverPostgres)
	}
}

func (cfg Config) TrustedProxyRanges() ([]netip.Prefix, error) {
	ranges := make([]netip.Prefix, 0, len(cfg.TrustedProxies))
	for _, proxy := range cfg.TrustedProxies {
		if address, err := netip.ParseAddr(proxy); err == nil {
			ranges = append(ranges, netip.PrefixFrom(address.Unmap(), address.Unmap().BitLen()))
			continue
		}
		prefix, err := netip.ParsePrefix(proxy)
		if err != nil {
			return nil, fmt.Errorf("trustedProxies: %q is not an address or range", proxy)
		}
		ranges = append(ranges, prefix.Masked())
	}
	return ranges, nil
}

func (cfg Config) WOPIBaseURL() string {
	if cfg.WOPIURL != "" {
		return strings.TrimSuffix(cfg.WOPIURL, "/")
	}
	host, port, err := net.SplitHostPort(cfg.ListenAddress)
	if err != nil || host == "" || host == "0.0.0.0" || host == "::" {
		host = "localhost"
	}
	return "http://" + net.JoinHostPort(host, port)
}

func (cfg Config) SQLitePath() string {
	return filepath.Join(cfg.ConfigDir, "polder.db")
}

// The cache directory holds only what can be rebuilt from the data directory and the database, so it is safe to delete.
func (cfg Config) cacheDir() string {
	if cfg.CacheDir != "" {
		return cfg.CacheDir
	}
	return filepath.Join(cfg.ConfigDir, "cache")
}

func (cfg Config) PreviewCacheDir() string {
	return filepath.Join(cfg.cacheDir(), "previews")
}

func (cfg Config) SearchIndexDir() string {
	return filepath.Join(cfg.cacheDir(), "search-index")
}

func (cfg Config) SearchTextDir() string {
	return filepath.Join(cfg.cacheDir(), "text")
}

func (cfg Config) OCRModelDir() string {
	return filepath.Join(cfg.cacheDir(), "tessdata")
}

func (cfg Config) LogDir() string {
	return filepath.Join(cfg.ConfigDir, "logs")
}

func (cfg Config) BrandingDir() string {
	return filepath.Join(cfg.ConfigDir, "branding")
}

func (cfg Config) JWTKeyPath() string {
	return filepath.Join(cfg.ConfigDir, "jwt.key")
}

func envOr(name, fallback string) string {
	if value, ok := os.LookupEnv(name); ok && value != "" {
		return value
	}
	return fallback
}
