package database

import (
	"database/sql"
	"embed"
	"fmt"
	"os"
	"path/filepath"

	"github.com/go-sql-driver/mysql"
	"github.com/pressly/goose/v3"
	_ "modernc.org/sqlite"

	"nomad-server/internal/config"
)

//go:embed migrations
var migrations embed.FS

func Open(cfg config.Config) (*sql.DB, error) {
	db, err := openDriver(cfg)
	if err != nil {
		return nil, err
	}
	if err := db.Ping(); err != nil {
		db.Close()
		return nil, fmt.Errorf("connect to %s: %w", cfg.DatabaseDriver, err)
	}
	if err := migrate(db, cfg.DatabaseDriver); err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}

func openDriver(cfg config.Config) (*sql.DB, error) {
	if cfg.DatabaseDriver == config.DriverMariaDB {
		return openMariaDB(cfg.DatabaseDSN)
	}
	if err := os.MkdirAll(filepath.Dir(cfg.SQLitePath()), 0o750); err != nil {
		return nil, fmt.Errorf("create config dir: %w", err)
	}
	dsn := "file:" + cfg.SQLitePath() + "?_pragma=foreign_keys(1)&_pragma=journal_mode(WAL)&_pragma=busy_timeout(10000)&_pragma=synchronous(NORMAL)"
	db, err := sql.Open("sqlite", dsn)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	return db, nil
}

func openMariaDB(dsn string) (*sql.DB, error) {
	mariaConfig, err := mysql.ParseDSN(dsn)
	if err != nil {
		return nil, fmt.Errorf("parse NOMAD_DB_DSN: %w", err)
	}
	if mariaConfig.Params == nil {
		mariaConfig.Params = map[string]string{}
	}
	mariaConfig.Params["transaction_isolation"] = "'READ-COMMITTED'"
	return sql.Open("mysql", mariaConfig.FormatDSN())
}

func migrate(db *sql.DB, driver string) error {
	goose.SetBaseFS(migrations)
	goose.SetLogger(goose.NopLogger())
	dialect, directory := "sqlite3", "migrations/sqlite"
	if driver == config.DriverMariaDB {
		dialect, directory = "mysql", "migrations/mysql"
	}
	if err := goose.SetDialect(dialect); err != nil {
		return err
	}
	if err := goose.Up(db, directory); err != nil {
		return fmt.Errorf("run migrations: %w", err)
	}
	return nil
}
