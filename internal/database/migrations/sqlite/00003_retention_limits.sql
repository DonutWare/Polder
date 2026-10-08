-- +goose Up
ALTER TABLE users DROP COLUMN trash_retention_override_days;
ALTER TABLE users ADD COLUMN trash_enabled BOOLEAN NULL;
ALTER TABLE users ADD COLUMN versions_keep_all_hours INTEGER NULL;
DELETE FROM server_settings WHERE name IN ('trash_retention_enforced', 'versions_enforced');

-- +goose Down
ALTER TABLE users DROP COLUMN versions_keep_all_hours;
ALTER TABLE users DROP COLUMN trash_enabled;
ALTER TABLE users ADD COLUMN trash_retention_override_days INTEGER NULL;
