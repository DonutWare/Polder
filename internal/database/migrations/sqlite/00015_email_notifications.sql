-- +goose Up
CREATE TABLE password_resets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    code_hash TEXT NOT NULL,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    expires_at INTEGER NOT NULL
);

CREATE TABLE known_sign_ins (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    last_seen INTEGER NOT NULL,
    PRIMARY KEY (user_id, address)
);

ALTER TABLE users ADD COLUMN email_security BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN email_quota BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN email_shares BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE users ADD COLUMN quota_warning_level INTEGER NOT NULL DEFAULT 0;

-- +goose Down
ALTER TABLE users DROP COLUMN quota_warning_level;
ALTER TABLE users DROP COLUMN email_shares;
ALTER TABLE users DROP COLUMN email_quota;
ALTER TABLE users DROP COLUMN email_security;
DROP TABLE known_sign_ins;
DROP TABLE password_resets;
