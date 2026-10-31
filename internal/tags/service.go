package tags

import (
	"bytes"
	"context"
	"database/sql"
	"io"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/users"
)

type Target struct {
	Owner   users.User
	Path    string
	CanEdit bool
}

type TagChange struct {
	Name  *string `json:"name,omitempty" required:"false"`
	Color *string `json:"color,omitempty" required:"false" doc:"Hex color such as #3e63dd"`
}

type Service struct {
	store *Store
	files *files.Service
	users *users.Store
	queue chan job
}

func NewService(db *sql.DB, fileService *files.Service, userStore *users.Store) *Service {
	return &Service{store: NewStore(db), files: fileService, users: userStore, queue: make(chan job, queueCapacity)}
}

func (s *Service) Store() *Store { return s.store }

func (s *Service) List(ctx context.Context, viewer users.User) ([]UserTag, error) {
	return s.store.List(ctx, viewer.ID)
}

func (s *Service) Create(ctx context.Context, viewer users.User, name, color string) (UserTag, error) {
	color = NormalizeColor(color)
	if err := validate(name, color); err != nil {
		return UserTag{}, err
	}
	return s.store.Insert(ctx, viewer.ID, name, color)
}

func validate(name, color string) error {
	if !ValidName(name) {
		return apperr.Invalid("a tag name uses letters, digits, -, _ or / and has at least one letter")
	}
	if color != "" && !ValidColor(color) {
		return apperr.Invalid("%q is not a color such as #3e63dd", color)
	}
	return nil
}

func (s *Service) Update(ctx context.Context, viewer users.User, id int64, change TagChange) (UserTag, error) {
	current, err := s.store.ByID(ctx, viewer.ID, id)
	if err != nil {
		return UserTag{}, err
	}
	name, color := current.Name, current.Color
	if change.Name != nil {
		name = *change.Name
	}
	if change.Color != nil {
		color = NormalizeColor(*change.Color)
	}
	if err := validate(name, color); err != nil {
		return UserTag{}, err
	}
	if err := s.store.Update(ctx, viewer.ID, id, name, color); err != nil {
		return UserTag{}, err
	}
	if name != current.Name {
		s.rewriteOwnNotes(ctx, viewer, Key(current.Name), func(source []byte) []byte {
			return RenameTag(source, Key(current.Name), name)
		})
	}
	return s.store.ByID(ctx, viewer.ID, id)
}

func (s *Service) Delete(ctx context.Context, viewer users.User, id int64) error {
	current, err := s.store.ByID(ctx, viewer.ID, id)
	if err != nil {
		return err
	}
	s.rewriteOwnNotes(ctx, viewer, Key(current.Name), func(source []byte) []byte {
		return RemoveTag(source, Key(current.Name))
	})
	return s.store.Delete(ctx, viewer.ID, id)
}

func (s *Service) rewriteOwnNotes(ctx context.Context, owner users.User, key string, rewrite func([]byte) []byte) {
	noteIDs, err := s.store.NotesWithTag(ctx, owner.ID, key)
	if err != nil {
		logger.Warn("find notes with a tag", "tag", key, "error", err)
		return
	}
	for _, noteID := range noteIDs {
		note, err := s.files.EntryByID(ctx, owner.ID, noteID)
		if err != nil {
			continue
		}
		if err := s.rewriteNote(ctx, owner, note, rewrite, true); err != nil && !apperr.Is(err, apperr.KindConflict) {
			logger.Warn("rewrite tags in a note", "path", note.Path, "error", err)
		}
	}
}

func (s *Service) rewriteNote(ctx context.Context, owner users.User, note files.Entry, rewrite func([]byte) []byte, housekeeping bool) error {
	source, err := s.content(ctx, owner, note)
	if err != nil {
		return err
	}
	updated := rewrite(source)
	if bytes.Equal(updated, source) {
		return nil
	}
	written, err := s.files.Write(ctx, owner, files.WriteRequest{
		Path: note.Path, BaseRev: note.Rev, Content: bytes.NewReader(updated), Housekeeping: housekeeping,
	})
	if err != nil {
		return err
	}
	return s.readNote(ctx, owner, written, updated)
}

func (s *Service) content(ctx context.Context, owner users.User, note files.Entry) ([]byte, error) {
	file, _, err := s.files.Open(ctx, owner, note.Path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	return io.ReadAll(file)
}

func (s *Service) Assign(ctx context.Context, viewer users.User, targets []Target, names []string) []error {
	tags, err := s.ensureForViewer(ctx, viewer, names)
	if err != nil {
		return repeatError(err, len(targets))
	}
	return s.eachTarget(ctx, targets, func(target Target, entry files.Entry) error {
		if isNote(entry) && target.CanEdit {
			return s.rewriteNote(ctx, target.Owner, entry, func(source []byte) []byte {
				for _, tag := range tags {
					source = AppendTag(source, tag.Name)
				}
				return source
			}, false)
		}
		for _, tag := range tags {
			if err := s.store.AddManual(ctx, viewer.ID, entry.ID, tag.ID); err != nil {
				return err
			}
		}
		return nil
	})
}

func (s *Service) Unassign(ctx context.Context, viewer users.User, targets []Target, names []string) []error {
	keys := make([]string, 0, len(names))
	for _, name := range names {
		keys = append(keys, Key(name))
	}
	tags, err := s.store.ByKeys(ctx, viewer.ID, keys)
	if err != nil {
		return repeatError(err, len(targets))
	}
	return s.eachTarget(ctx, targets, func(target Target, entry files.Entry) error {
		for _, tag := range tags {
			if err := s.store.RemoveManual(ctx, viewer.ID, entry.ID, tag.ID); err != nil {
				return err
			}
		}
		if !isNote(entry) {
			return nil
		}
		return s.removeFromNote(ctx, target, entry, keys)
	})
}

func (s *Service) removeFromNote(ctx context.Context, target Target, note files.Entry, keys []string) error {
	source, err := s.content(ctx, target.Owner, note)
	if err != nil {
		return err
	}
	written := false
	for _, key := range keys {
		written = written || HasTag(source, key)
	}
	if !written {
		return nil
	}
	if !target.CanEdit {
		return apperr.Forbidden("the tag is written in a note you cannot edit")
	}
	return s.rewriteNote(ctx, target.Owner, note, func(source []byte) []byte {
		for _, key := range keys {
			source = RemoveTag(source, key)
		}
		return source
	}, false)
}

func (s *Service) ensureForViewer(ctx context.Context, viewer users.User, names []string) ([]UserTag, error) {
	if len(names) == 0 {
		return nil, apperr.Invalid("name at least one tag")
	}
	keys := make([]string, 0, len(names))
	for _, name := range names {
		if err := validate(name, ""); err != nil {
			return nil, err
		}
		keys = append(keys, Key(name))
	}
	if err := s.store.EnsureNames(ctx, viewer.ID, names); err != nil {
		return nil, err
	}
	found, err := s.store.ByKeys(ctx, viewer.ID, keys)
	if err != nil {
		return nil, err
	}
	tags := make([]UserTag, 0, len(found))
	for _, key := range keys {
		if tag, ok := found[key]; ok {
			tags = append(tags, tag)
			delete(found, key)
		}
	}
	return tags, nil
}

func (s *Service) eachTarget(ctx context.Context, targets []Target, apply func(Target, files.Entry) error) []error {
	errs := make([]error, len(targets))
	for i, target := range targets {
		entry, err := s.files.Stat(ctx, target.Owner, target.Path)
		if err == nil {
			err = apply(target, entry)
		}
		errs[i] = err
	}
	return errs
}

func repeatError(err error, count int) []error {
	errs := make([]error, count)
	for i := range errs {
		errs[i] = err
	}
	return errs
}

func isNote(entry files.Entry) bool {
	return !entry.IsDir && entry.Mime == files.MarkdownMime
}
