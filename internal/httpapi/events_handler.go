package httpapi

import (
	"context"
	"errors"
	"strconv"
	"time"

	"github.com/coder/websocket"
	"github.com/coder/websocket/wsjson"
	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/users"
)

const eventsDescription = "Open a WebSocket here and send an `auth` message within 10 seconds, and again whenever " +
	"the token is renewed. The server answers `ready` and a `snapshot` of the transfers in progress. Administrators " +
	"can `subscribe` to other users; every subscribe is answered with a new snapshot, and your own events always arrive. " +
	"Messages are described by the ClientMessage and EventMessage schemas. " +
	"The connection closes with code 4401 when authentication fails or the token expires without renewal."

const (
	closeUnauthorized = websocket.StatusCode(4401)
	authTimeout       = 10 * time.Second
	writeTimeout      = 10 * time.Second
	pingInterval      = 30 * time.Second
	eventsReadLimit   = 4096
)

type eventsOutput struct {
	Body func(huma.Context)
}

// eventMessage is every message the socket sends; its type decides which of the other fields are set.
type eventMessage struct {
	activity.Event
	User      *users.User             `json:"user,omitempty" required:"false"`
	Transfers []activity.LiveTransfer `json:"transfers,omitempty" required:"false"`
	Code      apperr.Kind             `json:"code,omitempty" required:"false"`
	Message   string                  `json:"message,omitempty" required:"false"`
}

type clientMessageType string

const (
	clientAuth      clientMessageType = "auth"
	clientSubscribe clientMessageType = "subscribe"
)

func (clientMessageType) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(clientAuth), string(clientSubscribe)}
	return s
}

type subscribeScope string

const (
	scopeMe   subscribeScope = "me"
	scopeAll  subscribeScope = "all"
	scopeUser subscribeScope = "user"
)

func (subscribeScope) TransformSchema(_ huma.Registry, s *huma.Schema) *huma.Schema {
	s.Enum = []any{string(scopeMe), string(scopeAll), string(scopeUser)}
	return s
}

// clientMessage is every message a client sends over the socket.
type clientMessage struct {
	Type   clientMessageType `json:"type"`
	Token  string            `json:"token,omitempty" required:"false" doc:"The access token, for auth"`
	Scope  subscribeScope    `json:"scope,omitempty" required:"false" doc:"Whose events to watch, for subscribe"`
	UserID int64             `json:"userId,omitempty" required:"false" doc:"The user to watch when scope is user"`
}

func (a *API) events(context.Context, *struct{}) (*eventsOutput, error) {
	return &eventsOutput{Body: func(ctx huma.Context) {
		r, w := humachi.Unwrap(ctx)
		// The token travels inside the socket rather than in a cookie, so another site's page
		// cannot borrow a session through this connection; any origin may connect.
		conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{InsecureSkipVerify: true})
		if err != nil {
			return
		}
		defer func() { _ = conn.CloseNow() }()
		conn.SetReadLimit(eventsReadLimit)
		a.serveEvents(r.Context(), conn)
	}}, nil
}

type eventStream struct {
	api          *API
	conn         *websocket.Conn
	identity     auth.Identity
	requested    string
	subscription *activity.Subscription
}

func (a *API) serveEvents(ctx context.Context, conn *websocket.Conn) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	identity, err := a.authenticateSocket(ctx, conn)
	if err != nil {
		_ = conn.Close(closeUnauthorized, "authentication required")
		return
	}
	stream := &eventStream{api: a, conn: conn, identity: identity, requested: string(scopeMe)}
	subscription, transfers := a.activity.Subscribe(activity.Scope{Self: identity.User.ID})
	stream.subscription = subscription
	defer subscription.Close()
	if stream.send(ctx, eventMessage{Event: activity.Event{Type: activity.EventReady}, User: &identity.User}) != nil || stream.sendSnapshot(ctx, transfers) != nil {
		return
	}

	messages := make(chan clientMessage)
	go func() {
		defer cancel()
		for {
			var message clientMessage
			if err := wsjson.Read(ctx, conn, &message); err != nil {
				return
			}
			select {
			case messages <- message:
			case <-ctx.Done():
				return
			}
		}
	}()

	ping := time.NewTicker(pingInterval)
	defer ping.Stop()
	expiry := time.NewTimer(time.Until(identity.ExpiresAt))
	defer expiry.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case event, open := <-subscription.Events():
			if !open {
				_ = conn.Close(websocket.StatusTryAgainLater, "reconnect")
				return
			}
			if stream.send(ctx, eventMessage{Event: event}) != nil {
				return
			}
		case message := <-messages:
			if err := stream.handle(ctx, message); err != nil {
				_ = conn.Close(closeUnauthorized, "authentication failed")
				return
			}
			expiry.Reset(time.Until(stream.identity.ExpiresAt))
		case <-ping.C:
			pingCtx, cancelPing := context.WithTimeout(ctx, writeTimeout)
			err := conn.Ping(pingCtx)
			cancelPing()
			if err != nil {
				return
			}
		case <-expiry.C:
			_ = conn.Close(closeUnauthorized, "token expired")
			return
		}
	}
}

func (a *API) authenticateSocket(ctx context.Context, conn *websocket.Conn) (auth.Identity, error) {
	authCtx, cancel := context.WithTimeout(ctx, authTimeout)
	defer cancel()
	var message clientMessage
	if err := wsjson.Read(authCtx, conn, &message); err != nil {
		return auth.Identity{}, err
	}
	if message.Type != clientAuth {
		return auth.Identity{}, errors.New("first message must be auth")
	}
	return a.auth.Authenticate(ctx, message.Token)
}

func (s *eventStream) handle(ctx context.Context, message clientMessage) error {
	switch message.Type {
	case clientAuth:
		identity, err := s.api.auth.Authenticate(ctx, message.Token)
		if err != nil {
			return err
		}
		if identity.User.ID != s.identity.User.ID {
			return errors.New("a connection cannot switch users")
		}
		s.identity = identity
		return s.subscribe(ctx, s.requested)
	case clientSubscribe:
		requested := string(message.Scope)
		if message.Scope == scopeUser {
			requested = strconv.FormatInt(message.UserID, 10)
		}
		return s.subscribe(ctx, requested)
	default:
		return s.sendError(ctx, apperr.Invalid("unknown message type %q", message.Type))
	}
}

func (s *eventStream) subscribe(ctx context.Context, requested string) error {
	scope, err := s.api.resolveScope(ctx, s.identity.User, requested)
	if err != nil {
		s.requested = string(scopeMe)
		if err := s.sendSnapshot(ctx, s.subscription.SetScope(activity.Scope{Self: s.identity.User.ID})); err != nil {
			return err
		}
		return s.sendError(ctx, err)
	}
	s.requested = requested
	return s.sendSnapshot(ctx, s.subscription.SetScope(scope))
}

func (s *eventStream) sendSnapshot(ctx context.Context, transfers []activity.LiveTransfer) error {
	return s.send(ctx, eventMessage{Event: activity.Event{Type: activity.EventSnapshot}, Transfers: transfers})
}

func (s *eventStream) sendError(ctx context.Context, err error) error {
	appErr, ok := errors.AsType[*apperr.Error](err)
	if !ok {
		appErr = apperr.New("internal", "%s", err.Error())
	}
	return s.send(ctx, eventMessage{Event: activity.Event{Type: activity.EventError}, Code: appErr.Kind, Message: appErr.Message})
}

func (s *eventStream) send(ctx context.Context, message eventMessage) error {
	writeCtx, cancel := context.WithTimeout(ctx, writeTimeout)
	defer cancel()
	return wsjson.Write(writeCtx, s.conn, message)
}
