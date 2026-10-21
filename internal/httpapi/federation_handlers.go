package httpapi

import (
	"context"
	"io"
	"net/http"

	"github.com/danielgtaylor/huma/v2"

	"polder-server/internal/apperr"
	"polder-server/internal/federation"
	"polder-server/internal/logging"
)

var federationLog = logging.For("federation")

type federationStatus struct {
	Enabled    bool   `json:"enabled" doc:"Whether people on trusted servers can be shared with"`
	Configured bool   `json:"configured" doc:"Whether the server has the public address federation needs"`
	CloudID    string `json:"cloudId" doc:"The logged-in user's federated cloud ID; empty when federation is not configured"`
}

type federatedShareID struct {
	ShareID int64 `path:"shareID"`
}

type outgoingFederatedSharesInput struct {
	FileID int64 `query:"fileId" doc:"Only shares of this file or folder; 0 for all"`
}

type updateFederatedShareInput struct {
	ShareID int64 `path:"shareID"`
	Body    federation.OutgoingShareChanges
}

type federatedPathQuery struct {
	ShareID int64  `path:"shareID"`
	Path    string `query:"path" doc:"Path inside the share; / or empty is the shared item itself"`
}

type federatedDownloadInput struct {
	ShareID     int64  `path:"shareID"`
	Path        string `query:"path" doc:"Path inside the share"`
	Range       string `header:"Range" doc:"Byte range to send, such as bytes=0-1023"`
	IfNoneMatch string `header:"If-None-Match"`
}

type federatedUploadInput struct {
	ShareID      int64  `path:"shareID"`
	Path         string `query:"path" doc:"Where to store the file inside the share"`
	MustNotExist bool   `query:"mustNotExist" doc:"Fail instead of replacing an existing file"`
	content      io.Reader
	size         *int64
}

func (i *federatedUploadInput) Resolve(ctx huma.Context) []error {
	i.content, i.size = ctx.BodyReader(), contentLength(ctx)
	return nil
}

type federatedMkdirInput struct {
	ShareID int64 `path:"shareID"`
	Body    pathRequest
}

type federatedMoveInput struct {
	ShareID int64 `path:"shareID"`
	Body    copyRequest
}

type federatedDeleteInput struct {
	ShareID int64  `path:"shareID"`
	Path    string `query:"path"`
}

type remoteListResponse struct {
	Item    federation.RemoteEntry   `json:"item" doc:"The listed folder itself"`
	Entries []federation.RemoteEntry `json:"entries"`
}

type remoteContentOutput struct {
	Status             int
	ContentType        string `header:"Content-Type"`
	ContentLength      string `header:"Content-Length"`
	ContentRange       string `header:"Content-Range"`
	ETag               string `header:"ETag"`
	LastModified       string `header:"Last-Modified"`
	ContentDisposition string `header:"Content-Disposition"`
	NoSniff            string `header:"X-Content-Type-Options"`
	Policy             string `header:"Content-Security-Policy"`
	Body               func(huma.Context)
}

type trustedServerRequest struct {
	Remote string `json:"remote" maxLength:"512" doc:"The server's address, such as cloud.example.com"`
	federation.ServerOptions
}

type updateTrustedServerInput struct {
	ServerID int64 `path:"serverID"`
	Body     federation.ServerOptions
}

type idPath struct {
	ID int64 `path:"id"`
}

type trustedServerPath struct {
	ServerID int64 `path:"serverID"`
}

func (a *API) federationStatus(ctx context.Context, _ *struct{}) (*jsonBody[federationStatus], error) {
	status := federationStatus{Configured: a.federation.Configured(), Enabled: a.federation.Enabled(ctx)}
	if status.Configured {
		status.CloudID = a.federation.CloudID(currentUser(ctx))
	}
	return respond(status), nil
}

func (a *API) listOutgoingFederatedShares(ctx context.Context, input *outgoingFederatedSharesInput) (*jsonBody[[]federation.OutgoingShare], error) {
	list, err := a.federation.Outgoing(ctx, currentUser(ctx), input.FileID)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createFederatedShare(ctx context.Context, input *jsonBody[federation.NewOutgoingShare]) (*jsonBody[federation.OutgoingShare], error) {
	share, err := a.federation.ShareOut(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
	}
	return respond(share), nil
}

func (a *API) updateFederatedShare(ctx context.Context, input *updateFederatedShareInput) (*jsonBody[federation.OutgoingShare], error) {
	share, err := a.federation.UpdateOutgoing(ctx, currentUser(ctx), input.ShareID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(share), nil
}

func (a *API) deleteFederatedShare(ctx context.Context, input *federatedShareID) (*struct{}, error) {
	return nil, a.federation.RemoveOutgoing(ctx, currentUser(ctx), input.ShareID)
}

func (a *API) listIncomingFederatedShares(ctx context.Context, _ *struct{}) (*jsonBody[[]federation.IncomingFederatedShare], error) {
	list, err := a.federation.Incoming(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) acceptFederatedShare(ctx context.Context, input *federatedShareID) (*jsonBody[federation.IncomingFederatedShare], error) {
	share, err := a.federation.AcceptIncoming(ctx, currentUser(ctx), input.ShareID)
	if err != nil {
		return nil, err
	}
	return respond(share), nil
}

func (a *API) removeIncomingFederatedShare(ctx context.Context, input *federatedShareID) (*struct{}, error) {
	return nil, a.federation.RemoveIncoming(ctx, currentUser(ctx), input.ShareID)
}

func (a *API) listFederatedShareFiles(ctx context.Context, input *federatedPathQuery) (*jsonBody[remoteListResponse], error) {
	item, entries, err := a.federation.RemoteList(ctx, currentUser(ctx), input.ShareID, input.Path)
	if err != nil {
		return nil, err
	}
	return respond(remoteListResponse{Item: item, Entries: entries}), nil
}

func (a *API) downloadFederatedShareFile(ctx context.Context, input *federatedDownloadInput) (*remoteContentOutput, error) {
	content, err := a.federation.RemoteOpen(ctx, currentUser(ctx), input.ShareID, input.Path, input.Range, input.IfNoneMatch)
	if err != nil {
		return nil, err
	}
	return &remoteContentOutput{
		Status:             content.Status,
		ContentType:        content.Mime,
		ContentLength:      content.ContentLength,
		ContentRange:       content.ContentRange,
		ETag:               content.ETag,
		LastModified:       content.LastModified,
		ContentDisposition: attachment(content.Name),
		NoSniff:            "nosniff",
		Policy:             sandboxPolicy,
		Body: func(humaCtx huma.Context) {
			defer content.Body.Close()
			if content.Status == http.StatusNotModified {
				return
			}
			if _, err := io.Copy(humaCtx.BodyWriter(), content.Body); err != nil {
				federationLog.Debug("stream a federated file", "error", err)
			}
		},
	}, nil
}

func (a *API) uploadFederatedShareFile(ctx context.Context, input *federatedUploadInput) (*struct{}, error) {
	if input.size == nil {
		return nil, apperr.Invalid("uploads into a federated share need a Content-Length")
	}
	return nil, a.federation.RemoteWrite(ctx, currentUser(ctx), input.ShareID, input.Path, input.content, *input.size, input.MustNotExist)
}

func (a *API) makeFederatedShareDirectory(ctx context.Context, input *federatedMkdirInput) (*struct{}, error) {
	return nil, a.federation.RemoteMkdir(ctx, currentUser(ctx), input.ShareID, input.Body.Path)
}

func (a *API) moveFederatedShareFile(ctx context.Context, input *federatedMoveInput) (*struct{}, error) {
	return nil, a.federation.RemoteMove(ctx, currentUser(ctx), input.ShareID, input.Body.From, input.Body.To, false)
}

func (a *API) copyFederatedShareFile(ctx context.Context, input *federatedMoveInput) (*struct{}, error) {
	return nil, a.federation.RemoteMove(ctx, currentUser(ctx), input.ShareID, input.Body.From, input.Body.To, true)
}

func (a *API) deleteFederatedShareFile(ctx context.Context, input *federatedDeleteInput) (*struct{}, error) {
	return nil, a.federation.RemoteDelete(ctx, currentUser(ctx), input.ShareID, input.Path)
}

func (a *API) listTrustedServers(ctx context.Context, _ *struct{}) (*jsonBody[[]federation.Server], error) {
	list, err := a.federation.Servers(ctx)
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) addTrustedServer(ctx context.Context, input *jsonBody[trustedServerRequest]) (*jsonBody[federation.Server], error) {
	server, err := a.federation.AddServer(ctx, currentUser(ctx), input.Body.Remote, input.Body.ServerOptions)
	if err != nil {
		return nil, err
	}
	return respond(server), nil
}

func (a *API) refreshTrustedServer(ctx context.Context, input *trustedServerPath) (*jsonBody[federation.Server], error) {
	server, err := a.federation.RefreshServer(ctx, currentUser(ctx), input.ServerID)
	if err != nil {
		return nil, err
	}
	return respond(server), nil
}

func (a *API) updateTrustedServer(ctx context.Context, input *updateTrustedServerInput) (*jsonBody[federation.Server], error) {
	server, err := a.federation.UpdateServer(ctx, currentUser(ctx), input.ServerID, input.Body)
	if err != nil {
		return nil, err
	}
	return respond(server), nil
}

func (a *API) listInvites(ctx context.Context, _ *struct{}) (*jsonBody[[]federation.Invite], error) {
	list, err := a.federation.Invites(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) createInvite(ctx context.Context, _ *struct{}) (*jsonBody[federation.Invite], error) {
	invite, err := a.federation.CreateInvite(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(invite), nil
}

func (a *API) revokeInvite(ctx context.Context, input *idPath) (*struct{}, error) {
	return nil, a.federation.RevokeInvite(ctx, currentUser(ctx), input.ID)
}

func (a *API) acceptInvite(ctx context.Context, input *jsonBody[federation.AcceptInviteRequest]) (*jsonBody[federation.Contact], error) {
	contact, err := a.federation.AcceptInvite(ctx, currentUser(ctx), input.Body)
	if err != nil {
		return nil, err
	}
	return respond(contact), nil
}

func (a *API) listContacts(ctx context.Context, _ *struct{}) (*jsonBody[[]federation.Contact], error) {
	list, err := a.federation.Contacts(ctx, currentUser(ctx))
	if err != nil {
		return nil, err
	}
	return respond(list), nil
}

func (a *API) removeContact(ctx context.Context, input *idPath) (*struct{}, error) {
	return nil, a.federation.RemoveContact(ctx, currentUser(ctx), input.ID)
}

func (a *API) removeTrustedServer(ctx context.Context, input *trustedServerPath) (*struct{}, error) {
	return nil, a.federation.RemoveServer(ctx, currentUser(ctx), input.ServerID)
}

type federationGuard struct {
	api *API
}

func (g federationGuard) Blocked(keys ...string) bool {
	return g.api.federationLimiter.blocked(keys...)
}
func (g federationGuard) Fail(keys ...string)         { g.api.federationLimiter.fail(keys...) }
func (g federationGuard) Secure(r *http.Request) bool { return g.api.secureTransport(r) }
