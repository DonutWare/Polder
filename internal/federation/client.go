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
	"net/netip"
	"net/url"
	"strings"
	"syscall"
	"time"
)

const (
	dialTimeout           = 10 * time.Second
	tlsHandshakeTimeout   = 10 * time.Second
	responseHeaderTimeout = 30 * time.Second
	apiCallTimeout        = 30 * time.Second
	maxIdleConnections    = 16
)

var (
	errForbiddenAddress = errors.New("the server resolves to an address federation may not reach")
	errNotHTTPS         = errors.New("federation only talks to https addresses")
	errResponseTooLarge = errors.New("the remote server's response is too large")
)

var alwaysForbidden = []netip.Prefix{
	netip.MustParsePrefix("0.0.0.0/8"),
	netip.MustParsePrefix("169.254.0.0/16"),
	netip.MustParsePrefix("192.0.0.0/24"),
	netip.MustParsePrefix("192.0.2.0/24"),
	netip.MustParsePrefix("198.18.0.0/15"),
	netip.MustParsePrefix("198.51.100.0/24"),
	netip.MustParsePrefix("203.0.113.0/24"),
	netip.MustParsePrefix("224.0.0.0/4"),
	netip.MustParsePrefix("240.0.0.0/4"),
	netip.MustParsePrefix("100::/64"),
	netip.MustParsePrefix("2001:db8::/32"),
	netip.MustParsePrefix("fe80::/10"),
	netip.MustParsePrefix("ff00::/8"),
}

var privateUnlessAllowed = []netip.Prefix{
	netip.MustParsePrefix("10.0.0.0/8"),
	netip.MustParsePrefix("100.64.0.0/10"),
	netip.MustParsePrefix("127.0.0.0/8"),
	netip.MustParsePrefix("172.16.0.0/12"),
	netip.MustParsePrefix("192.168.0.0/16"),
	netip.MustParsePrefix("::1/128"),
	netip.MustParsePrefix("fc00::/7"),
}

func addressAllowed(address netip.Addr, allowPrivate bool) bool {
	address = address.Unmap()
	if !address.IsValid() || address.IsUnspecified() {
		return false
	}
	for _, prefix := range alwaysForbidden {
		if prefix.Contains(address) {
			return false
		}
	}
	if allowPrivate {
		return true
	}
	for _, prefix := range privateUnlessAllowed {
		if prefix.Contains(address) {
			return false
		}
	}
	return true
}

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
		Control: func(_, address string, _ syscall.RawConn) error {
			host, _, err := net.SplitHostPort(address)
			if err != nil {
				return err
			}
			ip, err := netip.ParseAddr(host)
			if err != nil || !addressAllowed(ip, allowPrivate) {
				return errForbiddenAddress
			}
			return nil
		},
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
