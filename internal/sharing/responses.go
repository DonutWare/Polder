package sharing

import (
	"context"
	"strconv"
	"strings"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/database"
	"polder-server/internal/users"
)

type ShareState string

const (
	StatePending  ShareState = "pending"
	StateAccepted ShareState = "accepted"
	StateDeclined ShareState = "declined"
)

func (ShareState) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(StatePending), string(StateAccepted)}
	return s
}

type ShareNotifier interface {
	ShareReceived(ctx context.Context, userIDs []int64, notice activity.ShareNotice)
}

func (s *Service) UseNotifier(notifier ShareNotifier) {
	s.notifier = notifier
}

func (s *Service) Accept(ctx context.Context, user users.User, shareID int64) error {
	return s.respond(ctx, user, shareID, StateAccepted)
}

func (s *Service) Decline(ctx context.Context, user users.User, shareID int64) error {
	return s.respond(ctx, user, shareID, StateDeclined)
}

func (s *Service) respond(ctx context.Context, user users.User, shareID int64, state ShareState) error {
	row, err := shareByID(ctx, s.db, shareID)
	if err != nil {
		return err
	}
	rows, err := s.reachingShares(ctx, user, ` AND file_id = $2`, row.FileID)
	if err != nil {
		return err
	}
	items := s.reachedItems(ctx, user, rows)
	if len(items) == 0 {
		return notAvailable()
	}
	now := time.Now().Unix()
	for _, reached := range items[0].reaches {
		_, err := s.db.ExecContext(ctx,
			`INSERT INTO share_responses (share_id, user_id, state, responded_at) VALUES ($1, $2, $3, $4)
			ON CONFLICT (share_id, user_id) DO UPDATE SET state = excluded.state, responded_at = excluded.responded_at`,
			reached.row.ID, user.ID, string(state), now)
		if err != nil {
			return err
		}
	}
	return nil
}

func (s *Service) responsesOf(ctx context.Context, userID int64, rows []shareRow) (map[int64]ShareState, error) {
	states := map[int64]ShareState{}
	if len(rows) == 0 {
		return states, nil
	}
	placeholders := make([]string, len(rows))
	args := []any{userID}
	for i, row := range rows {
		args = append(args, row.ID)
		placeholders[i] = "$" + strconv.Itoa(i+2)
	}
	type response struct {
		shareID int64
		state   ShareState
	}
	list, err := database.QueryAll(ctx, s.db, func(row database.RowScanner) (response, error) {
		var found response
		err := row.Scan(&found.shareID, &found.state)
		return found, err
	}, `SELECT share_id, state FROM share_responses WHERE user_id = $1 AND share_id IN (`+strings.Join(placeholders, ", ")+`)`, args...)
	if err != nil {
		return nil, err
	}
	for _, found := range list {
		states[found.shareID] = found.state
	}
	return states, nil
}

func (item reachedItem) state(responses map[int64]ShareState) ShareState {
	declined := 0
	for _, reached := range item.reaches {
		switch responses[reached.row.ID] {
		case StateAccepted:
			return StateAccepted
		case StateDeclined:
			declined++
		}
	}
	if declined == len(item.reaches) {
		return StateDeclined
	}
	return StatePending
}

func (s *Service) notifyRecipients(ctx context.Context, owner users.User, row shareRow, name string, isDir bool) {
	if s.notifier == nil {
		return
	}
	notice := activity.ShareNotice{
		OwnerName: owner.ShownName(), Owner: owner.Username, Name: name, IsDir: isDir, Note: row.Note,
	}
	recipients := []int64{row.RecipientUserID}
	if row.RecipientGroupID != 0 {
		var err error
		if recipients, err = s.groupAudience(ctx, row.RecipientGroupID, owner.ID); err != nil {
			logger.Warn("find who a group share reaches", "group", row.RecipientGroupID, "error", err)
			return
		}
		if group, err := s.groups.ByID(ctx, row.RecipientGroupID); err == nil {
			notice.Group = group.Name
		}
	}
	notice.ShareID = row.ID
	s.notifier.ShareReceived(ctx, recipients, notice)
}

func (s *Service) groupAudience(ctx context.Context, groupID, ownerID int64) ([]int64, error) {
	return database.QueryAll(ctx, s.db, database.ScanInt64,
		`SELECT user_id FROM group_members WHERE group_id = $1 AND user_id <> $2`, groupID, ownerID)
}
