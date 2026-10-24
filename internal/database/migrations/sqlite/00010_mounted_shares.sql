-- +goose Up
ALTER TABLE users ADD COLUMN hide_shares_in_files BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE federated_shares_in ADD COLUMN remote_size INTEGER NOT NULL DEFAULT 0;
ALTER TABLE federated_shares_in ADD COLUMN remote_mtime INTEGER NULL;

-- +goose Down
ALTER TABLE federated_shares_in DROP COLUMN remote_mtime;
ALTER TABLE federated_shares_in DROP COLUMN remote_size;
ALTER TABLE users DROP COLUMN hide_shares_in_files;
