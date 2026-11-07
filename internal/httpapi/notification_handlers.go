package httpapi

import (
	"context"

	"polder-server/internal/notifications"
)

type notificationsInput struct {
	After int64 `query:"after" default:"0" doc:"Cursor from the previous page; 0 starts from the oldest kept, -1 returns nothing and only the latest cursor"`
	Limit int   `query:"limit" default:"100" doc:"Maximum number of notifications to return; the server caps it"`
}

type markNotificationsReadInput struct {
	Body struct {
		UpTo int64 `json:"upTo" doc:"Marks this notification and every earlier one as read"`
	}
}

func (a *API) listNotifications(ctx context.Context, input *notificationsInput) (*jsonBody[notifications.NotificationPage], error) {
	page, err := a.notifications.List(ctx, currentUser(ctx).ID, input.After, input.Limit)
	if err != nil {
		return nil, err
	}
	return respond(page), nil
}

func (a *API) markNotificationsRead(ctx context.Context, input *markNotificationsReadInput) (*struct{}, error) {
	return nil, a.notifications.MarkRead(ctx, currentUser(ctx).ID, input.Body.UpTo)
}
