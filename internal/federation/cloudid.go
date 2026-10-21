package federation

import (
	"net"
	"net/url"
	"regexp"
	"strings"

	"polder-server/internal/apperr"
)

const (
	maxCloudIDLength = 512
	maxUserLength    = 255
)

var (
	remoteUserPattern = regexp.MustCompile(`^[\p{L}\p{N}_.@+'=: -]{1,255}$`)
	hostPattern       = regexp.MustCompile(`^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*(:[0-9]{1,5})?$`)
	pathPattern       = regexp.MustCompile(`^(/[A-Za-z0-9._~-]+)*$`)
)

type CloudID struct {
	User   string
	Remote string
}

func (c CloudID) String() string {
	return c.User + "@" + c.Remote
}

func (c CloudID) Host() string {
	host, _, _ := strings.Cut(c.Remote, "/")
	return host
}

func (c CloudID) BaseURL() string {
	return "https://" + c.Remote
}

func ParseCloudID(raw string) (CloudID, error) {
	raw = strings.TrimSpace(raw)
	invalid := apperr.Invalid("%q is not a federated cloud ID such as alice@cloud.example.com", truncate(raw, 80))
	if raw == "" || len(raw) > maxCloudIDLength {
		return CloudID{}, invalid
	}
	at := strings.LastIndex(raw, "@")
	if at <= 0 || at == len(raw)-1 {
		return CloudID{}, invalid
	}
	user := raw[:at]
	remote, err := NormalizeRemote(raw[at+1:])
	if err != nil || len(user) > maxUserLength || !remoteUserPattern.MatchString(user) {
		return CloudID{}, invalid
	}
	return CloudID{User: user, Remote: remote}, nil
}

func NormalizeRemote(raw string) (string, error) {
	raw = strings.TrimSpace(raw)
	invalid := apperr.Invalid("%q is not a server address", truncate(raw, 80))
	if !strings.Contains(raw, "://") {
		raw = "https://" + raw
	}
	parsed, err := url.Parse(raw)
	if err != nil || parsed.Scheme != "https" || parsed.User != nil || parsed.RawQuery != "" || parsed.Fragment != "" {
		return "", invalid
	}
	host := strings.ToLower(strings.TrimSuffix(parsed.Host, "."))
	if host == "" || (!hostPattern.MatchString(host) && !isIPHost(host)) {
		return "", invalid
	}
	path := strings.TrimSuffix(parsed.Path, "/")
	path = strings.TrimSuffix(path, "/index.php")
	if !pathPattern.MatchString(path) || hasDotSegment(path) {
		return "", invalid
	}
	return host + path, nil
}

func hasDotSegment(path string) bool {
	for _, segment := range strings.Split(path, "/") {
		if segment == "." || segment == ".." {
			return true
		}
	}
	return false
}

func isIPHost(host string) bool {
	hostname := host
	if h, _, err := net.SplitHostPort(host); err == nil {
		hostname = h
	}
	return net.ParseIP(strings.Trim(hostname, "[]")) != nil
}

func truncate(value string, limit int) string {
	if len(value) <= limit {
		return value
	}
	return value[:limit] + "…"
}
