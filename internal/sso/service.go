package sso

import (
	"database/sql"
	"net/http"
	"sync"
	"time"

	"polder-server/internal/auth"
	"polder-server/internal/logging"
	"polder-server/internal/secretbox"
	"polder-server/internal/users"
)

const (
	SecretKeyPurpose = "sso-client-secrets"
	providerTimeout  = 15 * time.Second
)

var logger = logging.For("sso")

type Service struct {
	db         *sql.DB
	box        *secretbox.Box
	users      *users.Service
	auth       *auth.Service
	publicURL  string
	client     *http.Client
	now        func() time.Time
	mu         sync.Mutex
	connectors map[string]connector
}

type Options struct {
	PublicURL string
	SecretKey []byte
}

func NewService(db *sql.DB, userService *users.Service, authService *auth.Service, options Options) (*Service, error) {
	box, err := secretbox.New(options.SecretKey)
	if err != nil {
		return nil, err
	}
	return &Service{
		db:         db,
		box:        box,
		users:      userService,
		auth:       authService,
		publicURL:  options.PublicURL,
		client:     &http.Client{Timeout: providerTimeout},
		now:        time.Now,
		connectors: map[string]connector{},
	}, nil
}

func (s *Service) Configured() bool {
	return s.publicURL != ""
}
