-- +goose Up
CREATE TABLE user_totp (
    user_id INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    secret_sealed TEXT NOT NULL,
    confirmed_at INTEGER NULL,
    last_used_step INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE user_recovery_codes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    code_hash TEXT NOT NULL,
    used_at INTEGER NULL
);
CREATE INDEX user_recovery_codes_user ON user_recovery_codes (user_id);

ALTER TABLE users ADD COLUMN two_factor_deadline INTEGER NULL;
ALTER TABLE users ADD COLUMN two_factor_reminder_level INTEGER NOT NULL DEFAULT 0;
ALTER TABLE sessions ADD COLUMN auth_method TEXT NOT NULL DEFAULT 'password';
ALTER TABLE sessions ADD COLUMN authenticated_at INTEGER NOT NULL DEFAULT 0;

CREATE TABLE auth_providers (
    id TEXT PRIMARY KEY,
    kind TEXT NOT NULL,
    preset TEXT NOT NULL,
    label TEXT NOT NULL,
    issuer TEXT NOT NULL DEFAULT '',
    client_id TEXT NOT NULL,
    client_secret_sealed TEXT NOT NULL DEFAULT '',
    scopes TEXT NOT NULL DEFAULT '',
    username_claim TEXT NOT NULL DEFAULT '',
    allow_signup BOOLEAN NOT NULL DEFAULT FALSE,
    link_by_email BOOLEAN NOT NULL DEFAULT TRUE,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    position INTEGER NOT NULL DEFAULT 0,
    managed_by_config BOOLEAN NOT NULL DEFAULT FALSE,
    created_at INTEGER NOT NULL
);

CREATE TABLE user_identities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    provider_id TEXT NOT NULL REFERENCES auth_providers(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    email TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    UNIQUE (provider_id, subject),
    UNIQUE (provider_id, user_id)
);
CREATE INDEX user_identities_user ON user_identities (user_id);

CREATE TABLE sso_logins (
    state_hash TEXT PRIMARY KEY,
    provider_id TEXT NOT NULL REFERENCES auth_providers(id) ON DELETE CASCADE,
    nonce TEXT NOT NULL,
    idp_verifier TEXT NOT NULL,
    app_redirect TEXT NOT NULL,
    app_challenge TEXT NOT NULL,
    device_name TEXT NOT NULL DEFAULT '',
    link_user_id INTEGER NULL REFERENCES users(id) ON DELETE CASCADE,
    code_hash TEXT NULL UNIQUE,
    user_id INTEGER NULL REFERENCES users(id) ON DELETE CASCADE,
    link_subject TEXT NOT NULL DEFAULT '',
    link_email TEXT NOT NULL DEFAULT '',
    expires_at INTEGER NOT NULL
);

-- +goose Down
DROP TABLE sso_logins;
DROP TABLE user_identities;
DROP TABLE auth_providers;
ALTER TABLE sessions DROP COLUMN authenticated_at;
ALTER TABLE sessions DROP COLUMN auth_method;
ALTER TABLE users DROP COLUMN two_factor_reminder_level;
ALTER TABLE users DROP COLUMN two_factor_deadline;
DROP TABLE user_recovery_codes;
DROP TABLE user_totp;
