package config

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"gopkg.in/yaml.v3"
)

const (
	DriverSQLite  = "sqlite"
	DriverMariaDB = "mariadb"
)

type Config struct {
	ListenAddress  string        `yaml:"listen"`
	ConfigDir      string        `yaml:"-"`
	DataDir        string        `yaml:"-"`
	DatabaseDriver string        `yaml:"databaseDriver"`
	DatabaseDSN    string        `yaml:"databaseDsn"`
	RescanInterval time.Duration `yaml:"rescanInterval"`
	WatchFiles     bool          `yaml:"watchFiles"`
	LoginRateLimit int           `yaml:"loginAttemptsPerMinute"`
	// WebDir serves the web client from disk instead of the copy built into the binary.
	WebDir string `yaml:"webDir"`
	// ServeWeb turns the bundled web client off when false, leaving only the API.
	ServeWeb bool `yaml:"serveWeb"`
}

func Default() Config {
	return Config{
		ListenAddress:  ":6060",
		ConfigDir:      "/config",
		DataDir:        "/data",
		DatabaseDriver: DriverSQLite,
		RescanInterval: 15 * time.Minute,
		WatchFiles:     true,
		LoginRateLimit: 10,
		ServeWeb:       true,
	}
}

func Load() (Config, error) {
	cfg := Default()
	cfg.ConfigDir = envOr("NOMAD_CONFIG_DIR", cfg.ConfigDir)
	cfg.DataDir = envOr("NOMAD_DATA_DIR", cfg.DataDir)

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
	cfg.ListenAddress = envOr("NOMAD_LISTEN", cfg.ListenAddress)
	cfg.DatabaseDriver = envOr("NOMAD_DB_DRIVER", cfg.DatabaseDriver)
	cfg.DatabaseDSN = envOr("NOMAD_DB_DSN", cfg.DatabaseDSN)
	cfg.WebDir = envOr("NOMAD_WEB_DIR", cfg.WebDir)

	if value, ok := os.LookupEnv("NOMAD_RESCAN_INTERVAL"); ok {
		interval, err := time.ParseDuration(value)
		if err != nil {
			return fmt.Errorf("NOMAD_RESCAN_INTERVAL: %w", err)
		}
		cfg.RescanInterval = interval
	}
	if value, ok := os.LookupEnv("NOMAD_SERVE_WEB"); ok {
		serve, err := strconv.ParseBool(value)
		if err != nil {
			return fmt.Errorf("NOMAD_SERVE_WEB: %w", err)
		}
		cfg.ServeWeb = serve
	}
	if value, ok := os.LookupEnv("NOMAD_WATCH_FILES"); ok {
		watch, err := strconv.ParseBool(value)
		if err != nil {
			return fmt.Errorf("NOMAD_WATCH_FILES: %w", err)
		}
		cfg.WatchFiles = watch
	}
	return nil
}

func (cfg Config) validate() error {
	switch cfg.DatabaseDriver {
	case DriverSQLite:
		return nil
	case DriverMariaDB:
		if cfg.DatabaseDSN == "" {
			return errors.New("NOMAD_DB_DSN is required for the mariadb driver")
		}
		return nil
	default:
		return fmt.Errorf("unknown database driver %q (use %q or %q)", cfg.DatabaseDriver, DriverSQLite, DriverMariaDB)
	}
}

func (cfg Config) SQLitePath() string {
	return filepath.Join(cfg.ConfigDir, "nomad.db")
}

func (cfg Config) PreviewCacheDir() string {
	return filepath.Join(cfg.ConfigDir, "cache", "previews")
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
