-- +goose Up
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(64) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(16) NOT NULL,
    quota_bytes BIGINT NOT NULL DEFAULT 0,
    disabled TINYINT(1) NOT NULL DEFAULT 0,
    created_at BIGINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash CHAR(64) NOT NULL UNIQUE,
    device_name VARCHAR(255) NOT NULL,
    created_at BIGINT NOT NULL,
    last_used_at BIGINT NOT NULL,
    expires_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE files (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    path TEXT NOT NULL,
    path_key CHAR(64) NOT NULL,
    parent_key CHAR(64) NOT NULL,
    name VARCHAR(1024) NOT NULL,
    is_dir TINYINT(1) NOT NULL,
    size BIGINT NOT NULL,
    mtime_ns BIGINT NOT NULL,
    hash CHAR(64) NOT NULL,
    rev BIGINT NOT NULL,
    mime VARCHAR(255) NOT NULL,
    meta_json TEXT NOT NULL,
    preview_state VARCHAR(16) NOT NULL,
    UNIQUE KEY files_user_path (user_id, path_key),
    KEY files_user_parent (user_id, parent_key),
    KEY files_preview_state (preview_state),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE file_chunks (
    file_id BIGINT NOT NULL,
    rev BIGINT NOT NULL,
    idx INT NOT NULL,
    hash CHAR(64) NOT NULL,
    offset_bytes BIGINT NOT NULL,
    size BIGINT NOT NULL,
    PRIMARY KEY (file_id, rev, idx),
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE changes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    path TEXT NOT NULL,
    path_key CHAR(64) NOT NULL,
    change_type VARCHAR(16) NOT NULL,
    from_path TEXT NULL,
    created_at BIGINT NOT NULL,
    KEY changes_user_id (user_id, id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

CREATE TABLE uploads (
    id CHAR(32) PRIMARY KEY,
    user_id BIGINT NOT NULL,
    path TEXT NOT NULL,
    base_rev BIGINT NOT NULL,
    size BIGINT NOT NULL,
    hash CHAR(64) NOT NULL,
    mtime_ns BIGINT NOT NULL,
    chunks_json LONGTEXT NOT NULL,
    created_at BIGINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- +goose Down
DROP TABLE uploads;
DROP TABLE changes;
DROP TABLE file_chunks;
DROP TABLE files;
DROP TABLE sessions;
DROP TABLE users;
