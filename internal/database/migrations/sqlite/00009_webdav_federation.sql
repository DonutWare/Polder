-- +goose Up
CREATE TABLE app_passwords (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    lookup TEXT NOT NULL UNIQUE,
    token_hash TEXT NOT NULL,
    read_only BOOLEAN NOT NULL DEFAULT FALSE,
    created_at INTEGER NOT NULL,
    last_used_at INTEGER NULL,
    last_used_address TEXT NOT NULL DEFAULT ''
);
CREATE INDEX app_passwords_user ON app_passwords(user_id);

CREATE TABLE federation_servers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    remote TEXT NOT NULL UNIQUE,
    provider TEXT NOT NULL DEFAULT '',
    ocm_endpoint TEXT NOT NULL DEFAULT '',
    webdav_path TEXT NOT NULL DEFAULT '',
    key_id TEXT NOT NULL DEFAULT '',
    public_key_pem TEXT NOT NULL DEFAULT '',
    api_version TEXT NOT NULL DEFAULT '',
    resource_types TEXT NOT NULL DEFAULT '',
    capabilities TEXT NOT NULL DEFAULT '',
    allow_private_network BOOLEAN NOT NULL DEFAULT FALSE,
    verify_sender_address BOOLEAN NOT NULL DEFAULT TRUE,
    added_by INTEGER NULL REFERENCES users(id) ON DELETE SET NULL,
    created_at INTEGER NOT NULL,
    discovered_at INTEGER NULL
);

CREATE TABLE federated_shares_out (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_id INTEGER NOT NULL,
    server_id INTEGER NOT NULL REFERENCES federation_servers(id) ON DELETE CASCADE,
    remote_user TEXT NOT NULL,
    remote_display_name TEXT NOT NULL DEFAULT '',
    secret_hash TEXT NOT NULL UNIQUE,
    secret_sealed TEXT NOT NULL,
    can_create BOOLEAN NOT NULL DEFAULT FALSE,
    can_update BOOLEAN NOT NULL DEFAULT FALSE,
    can_delete BOOLEAN NOT NULL DEFAULT FALSE,
    expires_at INTEGER NULL,
    state TEXT NOT NULL DEFAULT 'pending',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX federated_shares_out_recipient ON federated_shares_out(file_id, server_id, remote_user);
CREATE INDEX federated_shares_out_owner ON federated_shares_out(owner_id);

CREATE TABLE federated_shares_in (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    server_id INTEGER NOT NULL REFERENCES federation_servers(id) ON DELETE CASCADE,
    provider_id TEXT NOT NULL,
    owner_cloud_id TEXT NOT NULL,
    owner_display_name TEXT NOT NULL DEFAULT '',
    sender_cloud_id TEXT NOT NULL,
    sender_display_name TEXT NOT NULL DEFAULT '',
    name TEXT NOT NULL,
    is_dir BOOLEAN NOT NULL DEFAULT TRUE,
    secret_sealed TEXT NOT NULL,
    secret_hash TEXT NOT NULL,
    permissions INTEGER NOT NULL DEFAULT 1,
    webdav_uri TEXT NOT NULL DEFAULT '',
    auth_scheme TEXT NOT NULL DEFAULT '',
    state TEXT NOT NULL DEFAULT 'pending',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX federated_shares_in_remote ON federated_shares_in(server_id, provider_id);
CREATE INDEX federated_shares_in_user ON federated_shares_in(user_id);

CREATE TABLE federation_outbox (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    server_id INTEGER NOT NULL REFERENCES federation_servers(id) ON DELETE CASCADE,
    body_sealed TEXT NOT NULL,
    attempts INTEGER NOT NULL DEFAULT 0,
    next_attempt_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE INDEX federation_outbox_due ON federation_outbox(next_attempt_at);

CREATE TABLE federation_invites (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at INTEGER NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE INDEX federation_invites_user ON federation_invites(user_id);

CREATE TABLE federation_contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    server_id INTEGER NOT NULL REFERENCES federation_servers(id) ON DELETE CASCADE,
    remote_user TEXT NOT NULL,
    name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX federation_contacts_remote ON federation_contacts(user_id, server_id, remote_user);

-- +goose Down
DROP TABLE federation_contacts;
DROP TABLE federation_invites;
DROP TABLE federation_outbox;
DROP TABLE federated_shares_in;
DROP TABLE federated_shares_out;
DROP TABLE federation_servers;
DROP TABLE app_passwords;
