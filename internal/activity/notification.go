package activity

import "time"

type NotificationKind string

const (
	NotificationShareReceived          NotificationKind = "share.received"
	NotificationFederatedShareReceived NotificationKind = "federated_share.received"
)

type Notification struct {
	ID        int64            `json:"id"`
	Kind      NotificationKind `json:"kind"`
	CreatedAt time.Time        `json:"createdAt"`
	Read      bool             `json:"read"`
	Share     *ShareNotice     `json:"share,omitempty" required:"false" doc:"Set for share.received and federated_share.received"`
}

type ShareNotice struct {
	ShareID   int64  `json:"shareId" doc:"The incoming share to open, accept or decline"`
	OwnerName string `json:"ownerName"`
	Owner     string `json:"owner" doc:"The owner's username, or cloud ID for a federated share"`
	Name      string `json:"name" doc:"The shared item's name"`
	IsDir     bool   `json:"isDir"`
	Note      string `json:"note,omitempty" required:"false"`
	Group     string `json:"group,omitempty" required:"false" doc:"The group it reached the user through"`
	Server    string `json:"server,omitempty" required:"false" doc:"The remote server, for a federated share"`
}
