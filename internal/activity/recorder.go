package activity

import (
	"context"

	"polder-server/internal/files"
	"polder-server/internal/storage"
	"polder-server/internal/users"
)

const rescanDetailLimit = 20

func (h *Hub) FileMutation(ctx context.Context, mutation files.Mutation) {
	h.publishDirectories(mutation.Owner.ID, changedPaths(mutation))
	if mutation.Housekeeping {
		return
	}
	if mutation.Kind == files.MutationWrite {
		if transfer := transferFrom(ctx); transfer != nil {
			h.complete(transfer, mutation.Size)
			return
		}
	}

	actor := ActorFrom(ctx)
	entry := LogEntry{
		UserID: mutation.Owner.ID, Username: mutation.Owner.Username, Device: actor.Device, sessionID: actor.SessionID,
		Path: mutation.Path, FromPath: mutation.FromPath, IsDir: mutation.IsDir,
	}
	if entry.FromPath == entry.Path {
		entry.FromPath = ""
	}
	if !mutation.IsDir || mutation.Count > 0 {
		entry.Size = ptr(mutation.Size)
	}
	if mutation.Count > 0 {
		entry.Count = ptr(int64(mutation.Count))
	}

	switch mutation.Kind {
	case files.MutationWrite:
		entry.Kind = KindUpload
	case files.MutationMkdir:
		entry.Kind = KindMkdir
	case files.MutationMove:
		entry.Kind = KindMove
	case files.MutationDelete:
		entry.Kind = KindDelete
	case files.MutationRestore:
		entry.Kind = KindRestore
	case files.MutationTrashDelete:
		entry.Kind = KindTrashDelete
	case files.MutationTrashEmpty:
		entry.Kind = KindTrashEmpty
	case files.MutationTrashExpire:
		entry.Kind = KindTrashExpire
	case files.MutationRescan:
		return
	case files.MutationRescanFinished:
		h.recordRescan(ctx, entry, mutation.Changes, mutation.Count)
		return
	default:
		return
	}
	h.record(ctx, entry)
}

func (h *Hub) recordRescan(ctx context.Context, base LogEntry, changes []files.ScanChange, count int) {
	base.Kind = KindRescan
	if count > rescanDetailLimit {
		base.Detail = "summary"
		base.Count = ptr(int64(count))
		h.record(ctx, base)
		return
	}
	for _, change := range changes {
		entry := base
		entry.Path = change.Path
		entry.IsDir = change.IsDir
		entry.Detail = string(change.Change)
		h.record(ctx, entry)
	}
}

func (h *Hub) Session(ctx context.Context, user users.User, sessionID int64, device string, started bool) {
	kind := KindLogout
	if started {
		kind = KindLogin
	}
	h.record(ctx, LogEntry{UserID: user.ID, Username: user.Username, Device: device, sessionID: sessionID, Kind: kind, Path: ""})
}

func changedPaths(mutation files.Mutation) []string {
	switch mutation.Kind {
	case files.MutationTrashDelete, files.MutationTrashEmpty, files.MutationTrashExpire, files.MutationRescanFinished:
		return nil
	case files.MutationRescan:
		paths := make([]string, 0, len(mutation.Changes))
		for _, change := range mutation.Changes {
			paths = append(paths, change.Path)
		}
		return paths
	}
	return []string{mutation.Path, mutation.FromPath}
}

func (h *Hub) publishDirectories(userID int64, paths []string) {
	seen := map[string]bool{}
	var directories []string
	for _, changed := range paths {
		if changed == "" || changed == storage.RootPath {
			continue
		}
		for _, directory := range append([]string{storage.RootPath}, storage.Ancestors(changed)...) {
			if !seen[directory] {
				seen[directory] = true
				directories = append(directories, directory)
			}
		}
	}
	if len(directories) > 0 {
		h.Publish(Event{Type: EventFilesChanged, UserID: userID, Dirs: directories})
	}
}
