-- +goose Up
CREATE TABLE trash (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    original_path TEXT NOT NULL,
    name TEXT NOT NULL,
    is_dir INTEGER NOT NULL,
    size INTEGER NOT NULL,
    mime TEXT NOT NULL,
    hash TEXT NOT NULL,
    preview_state TEXT NOT NULL,
    storage_id TEXT NOT NULL,
    deleted_at INTEGER NOT NULL
);
CREATE INDEX trash_user_deleted ON trash(user_id, deleted_at);

CREATE TABLE server_settings (
    name TEXT PRIMARY KEY,
    value TEXT NOT NULL
);

ALTER TABLE users ADD COLUMN trash_retention_days INTEGER NULL;
ALTER TABLE users ADD COLUMN trash_retention_override_days INTEGER NULL;

-- +goose Down
ALTER TABLE users DROP COLUMN trash_retention_override_days;
ALTER TABLE users DROP COLUMN trash_retention_days;
DROP TABLE server_settings;
DROP TABLE trash;
