-- +goose Up
ALTER TABLE files ADD COLUMN text_state TEXT NOT NULL DEFAULT 'none';
UPDATE files SET text_state = 'pending' WHERE is_dir = 0;
CREATE INDEX files_text_state ON files(text_state);

-- +goose Down
DROP INDEX files_text_state;
ALTER TABLE files DROP COLUMN text_state;
