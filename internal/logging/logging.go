package logging

import (
	"context"
	"io"
	"log/slog"
	"slices"
	"time"
)

const (
	componentKey = "component"
	timeLayout   = "2006-01-02T15:04:05.000Z07:00"
)

// For returns a logger that tags every record with component. It looks up the default logger
// on each call, so packages can create theirs before Setup runs.
func For(component string) *slog.Logger {
	return slog.New(deferredHandler{attrs: []slog.Attr{slog.String(componentKey, component)}})
}

type deferredHandler struct {
	attrs []slog.Attr
}

func (h deferredHandler) Enabled(ctx context.Context, level slog.Level) bool {
	return slog.Default().Handler().Enabled(ctx, level)
}

func (h deferredHandler) Handle(ctx context.Context, record slog.Record) error {
	return slog.Default().Handler().WithAttrs(h.attrs).Handle(ctx, record)
}

func (h deferredHandler) WithAttrs(attrs []slog.Attr) slog.Handler {
	return deferredHandler{attrs: append(slices.Clip(h.attrs), attrs...)}
}

func (h deferredHandler) WithGroup(name string) slog.Handler {
	return slog.Default().Handler().WithAttrs(h.attrs).WithGroup(name)
}

// Setup makes the default logger write readable text to console and JSON lines to a file per
// day in dir, which Files reads back.
func Setup(dir string, level slog.Level, console io.Writer) (io.Closer, error) {
	file, err := newDailyFile(dir, time.Now)
	if err != nil {
		return nil, err
	}
	options := &slog.HandlerOptions{Level: level}
	slog.SetDefault(slog.New(slog.NewMultiHandler(
		slog.NewTextHandler(console, options),
		slog.NewJSONHandler(file, &slog.HandlerOptions{Level: level, ReplaceAttr: fixedTime}),
	)))
	return file, nil
}

// fixedTime writes times with milliseconds and the UTC offset, a layout tools such as fail2ban
// can parse, unlike the up to nine fraction digits slog writes by default.
func fixedTime(groups []string, attr slog.Attr) slog.Attr {
	if attr.Key == slog.TimeKey && len(groups) == 0 && attr.Value.Kind() == slog.KindTime {
		return slog.String(slog.TimeKey, attr.Value.Time().Format(timeLayout))
	}
	return attr
}
