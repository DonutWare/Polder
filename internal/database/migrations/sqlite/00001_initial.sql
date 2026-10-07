-- +goose Up
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL,
    quota_bytes INTEGER NOT NULL DEFAULT 0,
    disabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at INTEGER NOT NULL,
    trash_retention_days INTEGER NULL,
    trash_retention_override_days INTEGER NULL
);

CREATE TABLE sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    device_name TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    last_used_at INTEGER NOT NULL,
    expires_at INTEGER NOT NULL
);

CREATE TABLE files (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    path_key TEXT NOT NULL,
    parent_key TEXT NOT NULL,
    name TEXT NOT NULL,
    is_dir BOOLEAN NOT NULL,
    size INTEGER NOT NULL,
    mtime_ns INTEGER NOT NULL,
    hash TEXT NOT NULL,
    rev INTEGER NOT NULL,
    mime TEXT NOT NULL,
    meta_json TEXT NOT NULL,
    preview_state TEXT NOT NULL,
    text_state TEXT NOT NULL
);
CREATE UNIQUE INDEX files_user_path ON files(user_id, path_key);
CREATE INDEX files_user_parent ON files(user_id, parent_key);
CREATE INDEX files_preview_state ON files(preview_state);
CREATE INDEX files_text_state ON files(text_state);

CREATE TABLE file_chunks (
    file_id INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    rev INTEGER NOT NULL,
    idx INTEGER NOT NULL,
    hash TEXT NOT NULL,
    offset_bytes INTEGER NOT NULL,
    size INTEGER NOT NULL,
    PRIMARY KEY (file_id, rev, idx)
);

CREATE TABLE changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    path_key TEXT NOT NULL,
    change_type TEXT NOT NULL,
    from_path TEXT,
    created_at INTEGER NOT NULL
);
CREATE INDEX changes_user_id ON changes(user_id, id);

CREATE TABLE uploads (
    id TEXT PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    base_rev INTEGER NOT NULL,
    size INTEGER NOT NULL,
    hash TEXT NOT NULL,
    mtime_ns INTEGER NOT NULL,
    chunks_json TEXT NOT NULL,
    created_at INTEGER NOT NULL
);

CREATE TABLE trash (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    original_path TEXT NOT NULL,
    name TEXT NOT NULL,
    is_dir BOOLEAN NOT NULL,
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

CREATE TABLE activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id INTEGER NULL,
    device TEXT NOT NULL,
    kind TEXT NOT NULL,
    path TEXT NOT NULL,
    from_path TEXT NOT NULL,
    is_dir BOOLEAN NOT NULL,
    size INTEGER NULL,
    bytes INTEGER NULL,
    duration_ms INTEGER NULL,
    item_count INTEGER NULL,
    status TEXT NOT NULL,
    detail TEXT NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE INDEX activity_user ON activity(user_id, id);
CREATE INDEX activity_created ON activity(created_at);

-- +goose Down
DROP TABLE activity;
DROP TABLE server_settings;
DROP TABLE trash;
DROP TABLE uploads;
DROP TABLE changes;
DROP TABLE file_chunks;
DROP TABLE files;
DROP TABLE sessions;
DROP TABLE users;
