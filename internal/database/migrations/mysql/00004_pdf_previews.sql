-- +goose Up
UPDATE files SET preview_state = 'pending' WHERE mime = 'application/pdf' AND preview_state = 'none';

-- +goose Down
UPDATE files SET preview_state = 'none' WHERE mime = 'application/pdf';
