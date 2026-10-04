package files

import (
	"context"

	"nomad-server/internal/users"
)

type MutationKind string

const (
	MutationWrite       MutationKind = "write"
	MutationMkdir       MutationKind = "mkdir"
	MutationMove        MutationKind = "move"
	MutationDelete      MutationKind = "delete"
	MutationRestore     MutationKind = "restore"
	MutationTrashDelete MutationKind = "trashDelete"
	MutationTrashEmpty  MutationKind = "trashEmpty"
	MutationTrashExpire MutationKind = "trashExpire"
	MutationRescan      MutationKind = "rescan"
)

type ScanChangeType string

const (
	ScanAdded   ScanChangeType = "added"
	ScanChanged ScanChangeType = "changed"
	ScanRemoved ScanChangeType = "removed"
)

type ScanChange struct {
	Path   string
	IsDir  bool
	Change ScanChangeType
}

type Mutation struct {
	Owner    users.User
	Kind     MutationKind
	Path     string
	FromPath string
	IsDir    bool
	Size     int64
	Count    int
	Changes  []ScanChange
}

type MutationFunc func(context.Context, Mutation)

func (s *Service) OnMutation(observer MutationFunc) {
	s.observers = append(s.observers, observer)
}

func (s *Service) notify(ctx context.Context, mutation Mutation) {
	for _, observer := range s.observers {
		observer(ctx, mutation)
	}
}
