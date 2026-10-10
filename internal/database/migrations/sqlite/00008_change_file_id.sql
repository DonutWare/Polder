-- +goose Up
ALTER TABLE changes ADD COLUMN file_id INTEGER NULL;

-- +goose Down
ALTER TABLE changes DROP COLUMN file_id;
