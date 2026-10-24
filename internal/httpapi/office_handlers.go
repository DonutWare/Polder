package httpapi

import (
	"context"

	"polder-server/internal/apperr"
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
	user := currentUser(ctx)
	at, err := a.mountAt(ctx, user, input.Body.Path)
	if err != nil {
		return nil, err
	}
	var session office.EditorSession
	switch {
	case at == nil:
		session, err = a.office.StartSession(ctx, user, input.Body.Path, input.Body.Origin, input.Body.VersionID)
	case input.Body.VersionID != 0:
		return nil, apperr.Invalid("earlier versions of shared files cannot be opened")
	case at.federated():
		session, err = a.office.StartRemoteSession(ctx, user, at.mount.ShareID, at.relative, input.Body.Origin)
	default:
		session, err = a.startSharedOfficeSession(ctx, *at, input.Body.Origin)
	}
	if err != nil {
		return nil, err
	}
	return respond(session), nil
}

func (a *API) startSharedOfficeSession(ctx context.Context, at mountedPath, origin string) (_ office.EditorSession, err error) {
	ctx, access, err := a.recipientAccess(ctx, at.mount.ShareID)
	if err != nil {
		return office.EditorSession{}, err
	}
	defer access.Scrub(&err)
	absolute, err := access.Path(at.relative)
	if err != nil {
		return office.EditorSession{}, err
	}
	return a.office.StartSharedSession(ctx, access.Owner, currentUser(ctx), at.mount.ShareID, absolute, origin, !access.CanEdit)
}
