package sharing

import (
	"context"
	"slices"
	"strings"
	"time"

	"polder-server/internal/users"
)

type reach struct {
	row    shareRow
	access Access
}

type reachedItem struct {
	reaches []reach
}

func (s *Service) reachedItems(ctx context.Context, user users.User, rows []shareRow) []reachedItem {
	indexByFile := map[int64]int{}
	items := []reachedItem{}
	for _, row := range rows {
		access, err := s.resolve(ctx, row, user)
		if err != nil {
			continue
		}
		index, seen := indexByFile[row.FileID]
		if !seen {
			index = len(items)
			indexByFile[row.FileID] = index
			items = append(items, reachedItem{})
		}
		items[index].reaches = append(items[index].reaches, reach{row: row, access: access})
	}
	return items
}

func (item reachedItem) direct() (reach, bool) {
	for _, reached := range item.reaches {
		if reached.row.RecipientUserID != 0 {
			return reached, true
		}
	}
	return reach{}, false
}

func (item reachedItem) primary() reach {
	if direct, ok := item.direct(); ok {
		return direct
	}
	return item.reaches[0]
}

func (item reachedItem) access() Access {
	combined := item.primary().access
	for _, reached := range item.reaches {
		combined.CanCreate = combined.CanCreate || reached.access.CanCreate
		combined.CanEdit = combined.CanEdit || reached.access.CanEdit
		combined.CanDelete = combined.CanDelete || reached.access.CanDelete
	}
	combined.ExpiresAt = item.expiresAt()
	return combined
}

func (item reachedItem) expiresAt() *time.Time {
	var latest *time.Time
	for _, reached := range item.reaches {
		expiresAt := reached.access.ExpiresAt
		if expiresAt == nil {
			return nil
		}
		if latest == nil || expiresAt.After(*latest) {
			latest = expiresAt
		}
	}
	return latest
}

func (item reachedItem) note() string {
	notes := []string{}
	for _, reached := range append([]reach{item.primary()}, item.reaches...) {
		if note := reached.row.Note; note != "" && !slices.Contains(notes, note) {
			notes = append(notes, note)
		}
	}
	return strings.Join(notes, "\n\n")
}

func (item reachedItem) createdAt() time.Time {
	earliest := item.reaches[0].row.CreatedAt
	for _, reached := range item.reaches[1:] {
		if reached.row.CreatedAt.Before(earliest) {
			earliest = reached.row.CreatedAt
		}
	}
	return earliest
}

func (item reachedItem) groups(lookup *recipientNames) []GroupRef {
	refs := []GroupRef{}
	for _, reached := range item.reaches {
		if reached.row.RecipientGroupID == 0 {
			continue
		}
		if group, ok := lookup.describe(reached.row.recipient()); ok {
			refs = append(refs, GroupRef{ID: group.ID, Name: group.Name})
		}
	}
	return refs
}
