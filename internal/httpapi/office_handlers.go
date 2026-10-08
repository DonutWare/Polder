package httpapi

import (
	"context"

	"polder-server/internal/office"
)

type officeSessionRequest struct {
	Path      string `json:"path" minLength:"1"`
	Origin    string `json:"origin" doc:"The address the client uses for this server, such as https://polder.example.com; the editor page is loaded from it"`
	VersionID int64  `json:"versionId" required:"false" doc:"Open this earlier version of the file, read-only"`
}

func (a *API) officeCapabilities(ctx context.Context, _ *struct{}) (*jsonBody[office.EditorCapabilities], error) {
	return respond(a.office.Capabilities(ctx)), nil
}

func (a *API) startOfficeSession(ctx context.Context, input *jsonBody[officeSessionRequest]) (*jsonBody[office.EditorSession], error) {
	session, err := a.office.StartSession(ctx, currentUser(ctx), input.Body.Path, input.Body.Origin, input.Body.VersionID)
	if err != nil {
		return nil, err
	}
	return respond(session), nil
}
