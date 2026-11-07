-- +goose Up
CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kind TEXT NOT NULL,
    payload TEXT NOT NULL DEFAULT '{}',
    created_at INTEGER NOT NULL,
    read_at INTEGER NULL
);
CREATE INDEX notifications_user ON notifications(user_id, id);
CREATE INDEX notifications_created ON notifications(created_at);

CREATE TABLE share_responses (
    share_id INTEGER NOT NULL REFERENCES shares(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    state TEXT NOT NULL,
    responded_at INTEGER NOT NULL,
    PRIMARY KEY (share_id, user_id)
);
CREATE INDEX share_responses_user ON share_responses(user_id);

INSERT INTO share_responses (share_id, user_id, state, responded_at)
SELECT id, recipient_user_id, 'accepted', created_at FROM shares WHERE recipient_user_id IS NOT NULL;
INSERT INTO share_responses (share_id, user_id, state, responded_at)
SELECT s.id, m.user_id, 'accepted', s.created_at FROM shares s
JOIN group_members m ON m.group_id = s.recipient_group_id
WHERE m.user_id <> s.owner_id;

-- +goose Down
DROP TABLE share_responses;
DROP TABLE notifications;
