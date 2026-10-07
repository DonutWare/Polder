-- +goose Up
ALTER TABLE files ADD COLUMN text_state VARCHAR(16) NOT NULL DEFAULT 'none', ADD KEY files_text_state (text_state);
UPDATE files SET text_state = 'pending' WHERE is_dir = 0;

-- +goose Down
ALTER TABLE files DROP KEY files_text_state, DROP COLUMN text_state;
