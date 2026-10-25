package federation

import (
	"context"
	"crypto/tls"
	"crypto/x509"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"

	"polder-server/internal/netguard"
)

const (
	dialTimeout           = 10 * time.Second
	tlsHandshakeTimeout   = 10 * time.Second
	responseHeaderTimeout = 30 * time.Second
	apiCallTimeout        = 30 * time.Second
	maxIdleConnections    = 16
)

var (
	errNotHTTPS         = errors.New("federation only talks to https addresses")
	errResponseTooLarge = errors.New("the remote server's response is too large")
)

type Clients struct {
	public  *http.Client
	private *http.Client
}

func NewClients(rootCAs *x509.CertPool) *Clients {
	return &Clients{public: newClient(rootCAs, false), private: newClient(rootCAs, true)}
}

func (c *Clients) For(allowPrivate bool) *http.Client {
	if allowPrivate {
		return c.private
	}
	return c.public
}

func newClient(rootCAs *x509.CertPool, allowPrivate bool) *http.Client {
	dialer := &net.Dialer{
		Timeout: dialTimeout,
		Control: netguard.Control(allowPrivate),
	}
	transport := &http.Transport{
		DialContext:           dialer.DialContext,
		TLSClientConfig:       &tls.Config{MinVersion: tls.VersionTLS12, RootCAs: rootCAs},
		TLSHandshakeTimeout:   tlsHandshakeTimeout,
		ResponseHeaderTimeout: responseHeaderTimeout,
		MaxIdleConns:          maxIdleConnections,
		IdleConnTimeout:       90 * time.Second,
		ForceAttemptHTTP2:     true,
	}
	return &http.Client{
		Transport: transport,
		CheckRedirect: func(*http.Request, []*http.Request) error {
			return http.ErrUseLastResponse
		},
	}
}

func requireHTTPS(target string) (*url.URL, error) {
	parsed, err := url.Parse(target)
	if err != nil {
		return nil, err
	}
	if parsed.Scheme != "https" || parsed.Host == "" || parsed.User != nil {
		return nil, errNotHTTPS
	}
	return parsed, nil
}

func readLimited(body io.Reader, limit int64) ([]byte, error) {
	content, err := io.ReadAll(io.LimitReader(body, limit+1))
	if err != nil {
		return nil, err
	}
	if int64(len(content)) > limit {
		return nil, errResponseTooLarge
	}
	return content, nil
}

func withTimeout(ctx context.Context) (context.Context, context.CancelFunc) {
	return context.WithTimeout(ctx, apiCallTimeout)
}

func sameHost(a, b string) bool {
	return strings.EqualFold(strings.TrimSuffix(a, "."), strings.TrimSuffix(b, "."))
}

func describeStatus(response *http.Response) error {
	return fmt.Errorf("remote server answered %s", response.Status)
}
