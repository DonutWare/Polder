package federation

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"errors"
	"strings"
	"time"

	"polder-server/internal/apperr"
	"polder-server/internal/database"
)

type Server struct {
	ID                  int64      `json:"id"`
	Remote              string     `json:"remote" doc:"The server's address, such as cloud.example.com"`
	Provider            string     `json:"provider" doc:"The software the server says it runs"`
	KeyFingerprint      string     `json:"keyFingerprint" doc:"SHA-256 of the server's signing key; empty when it publishes none"`
	AllowPrivateNetwork bool       `json:"allowPrivateNetwork" doc:"Whether the server may be reached on a private or local network address"`
	VerifySenderAddress bool       `json:"verifySenderAddress" doc:"Whether unsigned requests must come from an address the server's name resolves to"`
	SignsRequests       bool       `json:"signsRequests" doc:"Whether the server signs its requests; then unsigned requests from it are refused"`
	APIVersion          string     `json:"apiVersion" doc:"The OCM version the server reports"`
	CreatedAt           time.Time  `json:"createdAt"`
	DiscoveredAt        *time.Time `json:"discoveredAt,omitempty" required:"false"`

	ocmEndpoint   string
	webdavPath    string
	keyID         string
	publicKeyPEM  string
	resourceTypes []string
	capabilities  []string
}

const serverColumns = `id, remote, provider, ocm_endpoint, webdav_path, key_id, public_key_pem, api_version, resource_types, capabilities,
	allow_private_network, verify_sender_address, created_at, discovered_at`

func scanServer(row database.RowScanner) (Server, error) {
	var server Server
	var createdAt int64
	var discoveredAt sql.NullInt64
	var resourceTypes, capabilities string
	err := row.Scan(&server.ID, &server.Remote, &server.Provider, &server.ocmEndpoint, &server.webdavPath, &server.keyID,
		&server.publicKeyPEM, &server.APIVersion, &resourceTypes, &capabilities, &server.AllowPrivateNetwork, &server.VerifySenderAddress,
		&createdAt, &discoveredAt)
	if err != nil {
		return Server{}, err
	}
	server.resourceTypes = splitList(resourceTypes)
	server.capabilities = splitList(capabilities)
	server.SignsRequests = server.publicKeyPEM != ""
	server.CreatedAt = time.Unix(createdAt, 0)
	if discoveredAt.Valid {
		discovered := time.Unix(discoveredAt.Int64, 0)
		server.DiscoveredAt = &discovered
	}
	server.KeyFingerprint = fingerprint(server.publicKeyPEM)
	return server, nil
}

func splitList(joined string) []string {
	if joined == "" {
		return nil
	}
	return strings.Split(joined, ",")
}

func fingerprint(publicKeyPEM string) string {
	if publicKeyPEM == "" {
		return ""
	}
	sum := sha256.Sum256([]byte(publicKeyPEM))
	return hex.EncodeToString(sum[:])
}

type serverStore struct {
	db *sql.DB
}

func (s serverStore) list(ctx context.Context) ([]Server, error) {
	return database.QueryAll(ctx, s.db, scanServer, `SELECT `+serverColumns+` FROM federation_servers ORDER BY remote`)
}

func (s serverStore) byID(ctx context.Context, id int64) (Server, error) {
	server, err := scanServer(s.db.QueryRowContext(ctx, `SELECT `+serverColumns+` FROM federation_servers WHERE id = $1`, id))
	if errors.Is(err, sql.ErrNoRows) {
		return Server{}, apperr.NotFound("no such trusted server")
	}
	return server, err
}

func (s serverStore) byRemote(ctx context.Context, remote string) (Server, error) {
	server, err := scanServer(s.db.QueryRowContext(ctx, `SELECT `+serverColumns+` FROM federation_servers WHERE remote = $1`, remote))
	if errors.Is(err, sql.ErrNoRows) {
		return Server{}, apperr.Forbidden("%s is not a trusted server", truncate(remote, 80))
	}
	return server, err
}

func (s serverStore) insert(ctx context.Context, server Server, addedBy int64) (Server, error) {
	now := time.Now().Unix()
	err := s.db.QueryRowContext(ctx,
		`INSERT INTO federation_servers (remote, provider, ocm_endpoint, webdav_path, key_id, public_key_pem, api_version, resource_types, capabilities,
		 allow_private_network, verify_sender_address, added_by, created_at, discovered_at)
		 VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14) RETURNING id`,
		server.Remote, server.Provider, server.ocmEndpoint, server.webdavPath, server.keyID, server.publicKeyPEM, server.APIVersion,
		strings.Join(server.resourceTypes, ","), strings.Join(server.capabilities, ","), server.AllowPrivateNetwork, server.VerifySenderAddress,
		database.NullIfZero(addedBy), now, now).Scan(&server.ID)
	if database.IsUniqueViolation(err) {
		return Server{}, apperr.AlreadyExists("%s is already trusted", server.Remote)
	}
	if err != nil {
		return Server{}, err
	}
	return s.byID(ctx, server.ID)
}

func (s serverStore) updateDiscovery(ctx context.Context, server Server) error {
	_, err := s.db.ExecContext(ctx,
		`UPDATE federation_servers SET provider = $1, ocm_endpoint = $2, webdav_path = $3, key_id = $4, public_key_pem = $5, api_version = $6,
		 resource_types = $7, capabilities = $8, discovered_at = $9 WHERE id = $10`,
		server.Provider, server.ocmEndpoint, server.webdavPath, server.keyID, server.publicKeyPEM, server.APIVersion,
		strings.Join(server.resourceTypes, ","), strings.Join(server.capabilities, ","), time.Now().Unix(), server.ID)
	return err
}

func (s serverStore) remove(ctx context.Context, id int64) error {
	return database.RequireAffected(apperr.NotFound("no such trusted server"))(
		s.db.ExecContext(ctx, `DELETE FROM federation_servers WHERE id = $1`, id))
}
