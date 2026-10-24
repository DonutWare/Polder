package database

import (
	"context"
	"database/sql"
	"strings"
)

type RowScanner interface {
	Scan(dest ...any) error
}

func IsUniqueViolation(err error) bool {
	if err == nil {
		return false
	}
	message := strings.ToLower(err.Error())
	return strings.Contains(message, "unique") || strings.Contains(message, "duplicate")
}

func RequireAffected(missing error) func(sql.Result, error) error {
	return func(result sql.Result, err error) error {
		if err != nil {
			return err
		}
		affected, err := result.RowsAffected()
		if err != nil {
			return err
		}
		if affected == 0 {
			return missing
		}
		return nil
	}
}

func QueryAll[T any](ctx context.Context, db *sql.DB, scan func(RowScanner) (T, error), query string, args ...any) ([]T, error) {
	rows, err := db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	list := []T{}
	for rows.Next() {
		item, err := scan(rows)
		if err != nil {
			return nil, err
		}
		list = append(list, item)
	}
	return list, rows.Err()
}

func ScanInt64(row RowScanner) (int64, error) {
	var value int64
	err := row.Scan(&value)
	return value, err
}

func NullIfZero(value int64) any {
	if value == 0 {
		return nil
	}
	return value
}

func NullIfNil[T any](value *T) any {
	if value == nil {
		return nil
	}
	return *value
}
