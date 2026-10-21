package federation

import (
	"bytes"
	"context"
	"crypto/x509"
	"database/sql"
	"encoding/json"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/files"
	"polder-server/internal/logging"
	"polder-server/internal/settings"
	"polder-server/internal/users"
)

var logger = logging.For("federation")

const maxOCMResponseBytes = 64 << 10

type Options struct {
	PublicURL string
	KeyPath   string
	SecretKey []byte
	RootCAs   *x509.CertPool
}

type Service struct {
	db         *sql.DB
	files      *files.Service
	users      *users.Store
	settings   *settings.Store
	servers    serverStore
	clients    *Clients
	signer     signer
	box        *secretBox
	publicURL  string
	publicHost string
	now        func() time.Time
	resolver   resolver
	outboxWake chan struct{}
}

func New(db *sql.DB, fileService *files.Service, userStore *users.Store, settingsStore *settings.Store, options Options) (*Service, error) {
	box, err := newSecretBox(options.SecretKey)
	if err != nil {
		return nil, err
	}
	service := &Service{
		db: db, files: fileService, users: userStore, settings: settingsStore,
		servers:    serverStore{db: db},
		clients:    NewClients(options.RootCAs),
		box:        box,
		now:        time.Now,
		resolver:   net.DefaultResolver,
		outboxWake: make(chan struct{}, 1),
	}
	if options.PublicURL == "" {
		return service, nil
	}
	parsed, err := url.Parse(options.PublicURL)
	if err != nil {
		return nil, err
	}
	key, err := loadOrCreateSigningKey(options.KeyPath)
	if err != nil {
		return nil, err
	}
	service.publicURL = strings.TrimSuffix(options.PublicURL, "/")
	service.publicHost = strings.ToLower(parsed.Host)
	service.signer = signer{key: key, keyID: service.publicURL + ocmPath + "#signature", now: service.now}
	return service, nil
}

func (s *Service) Configured() bool {
	return s.publicURL != ""
}

func (s *Service) Enabled(ctx context.Context) bool {
	if !s.Configured() {
		return false
	}
	current, err := s.settings.Get(ctx)
	if err != nil {
		logger.Warn("load federation setting", "error", err)
		return false
	}
	return current.FederationEnabled
}

func (s *Service) requireEnabled(ctx context.Context) error {
	if !s.Configured() {
		return apperr.Unavailable("federation needs publicUrl in the server config")
	}
	if !s.Enabled(ctx) {
		return apperr.Forbidden("federation is turned off on this server")
	}
	return nil
}

func (s *Service) CloudID(user users.User) string {
	return s.localCloudID(user)
}

func (s *Service) localCloudID(user users.User) string {
	return user.Username + "@" + s.publicHost
}

func (s *Service) Servers(ctx context.Context) ([]Server, error) {
	return s.servers.list(ctx)
}

type ServerOptions struct {
	AllowPrivateNetwork bool `json:"allowPrivateNetwork,omitempty" required:"false" doc:"Allow reaching the server on a private or local network address"`
	SkipAddressCheck    bool `json:"skipAddressCheck,omitempty" required:"false" doc:"Accept unsigned requests from any address, not only from addresses the server's name resolves to"`
}

func (s *Service) AddServer(ctx context.Context, actor users.User, rawRemote string, options ServerOptions) (Server, error) {
	allowPrivate := options.AllowPrivateNetwork
	if !s.Configured() {
		return Server{}, apperr.Unavailable("federation needs publicUrl in the server config")
	}
	remote, err := NormalizeRemote(rawRemote)
	if err != nil {
		return Server{}, err
	}
	if host, _, _ := strings.Cut(remote, "/"); sameHost(host, s.publicHost) {
		return Server{}, apperr.Invalid("this is this server's own address")
	}
	discovered, err := s.discover(ctx, remote, allowPrivate)
	if err != nil {
		return Server{}, err
	}
	discovered.AllowPrivateNetwork = allowPrivate
	discovered.VerifySenderAddress = !options.SkipAddressCheck
	added, err := s.servers.insert(ctx, discovered, actor.ID)
	if err == nil {
		logger.Info("trusted server added", "remote", added.Remote, "provider", added.Provider, "key", added.KeyFingerprint, "by", actor.Username)
	}
	return added, err
}

func (s *Service) RefreshServer(ctx context.Context, actor users.User, id int64) (Server, error) {
	current, err := s.servers.byID(ctx, id)
	if err != nil {
		return Server{}, err
	}
	discovered, err := s.discover(ctx, current.Remote, current.AllowPrivateNetwork)
	if err != nil {
		return Server{}, err
	}
	discovered.ID = current.ID
	if err := s.servers.updateDiscovery(ctx, discovered); err != nil {
		return Server{}, err
	}
	refreshed, err := s.servers.byID(ctx, id)
	if err == nil && refreshed.KeyFingerprint != current.KeyFingerprint {
		logger.Warn("trusted server's signing key changed", "remote", current.Remote, "old", current.KeyFingerprint, "new", refreshed.KeyFingerprint, "by", actor.Username)
	}
	return refreshed, err
}

func (s *Service) UpdateServer(ctx context.Context, actor users.User, id int64, options ServerOptions) (Server, error) {
	if _, err := s.db.ExecContext(ctx, `UPDATE federation_servers SET allow_private_network = $1, verify_sender_address = $2 WHERE id = $3`,
		options.AllowPrivateNetwork, !options.SkipAddressCheck, id); err != nil {
		return Server{}, err
	}
	updated, err := s.servers.byID(ctx, id)
	if err == nil {
		logger.Info("trusted server changed", "remote", updated.Remote, "allowPrivateNetwork", updated.AllowPrivateNetwork,
			"verifySenderAddress", updated.VerifySenderAddress, "by", actor.Username)
	}
	return updated, err
}

func (s *Service) RemoveServer(ctx context.Context, actor users.User, id int64) error {
	current, err := s.servers.byID(ctx, id)
	if err != nil {
		return err
	}
	if err := s.servers.remove(ctx, id); err != nil {
		return err
	}
	logger.Info("trusted server removed; its federated shares are gone", "remote", current.Remote, "by", actor.Username)
	return nil
}

type ocmResponse struct {
	status int
	body   []byte
}

func (s *Service) postOCM(ctx context.Context, server Server, path string, payload any) (ocmResponse, error) {
	body, err := json.Marshal(payload)
	if err != nil {
		return ocmResponse{}, err
	}
	target, err := requireHTTPS(server.ocmEndpoint + path)
	if err != nil {
		return ocmResponse{}, err
	}
	ctx, cancel := withTimeout(ctx)
	defer cancel()
	request, err := http.NewRequestWithContext(ctx, http.MethodPost, target.String(), bytes.NewReader(body))
	if err != nil {
		return ocmResponse{}, err
	}
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")
	if err := s.signer.sign(request, body); err != nil {
		return ocmResponse{}, err
	}
	response, err := s.clients.For(server.AllowPrivateNetwork).Do(request)
	if err != nil {
		return ocmResponse{}, err
	}
	defer response.Body.Close()
	content, err := readLimited(response.Body, maxOCMResponseBytes)
	if err != nil {
		return ocmResponse{}, err
	}
	return ocmResponse{status: response.StatusCode, body: content}, nil
}

func remoteMessage(body []byte) string {
	var parsed struct {
		Message string `json:"message"`
	}
	if json.Unmarshal(body, &parsed) != nil || parsed.Message == "" {
		return ""
	}
	return truncate(cleanProvider(parsed.Message), 200)
}
