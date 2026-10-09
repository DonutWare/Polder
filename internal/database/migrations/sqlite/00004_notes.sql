-- +goose Up
ALTER TABLE users ADD COLUMN notes_path TEXT NULL;

UPDATE files SET mime = 'text/markdown', preview_state = 'pending'
WHERE is_dir = 0 AND (LOWER(name) LIKE '%.md' OR LOWER(name) LIKE '%.markdown');

CREATE TABLE file_links (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    source_id INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    kind TEXT NOT NULL,
    target_id INTEGER NULL,
    target_path TEXT NOT NULL,
    title TEXT NOT NULL
);
CREATE INDEX file_links_source ON file_links(source_id, kind);
CREATE INDEX file_links_target ON file_links(user_id, target_id);
CREATE INDEX file_links_target_path ON file_links(user_id, target_path);

CREATE TABLE link_sources (
    source_id INTEGER NOT NULL REFERENCES files(id) ON DELETE CASCADE,
    kind TEXT NOT NULL,
    hash TEXT NOT NULL,
    PRIMARY KEY (source_id, kind)
);

-- +goose Down
DROP TABLE link_sources;
DROP TABLE file_links;
ALTER TABLE users DROP COLUMN notes_path;
