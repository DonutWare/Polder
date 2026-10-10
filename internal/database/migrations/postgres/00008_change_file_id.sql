-- +goose Up
ALTER TABLE changes ADD COLUMN file_id BIGINT NULL;

-- +goose Down
ALTER TABLE changes DROP COLUMN file_id;
