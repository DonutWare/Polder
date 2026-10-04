package activity

import "context"

const ServerDevice = "server"

type Actor struct {
	SessionID int64
	Device    string
}

type actorKey struct{}

func WithActor(ctx context.Context, actor Actor) context.Context {
	return context.WithValue(ctx, actorKey{}, actor)
}

func ActorFrom(ctx context.Context) Actor {
	actor, ok := ctx.Value(actorKey{}).(Actor)
	if !ok {
		return Actor{Device: ServerDevice}
	}
	return actor
}

type transferKey struct{}

func WithTransfer(ctx context.Context, transfer *Transfer) context.Context {
	if transfer == nil {
		return ctx
	}
	return context.WithValue(ctx, transferKey{}, transfer)
}

func transferFrom(ctx context.Context) *Transfer {
	transfer, _ := ctx.Value(transferKey{}).(*Transfer)
	return transfer
}
