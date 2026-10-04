package activity

import "github.com/danielgtaylor/huma/v2"

type Kind string

const (
	KindUpload      Kind = "upload"
	KindDownload    Kind = "download"
	KindMkdir       Kind = "mkdir"
	KindMove        Kind = "move"
	KindDelete      Kind = "delete"
	KindRestore     Kind = "restore"
	KindTrashDelete Kind = "trashDelete"
	KindTrashEmpty  Kind = "trashEmpty"
	KindTrashExpire Kind = "trashExpire"
	KindRescan      Kind = "rescan"
	KindLogin       Kind = "login"
	KindLogout      Kind = "logout"
)

func (Kind) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(KindUpload), string(KindDownload), string(KindMkdir), string(KindMove), string(KindDelete),
		string(KindRestore), string(KindTrashDelete), string(KindTrashEmpty), string(KindTrashExpire), string(KindRescan),
		string(KindLogin), string(KindLogout)}
	return s
}

type Status string

const (
	StatusOK        Status = "ok"
	StatusFailed    Status = "failed"
	StatusCancelled Status = "cancelled"
)

func (Status) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(StatusOK), string(StatusFailed), string(StatusCancelled)}
	return s
}

type Direction string

const (
	DirectionUpload   Direction = "upload"
	DirectionDownload Direction = "download"
)

func (Direction) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(DirectionUpload), string(DirectionDownload)}
	return s
}

func (EventType) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(EventReady), string(EventSnapshot), string(EventError), string(EventTransferStarted),
		string(EventTransferProgress), string(EventTransferFinished), string(EventActivity), string(EventFilesChanged)}
	return s
}
