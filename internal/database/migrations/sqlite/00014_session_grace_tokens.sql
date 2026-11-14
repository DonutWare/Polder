-- +goose Up
CREATE TABLE session_grace_tokens (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE
);
CREATE INDEX session_grace_tokens_session ON session_grace_tokens(session_id, id);

-- +goose Down
DROP TABLE session_grace_tokens;
