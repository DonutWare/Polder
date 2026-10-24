package files

import "time"

type MountKind string

const (
	MountShare     MountKind = "share"
	MountFederated MountKind = "federated"
)

type MountPermissions struct {
	Create bool `json:"create" doc:"Add files and folders"`
	Edit   bool `json:"edit" doc:"Change and rename existing files"`
	Delete bool `json:"delete" doc:"Delete files and folders"`
}

type Mount struct {
	Kind        MountKind        `json:"kind" enum:"share,federated" doc:"share for another user on this server, federated for someone on another server"`
	ShareID     int64            `json:"shareId" doc:"The incoming share's ID, under /shares or /federation/shares/incoming"`
	Path        string           `json:"path" doc:"Where the share sits in the user's files"`
	IsDir       bool             `json:"isDir" doc:"Whether the shared item is a folder"`
	Owner       string           `json:"owner" doc:"The owner's username, or their cloud ID on another server"`
	OwnerName   string           `json:"ownerName"`
	Server      string           `json:"server,omitempty" required:"false" doc:"The other server, for federated shares"`
	Provider    string           `json:"provider,omitempty" required:"false" doc:"The software the other server runs"`
	Groups      []string         `json:"groups,omitempty" required:"false" doc:"Groups the share reached the user through"`
	Permissions MountPermissions `json:"permissions" doc:"What the user may do inside the share"`
	CanLeave    bool             `json:"canLeave" doc:"Whether the user can remove the share; not when it reaches them only through a group"`
	Note        string           `json:"note,omitempty" required:"false"`
	ExpiresAt   *time.Time       `json:"expiresAt,omitempty" required:"false"`
	SharedAt    time.Time        `json:"sharedAt"`
}
