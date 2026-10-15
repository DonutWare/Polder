-- +goose Up
DROP TABLE uploads;

CREATE TABLE upload_batches (
    id TEXT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at BIGINT NOT NULL
);
CREATE INDEX upload_batches_user ON upload_batches(user_id);

CREATE TABLE upload_batch_files (
    batch_id TEXT NOT NULL REFERENCES upload_batches(id) ON DELETE CASCADE,
    idx INTEGER NOT NULL,
    request_json TEXT NOT NULL,
    result_json TEXT NULL,
    PRIMARY KEY (batch_id, idx)
);

-- +goose Down
DROP TABLE upload_batch_files;
DROP TABLE upload_batches;

CREATE TABLE uploads (
    id TEXT PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    path TEXT NOT NULL,
    base_rev BIGINT NOT NULL,
    size BIGINT NOT NULL,
    hash TEXT NOT NULL,
    mtime_ns BIGINT NOT NULL,
    chunks_json TEXT NOT NULL,
    created_at BIGINT NOT NULL
);
CREATE INDEX uploads_user ON uploads(user_id);
