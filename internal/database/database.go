package database

import (
	"context"
	"crypto/rand"
	"database/sql"
	"embed"
	"fmt"
	"os"
	"path/filepath"

	_ "github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"
	_ "modernc.org/sqlite"

	"polder-server/internal/config"
)

const idSetting = "database_id"

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
	if cfg.DatabaseDriver == config.DriverPostgres {
		return sql.Open("pgx", cfg.DatabaseDSN)
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

// ID tells files derived from the database, such as the search index, which database they belong to,
// so they are rebuilt rather than trusted after the database is replaced.
func ID(ctx context.Context, db *sql.DB) (string, error) {
	_, err := db.ExecContext(ctx, `INSERT INTO server_settings (name, value) VALUES ($1, $2) ON CONFLICT (name) DO NOTHING`,
		idSetting, rand.Text())
	if err != nil {
		return "", err
	}
	var id string
	err = db.QueryRowContext(ctx, `SELECT value FROM server_settings WHERE name = $1`, idSetting).Scan(&id)
	return id, err
}

func migrate(db *sql.DB, driver string) error {
	goose.SetBaseFS(migrations)
	goose.SetLogger(goose.NopLogger())
	dialect, directory := "sqlite3", "migrations/sqlite"
	if driver == config.DriverPostgres {
		dialect, directory = "postgres", "migrations/postgres"
	}
	if err := goose.SetDialect(dialect); err != nil {
		return err
	}
	if err := goose.Up(db, directory); err != nil {
		return fmt.Errorf("run migrations: %w", err)
	}
	return nil
}
