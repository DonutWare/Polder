-- +goose Up
CREATE TABLE groups (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_by INTEGER NULL REFERENCES users(id) ON DELETE SET NULL,
    created_at INTEGER NOT NULL
);

CREATE TABLE group_members (
    group_id INTEGER NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member',
    added_at INTEGER NOT NULL,
    PRIMARY KEY (group_id, user_id)
);
CREATE INDEX group_members_user ON group_members(user_id);

CREATE TABLE shares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_id INTEGER NOT NULL,
    recipient_user_id INTEGER NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_group_id INTEGER NULL REFERENCES groups(id) ON DELETE CASCADE,
    can_create BOOLEAN NOT NULL DEFAULT FALSE,
    can_update BOOLEAN NOT NULL DEFAULT FALSE,
    can_delete BOOLEAN NOT NULL DEFAULT FALSE,
    expires_at INTEGER NULL,
    note TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    CHECK ((recipient_user_id IS NULL) <> (recipient_group_id IS NULL))
);
CREATE UNIQUE INDEX shares_file_user ON shares(file_id, recipient_user_id);
CREATE UNIQUE INDEX shares_file_group ON shares(file_id, recipient_group_id);
CREATE INDEX shares_owner ON shares(owner_id);
CREATE INDEX shares_recipient_user ON shares(recipient_user_id);
CREATE INDEX shares_recipient_group ON shares(recipient_group_id);

CREATE TABLE share_links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    code TEXT NOT NULL UNIQUE,
    owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_id INTEGER NOT NULL,
    allow_view BOOLEAN NOT NULL,
    allow_download BOOLEAN NOT NULL,
    allow_upload BOOLEAN NOT NULL,
    password_hash TEXT NULL,
    expires_at INTEGER NULL,
    generation INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE INDEX share_links_owner_file ON share_links(owner_id, file_id);

ALTER TABLE activity ADD COLUMN via TEXT NOT NULL DEFAULT '';

-- +goose Down
ALTER TABLE activity DROP COLUMN via;
DROP TABLE share_links;
DROP TABLE shares;
DROP TABLE group_members;
DROP TABLE groups;
