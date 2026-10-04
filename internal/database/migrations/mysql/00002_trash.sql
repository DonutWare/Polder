-- +goose Up
CREATE TABLE trash (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    original_path TEXT NOT NULL,
    name VARCHAR(1024) NOT NULL,
    is_dir TINYINT(1) NOT NULL,
    size BIGINT NOT NULL,
    mime VARCHAR(255) NOT NULL,
    hash CHAR(64) NOT NULL,
    preview_state VARCHAR(16) NOT NULL,
    storage_id CHAR(32) NOT NULL,
    deleted_at BIGINT NOT NULL,
    KEY trash_user_deleted (user_id, deleted_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE server_settings (
    name VARCHAR(64) PRIMARY KEY,
    value TEXT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

ALTER TABLE users ADD COLUMN trash_retention_days INT NULL;
ALTER TABLE users ADD COLUMN trash_retention_override_days INT NULL;

-- +goose Down
ALTER TABLE users DROP COLUMN trash_retention_override_days;
ALTER TABLE users DROP COLUMN trash_retention_days;
DROP TABLE server_settings;
DROP TABLE trash;
