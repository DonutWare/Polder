package httpapi

import (
	"context"

	"polder-server/internal/version"
)

type ServerInfo struct {
	Version     string `json:"version"`
	BuildNumber string `json:"buildNumber"`
}

func (a *API) getServerInfo(context.Context, *struct{}) (*jsonBody[ServerInfo], error) {
	return respond(ServerInfo{
		Version:     version.Current,
		BuildNumber: version.BuildNumber,
	}), nil
}
