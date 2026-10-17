package httpapi

import (
	"context"
	"net"
	"net/http"
	"net/netip"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/users"
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
		identity, err := a.auth.Authenticate(ctx.Context(), token)
		if err != nil {
			writeError(api, ctx, err)
			return
		}
		noteUsername(ctx.Context(), identity.User.Username)
		ctx = huma.WithValue(ctx, currentUserKey, identity.User)
		next(huma.WithContext(ctx, activity.WithActor(ctx.Context(), activity.Actor{SessionID: identity.SessionID, Device: identity.Device})))
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

func (l *failedAttemptLimiter) attempt(keys ...string) (func(failed bool), bool) {
	if l.limit <= 0 {
		return func(bool) {}, true
	}
	l.mu.Lock()
	defer l.mu.Unlock()
	now := time.Now()
	for _, key := range keys {
		l.failures[key] = recentOnly(l.failures[key], now.Add(-l.window))
		if len(l.failures[key]) >= l.limit {
			return nil, false
		}
	}
	for _, key := range keys {
		l.failures[key] = append(l.failures[key], now)
	}
	return func(failed bool) {
		if !failed {
			l.forget(keys, now)
		}
	}, true
}

func (l *failedAttemptLimiter) forget(keys []string, reserved time.Time) {
	l.mu.Lock()
	defer l.mu.Unlock()
	for _, key := range keys {
		moments := l.failures[key]
		if index := slices.Index(moments, reserved); index >= 0 {
			l.failures[key] = slices.Delete(moments, index, index+1)
		}
	}
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

// forwardedClient sets the remote address of a request that came through a trusted proxy to the
// client the proxy names, so rate limits and logs see the client instead of the proxy.
func forwardedClient(trusted []netip.Prefix) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		if len(trusted) == 0 {
			return next
		}
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if client, ok := clientBehind(r, trusted); ok {
				r = r.WithContext(r.Context())
				r.RemoteAddr = client
			}
			next.ServeHTTP(w, r)
		})
	}
}

// clientBehind reads X-Forwarded-For from the right, where the nearest proxy added its peer: the
// first address that is not a trusted proxy is the client. Anything further left was sent by the
// client and could be forged.
func clientBehind(r *http.Request, trusted []netip.Prefix) (string, bool) {
	peer, err := parseHop(clientAddress(r.RemoteAddr))
	if err != nil || !isTrusted(peer, trusted) {
		return "", false
	}
	var hops []string
	for _, header := range r.Header.Values("X-Forwarded-For") {
		for hop := range strings.SplitSeq(header, ",") {
			if hop = strings.TrimSpace(hop); hop != "" {
				hops = append(hops, hop)
			}
		}
	}
	for i := len(hops) - 1; i >= 0; i-- {
		address, err := parseHop(hops[i])
		if err != nil {
			return "", false
		}
		if !isTrusted(address, trusted) || i == 0 {
			return address.String(), true
		}
	}
	if address, err := parseHop(strings.TrimSpace(r.Header.Get("X-Real-IP"))); err == nil {
		return address.String(), true
	}
	return "", false
}

func parseHop(hop string) (netip.Addr, error) {
	address, err := netip.ParseAddr(hop)
	if err != nil {
		addressPort, portErr := netip.ParseAddrPort(hop)
		if portErr != nil {
			return netip.Addr{}, err
		}
		address = addressPort.Addr()
	}
	return address.Unmap(), nil
}

func isTrusted(address netip.Addr, trusted []netip.Prefix) bool {
	for _, prefix := range trusted {
		if prefix.Contains(address) {
			return true
		}
	}
	return false
}
