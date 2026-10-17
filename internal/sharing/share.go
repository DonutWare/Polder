package sharing

import (
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/files"
	"polder-server/internal/users"
)

type SharePermissions struct {
	Create bool `json:"create" required:"false" doc:"Add files and folders; only for folders"`
	Edit   bool `json:"edit" required:"false" doc:"Change and rename existing files"`
	Delete bool `json:"delete" required:"false" doc:"Delete files and folders; only for folders"`
}

func (p SharePermissions) forEntry(isDir bool) SharePermissions {
	if !isDir {
		p.Create, p.Delete = false, false
	}
	return p
}

type RecipientKind string

const (
	RecipientUser  RecipientKind = "user"
	RecipientGroup RecipientKind = "group"
)

func (RecipientKind) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(RecipientUser), string(RecipientGroup)}
	return s
}

type RecipientRef struct {
	Kind RecipientKind `json:"kind"`
	ID   int64         `json:"id"`
}

type Recipient struct {
	Kind     RecipientKind `json:"kind"`
	ID       int64         `json:"id"`
	Name     string        `json:"name" doc:"The user's shown name or the group's name"`
	Username string        `json:"username,omitempty" required:"false" doc:"Only for users"`
	Avatar   *users.Avatar `json:"avatar,omitempty" required:"false"`
}

type FileSummary struct {
	ID    int64  `json:"id"`
	Path  string `json:"path" doc:"Where the item is in the owner's storage; empty while it is in the trash or for other people's items"`
	Name  string `json:"name"`
	IsDir bool   `json:"isDir"`
}

func summarize(entry files.Entry) FileSummary {
	return FileSummary{ID: entry.ID, Path: entry.Path, Name: entry.Name, IsDir: entry.IsDir}
}

type Share struct {
	ID          int64             `json:"id"`
	File        FileSummary       `json:"file"`
	Owner       users.UserSummary `json:"owner"`
	Recipient   Recipient         `json:"recipient"`
	Permissions SharePermissions  `json:"permissions"`
	ExpiresAt   *time.Time        `json:"expiresAt,omitempty" required:"false"`
	Note        string            `json:"note"`
	Available   bool              `json:"available" doc:"False while the shared item is in the trash"`
	CanChange   bool              `json:"canChange" doc:"Whether the logged-in user may change this share"`
	CanRemove   bool              `json:"canRemove" doc:"Whether the logged-in user may remove this share"`
	CreatedAt   time.Time         `json:"createdAt"`
}

type GroupRef struct {
	ID   int64  `json:"id"`
	Name string `json:"name"`
}

type IncomingShare struct {
	ID          int64             `json:"id" doc:"Opens the item; when several shares reach the same item they are combined under one ID, the personal share's when there is one"`
	Owner       users.UserSummary `json:"owner"`
	Direct      bool              `json:"direct" doc:"Whether the item was shared with the user personally; only then can they remove it from their list"`
	Groups      []GroupRef        `json:"groups" doc:"The groups the item reached the user through"`
	Permissions SharePermissions  `json:"permissions" doc:"What the logged-in user may actually do, combined over every share that reaches them and after group roles"`
	ExpiresAt   *time.Time        `json:"expiresAt,omitempty" required:"false"`
	Note        string            `json:"note"`
	Entry       files.Entry       `json:"entry" doc:"The shared item; its path is / because paths inside a share start at the shared item"`
	CreatedAt   time.Time         `json:"createdAt"`
}

type NewShare struct {
	FileID      int64            `json:"fileId" doc:"One of the logged-in user's own files"`
	Recipient   RecipientRef     `json:"recipient"`
	Permissions SharePermissions `json:"permissions"`
	ExpiresAt   *time.Time       `json:"expiresAt,omitempty" required:"false"`
	Note        string           `json:"note,omitempty" required:"false" maxLength:"1000"`
}

type ShareChanges struct {
	Permissions  *SharePermissions `json:"permissions,omitempty" required:"false"`
	ExpiresAt    *time.Time        `json:"expiresAt,omitempty" required:"false"`
	RemoveExpiry bool              `json:"removeExpiry,omitempty" required:"false"`
	Note         *string           `json:"note,omitempty" required:"false" maxLength:"1000"`
}
