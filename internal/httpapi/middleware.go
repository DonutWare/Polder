package httpapi

import (
	"context"
	"net"
	"strings"
	"sync"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"nomad-server/internal/apperr"
	"nomad-server/internal/users"
)

type contextKey string

const currentUserKey contextKey = "currentUser"

// requireUser lets only requests with a valid access token through, and makes their user available
// to handlers through currentUser.
func (a *API) requireUser(api huma.API) func(huma.Context, func(huma.Context)) {
	return func(ctx huma.Context, next func(huma.Context)) {
		token, found := strings.CutPrefix(ctx.Header("Authorization"), "Bearer ")
		if !found || token == "" {
			writeError(api, ctx, apperr.Unauthorized("missing bearer token"))
			return
		}
		user, err := a.auth.Authenticate(ctx.Context(), token)
		if err != nil {
			writeError(api, ctx, err)
			return
		}
		next(huma.WithValue(ctx, currentUserKey, user))
	}
}

func requireAdmin(api huma.API) func(huma.Context, func(huma.Context)) {
	return func(ctx huma.Context, next func(huma.Context)) {
		if !currentUser(ctx.Context()).IsAdmin() {
			writeError(api, ctx, apperr.Forbidden("administrator role required"))
			return
		}
		next(ctx)
	}
}

func currentUser(ctx context.Context) users.User {
	user, _ := ctx.Value(currentUserKey).(users.User)
	return user
}

type failedAttemptLimiter struct {
	mu       sync.Mutex
	limit    int
	window   time.Duration
	failures map[string][]time.Time
}

func newFailedAttemptLimiter(limitPerMinute int) *failedAttemptLimiter {
	return &failedAttemptLimiter{limit: limitPerMinute, window: time.Minute, failures: map[string][]time.Time{}}
}

func (l *failedAttemptLimiter) allowed(key string) bool {
	if l.limit <= 0 {
		return true
	}
	l.mu.Lock()
	defer l.mu.Unlock()
	l.failures[key] = recentOnly(l.failures[key], time.Now().Add(-l.window))
	return len(l.failures[key]) < l.limit
}

func (l *failedAttemptLimiter) recordFailure(key string) {
	l.mu.Lock()
	defer l.mu.Unlock()
	l.failures[key] = append(l.failures[key], time.Now())
}

func recentOnly(moments []time.Time, cutoff time.Time) []time.Time {
	recent := moments[:0]
	for _, moment := range moments {
		if moment.After(cutoff) {
			recent = append(recent, moment)
		}
	}
	return recent
}

func clientAddress(remoteAddr string) string {
	host, _, err := net.SplitHostPort(remoteAddr)
	if err != nil {
		return remoteAddr
	}
	return host
}
