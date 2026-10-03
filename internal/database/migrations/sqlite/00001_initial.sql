-- +goose Up
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL,
    quota_bytes INTEGER NOT NULL DEFAULT 0,
    disabled INTEGER NOT NULL DEFAULT 0,
    created_at INTEGER NOT NULL
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
    is_dir INTEGER NOT NULL,
    size INTEGER NOT NULL,
    mtime_ns INTEGER NOT NULL,
    hash TEXT NOT NULL,
    rev INTEGER NOT NULL,
    mime TEXT NOT NULL,
    meta_json TEXT NOT NULL,
    preview_state TEXT NOT NULL
);
CREATE UNIQUE INDEX files_user_path ON files(user_id, path_key);
CREATE INDEX files_user_parent ON files(user_id, parent_key);
CREATE INDEX files_preview_state ON files(preview_state);

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

-- +goose Down
DROP TABLE uploads;
DROP TABLE changes;
DROP TABLE file_chunks;
DROP TABLE files;
DROP TABLE sessions;
DROP TABLE users;
