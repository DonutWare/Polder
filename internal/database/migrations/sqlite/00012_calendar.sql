-- +goose Up
CREATE TABLE calendars (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    owner_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    uri TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT NOT NULL DEFAULT '',
    color TEXT NOT NULL DEFAULT '',
    timezone TEXT NOT NULL DEFAULT '',
    sort_order INTEGER NOT NULL DEFAULT 0,
    kind TEXT NOT NULL DEFAULT 'local',
    is_default BOOLEAN NOT NULL DEFAULT FALSE,
    sync_revision INTEGER NOT NULL DEFAULT 0,
    pruned_revision INTEGER NOT NULL DEFAULT 0,
    source_url TEXT NOT NULL DEFAULT '',
    refresh_seconds INTEGER NOT NULL DEFAULT 0,
    fetched_at INTEGER NULL,
    fetch_etag TEXT NOT NULL DEFAULT '',
    fetch_last_modified TEXT NOT NULL DEFAULT '',
    fetch_error TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX calendars_owner_uri ON calendars(owner_id, uri);
CREATE INDEX calendars_kind ON calendars(kind);

CREATE TABLE calendar_objects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    calendar_id INTEGER NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    uri TEXT NOT NULL,
    uid TEXT NOT NULL,
    etag TEXT NOT NULL,
    schedule_tag TEXT NOT NULL DEFAULT '',
    component TEXT NOT NULL,
    data TEXT NOT NULL,
    size INTEGER NOT NULL,
    first_start INTEGER NOT NULL,
    last_end INTEGER NULL,
    recurring BOOLEAN NOT NULL DEFAULT FALSE,
    has_alarms BOOLEAN NOT NULL DEFAULT FALSE,
    summary TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX calendar_objects_uri ON calendar_objects(calendar_id, uri);
CREATE UNIQUE INDEX calendar_objects_uid ON calendar_objects(calendar_id, uid);
CREATE INDEX calendar_objects_range ON calendar_objects(calendar_id, first_start, last_end);
CREATE INDEX calendar_objects_alarms ON calendar_objects(has_alarms, first_start);

CREATE TABLE calendar_changes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    calendar_id INTEGER NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    revision INTEGER NOT NULL,
    object_uri TEXT NOT NULL,
    deleted BOOLEAN NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE INDEX calendar_changes_revision ON calendar_changes(calendar_id, revision);
CREATE INDEX calendar_changes_created ON calendar_changes(created_at);

CREATE TABLE calendar_shares (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    calendar_id INTEGER NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    recipient_user_id INTEGER NULL REFERENCES users(id) ON DELETE CASCADE,
    recipient_group_id INTEGER NULL REFERENCES groups(id) ON DELETE CASCADE,
    access TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    CHECK ((recipient_user_id IS NULL) <> (recipient_group_id IS NULL))
);
CREATE UNIQUE INDEX calendar_shares_user ON calendar_shares(calendar_id, recipient_user_id);
CREATE UNIQUE INDEX calendar_shares_group ON calendar_shares(calendar_id, recipient_group_id);
CREATE INDEX calendar_shares_recipient_user ON calendar_shares(recipient_user_id);
CREATE INDEX calendar_shares_recipient_group ON calendar_shares(recipient_group_id);

CREATE TABLE calendar_user_settings (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    calendar_id INTEGER NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    display_name TEXT NOT NULL DEFAULT '',
    color TEXT NOT NULL DEFAULT '',
    hidden BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order INTEGER NULL,
    notify BOOLEAN NULL,
    PRIMARY KEY (user_id, calendar_id)
);

CREATE TABLE calendar_feeds (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    calendar_id INTEGER NOT NULL REFERENCES calendars(id) ON DELETE CASCADE,
    secret_hash TEXT NOT NULL UNIQUE,
    mode TEXT NOT NULL,
    name TEXT NOT NULL DEFAULT '',
    created_at INTEGER NOT NULL,
    last_used_at INTEGER NULL
);
CREATE INDEX calendar_feeds_calendar ON calendar_feeds(calendar_id);

CREATE TABLE calendar_alarm_log (
    object_id INTEGER NOT NULL REFERENCES calendar_objects(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    occurrence_start INTEGER NOT NULL,
    alarm_key TEXT NOT NULL,
    fired_at INTEGER NOT NULL,
    PRIMARY KEY (object_id, user_id, occurrence_start, alarm_key)
);
CREATE INDEX calendar_alarm_log_fired ON calendar_alarm_log(fired_at);

CREATE TABLE calendar_inbox (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    uri TEXT NOT NULL,
    method TEXT NOT NULL,
    uid TEXT NOT NULL,
    sender TEXT NOT NULL,
    summary TEXT NOT NULL DEFAULT '',
    data TEXT NOT NULL,
    etag TEXT NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX calendar_inbox_uri ON calendar_inbox(user_id, uri);
CREATE INDEX calendar_inbox_created ON calendar_inbox(created_at);

-- +goose Down
DROP TABLE calendar_inbox;
DROP TABLE calendar_alarm_log;
DROP TABLE calendar_feeds;
DROP TABLE calendar_user_settings;
DROP TABLE calendar_shares;
DROP TABLE calendar_changes;
DROP TABLE calendar_objects;
DROP TABLE calendars;
