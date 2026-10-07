package httpapi

import (
	"context"
	"errors"
	"io/fs"
	"log/slog"
	"net/http"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"

	"polder-server/internal/apperr"
	"polder-server/internal/logging"
)

type logsInput struct {
	Level     string `query:"level" default:"debug" enum:"debug,info,warn,error" doc:"Leave out entries below this level"`
	Component string `query:"component" doc:"Only entries from this part of the server"`
	Query     string `query:"q" doc:"Only entries whose message or attributes contain this text, ignoring case"`
	Before    string `query:"before" doc:"Cursor from the previous page; empty starts at the newest"`
	Limit     int    `query:"limit" default:"100" doc:"Maximum number of entries to return; the server caps it"`
}

type logComponents struct {
	Components []string `json:"components" doc:"Parts of the server that appear in the log files"`
}

type logFiles struct {
	Files []logging.ServerLogFile `json:"files"`
}

type logFilePath struct {
	Name string `path:"name"`
}

func (a *API) listLogs(_ context.Context, input *logsInput) (*jsonBody[logging.ServerLogPage], error) {
	var level slog.Level
	if err := level.UnmarshalText([]byte(input.Level)); err != nil {
		return nil, apperr.Invalid("unknown level %q", input.Level)
	}
	page, err := a.logs.Read(logging.Query{
		MinLevel:  level,
		Component: input.Component,
		Text:      input.Query,
		Before:    input.Before,
		Limit:     input.Limit,
	})
	if errors.Is(err, logging.ErrInvalidCursor) {
		return nil, apperr.Invalid("before is not a cursor from this log")
	}
	if err != nil {
		return nil, err
	}
	return respond(page), nil
}

func (a *API) listLogComponents(context.Context, *struct{}) (*jsonBody[logComponents], error) {
	components, err := a.logs.Components()
	if err != nil {
		return nil, err
	}
	return respond(logComponents{Components: components}), nil
}

func (a *API) listLogFiles(context.Context, *struct{}) (*jsonBody[logFiles], error) {
	list, err := a.logs.List()
	if err != nil {
		return nil, err
	}
	return respond(logFiles{Files: list}), nil
}

func (a *API) downloadLogFile(_ context.Context, input *logFilePath) (*attachmentOutput, error) {
	file, err := a.logs.Open(input.Name)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, apperr.NotFound("no such log file")
	}
	if err != nil {
		return nil, err
	}
	info, err := file.Stat()
	if err != nil {
		file.Close()
		return nil, err
	}
	return &attachmentOutput{
		ContentType:        "application/x-ndjson",
		ContentDisposition: attachment(input.Name),
		Body: func(ctx huma.Context) {
			defer file.Close()
			r, w := humachi.Unwrap(ctx)
			http.ServeContent(w, r, input.Name, info.ModTime(), file)
		},
	}, nil
}
