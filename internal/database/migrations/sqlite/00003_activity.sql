-- +goose Up
CREATE TABLE activity (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id INTEGER NULL,
    device TEXT NOT NULL,
    kind TEXT NOT NULL,
    path TEXT NOT NULL,
    from_path TEXT NOT NULL,
    is_dir INTEGER NOT NULL,
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
