-- +goose Up
CREATE TABLE activity (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    session_id BIGINT NULL,
    device VARCHAR(255) NOT NULL,
    kind VARCHAR(32) NOT NULL,
    path TEXT NOT NULL,
    from_path TEXT NOT NULL,
    is_dir TINYINT(1) NOT NULL,
    size BIGINT NULL,
    bytes BIGINT NULL,
    duration_ms BIGINT NULL,
    item_count BIGINT NULL,
    status VARCHAR(16) NOT NULL,
    detail TEXT NOT NULL,
    created_at BIGINT NOT NULL,
    KEY activity_user (user_id, id),
    KEY activity_created (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- +goose Down
DROP TABLE activity;
