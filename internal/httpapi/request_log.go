package httpapi

import (
	"context"
	"fmt"
	"log/slog"
	"net/http"
	"runtime/debug"
	"time"

	"github.com/go-chi/chi/v5/middleware"
)

const requestInfoKey contextKey = "requestInfo"

// requestInfo lets requireUser tell logRequests who made the request.
type requestInfo struct {
	username string
}

func noteUsername(ctx context.Context, username string) {
	if info, ok := ctx.Value(requestInfoKey).(*requestInfo); ok {
		info.username = username
	}
}

// logRequests logs every request that changes something or fails; successful reads only at debug
// level, since thumbnails and sync chunks would drown everything else. The query string is left
// out because it can carry tokens.
func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		started := time.Now()
		info := &requestInfo{}
		recorder := middleware.NewWrapResponseWriter(w, r.ProtoMajor)
		next.ServeHTTP(recorder, r.WithContext(context.WithValue(r.Context(), requestInfoKey, info)))

		status := recorder.Status()
		if status == 0 {
			status = http.StatusOK
		}
		level := slog.LevelInfo
		switch {
		case status >= http.StatusInternalServerError:
			level = slog.LevelError
		case status < http.StatusBadRequest && (r.Method == http.MethodGet || r.Method == http.MethodHead):
			level = slog.LevelDebug
		}
		attrs := []slog.Attr{
			slog.String("method", r.Method),
			slog.String("path", r.URL.Path),
			slog.Int("status", status),
			slog.String("duration", time.Since(started).Round(time.Microsecond).String()),
			slog.String("address", clientAddress(r.RemoteAddr)),
		}
		if info.username != "" {
			attrs = append(attrs, slog.String("user", info.username))
		}
		logger.LogAttrs(r.Context(), level, "request", attrs...)
	})
}

func recoverPanics(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			recovered := recover()
			if recovered == nil {
				return
			}
			if recovered == http.ErrAbortHandler {
				panic(recovered)
			}
			logger.Error("panic while handling request", "method", r.Method, "path", r.URL.Path,
				"panic", fmt.Sprint(recovered), "stack", string(debug.Stack()))
			if r.Header.Get("Connection") != "Upgrade" {
				w.WriteHeader(http.StatusInternalServerError)
			}
		}()
		next.ServeHTTP(w, r)
	})
}
