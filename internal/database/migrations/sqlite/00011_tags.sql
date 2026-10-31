-- +goose Up
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    name_key TEXT NOT NULL,
    color TEXT NOT NULL,
    created_at INTEGER NOT NULL
);
CREATE UNIQUE INDEX tags_user_name ON tags(user_id, name_key);

CREATE TABLE file_tags (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    file_id INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, file_id, tag_id)
);
CREATE INDEX file_tags_tag ON file_tags(tag_id);
CREATE INDEX file_tags_file ON file_tags(file_id);

CREATE TABLE note_tags (
    file_id INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    name_key TEXT NOT NULL,
    name TEXT NOT NULL,
    PRIMARY KEY (file_id, name_key)
);
CREATE INDEX note_tags_name ON note_tags(name_key);

CREATE TABLE tag_sources (
    source_id INTEGER NOT NULL PRIMARY KEY REFERENCES files(id) ON DELETE CASCADE,
    hash TEXT NOT NULL
);

-- +goose Down
DROP TABLE tag_sources;
DROP TABLE note_tags;
DROP TABLE file_tags;
DROP TABLE tags;
