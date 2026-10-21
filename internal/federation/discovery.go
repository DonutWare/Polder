package federation

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/url"
	"slices"
	"strings"
	"unicode/utf8"

	"polder-server/internal/apperr"
)

const (
	resourceFile         = "file"
	resourceFolder       = "folder"
	ocmAPIVersion        = "1.1.0"
	ocmPath              = "/ocm"
	publicWebDAVPath     = "/dav/ocm"
	maxDiscoveryBytes    = 64 << 10
	maxProviderNameRunes = 100
	maxRedirects         = 3
)

var discoveryPaths = []string{"/.well-known/ocm", "/ocm-provider/"}

type discoveryDocument struct {
	Enabled       bool               `json:"enabled"`
	APIVersion    string             `json:"apiVersion"`
	Version       string             `json:"version,omitempty"`
	EndPoint      string             `json:"endPoint"`
	Provider      string             `json:"provider,omitempty"`
	ResourceTypes []discoveryResouce `json:"resourceTypes"`
	Capabilities  []string           `json:"capabilities,omitempty"`
	PublicKey     *discoveryKey      `json:"publicKey,omitempty"`
}

type remoteDiscovery struct {
	Enabled       bool            `json:"enabled"`
	APIVersion    string          `json:"apiVersion"`
	Version       string          `json:"version"`
	EndPoint      string          `json:"endPoint"`
	Provider      string          `json:"provider"`
	ResourceTypes json.RawMessage `json:"resourceTypes"`
	ShareTypes    json.RawMessage `json:"shareTypes"`
	Capabilities  json.RawMessage `json:"capabilities"`
	PublicKey     *discoveryKey   `json:"publicKey"`
}

func (d remoteDiscovery) resources() []discoveryResouce {
	var resources []discoveryResouce
	for _, raw := range []json.RawMessage{d.ResourceTypes, d.ShareTypes} {
		var list []discoveryResouce
		if json.Unmarshal(raw, &list) == nil {
			resources = append(resources, list...)
		}
	}
	return resources
}

func (d remoteDiscovery) capabilities() []string {
	var list []string
	if json.Unmarshal(d.Capabilities, &list) != nil {
		return nil
	}
	cleaned := make([]string, 0, len(list))
	for _, capability := range list {
		capability = strings.ToLower(strings.TrimPrefix(strings.TrimSpace(capability), "/"))
		if capability != "" && len(capability) <= 64 && !strings.Contains(capability, ",") {
			cleaned = append(cleaned, capability)
		}
	}
	return cleaned
}

type discoveryResouce struct {
	Name       string            `json:"name"`
	ShareTypes []string          `json:"shareTypes"`
	Protocols  map[string]string `json:"protocols"`
}

type discoveryKey struct {
	KeyID        string `json:"keyId"`
	PublicKeyPEM string `json:"publicKeyPem"`
}

func (s *Service) ownDiscovery() discoveryDocument {
	return discoveryDocument{
		Enabled:    true,
		APIVersion: ocmAPIVersion,
		Version:    ocmAPIVersion,
		EndPoint:   s.publicURL + ocmPath,
		Provider:   "Polder",
		ResourceTypes: []discoveryResouce{
			{Name: resourceFile, ShareTypes: []string{"user"}, Protocols: map[string]string{"webdav": publicWebDAVPath + "/"}},
			{Name: resourceFolder, ShareTypes: []string{"user"}, Protocols: map[string]string{"webdav": publicWebDAVPath + "/"}},
		},
		Capabilities: []string{"invites", "notifications", "protocol-object"},
		PublicKey:    &discoveryKey{KeyID: s.signer.keyID, PublicKeyPEM: s.signer.key.publicPEM},
	}
}

func (s *Service) discover(ctx context.Context, remote string, allowPrivate bool) (Server, error) {
	var failures []error
	for _, path := range discoveryPaths {
		document, err := s.fetchDiscovery(ctx, "https://"+remote+path, allowPrivate)
		if err == nil {
			return serverFromDiscovery(remote, document)
		}
		failures = append(failures, fmt.Errorf("%s: %w", path, err))
	}
	return Server{}, apperr.Unavailable("could not discover federation at %s: %v", remote, errors.Join(failures...))
}

func (s *Service) fetchDiscovery(ctx context.Context, target string, allowPrivate bool) (remoteDiscovery, error) {
	ctx, cancel := withTimeout(ctx)
	defer cancel()
	for range maxRedirects + 1 {
		parsed, err := requireHTTPS(target)
		if err != nil {
			return remoteDiscovery{}, err
		}
		request, err := http.NewRequestWithContext(ctx, http.MethodGet, parsed.String(), nil)
		if err != nil {
			return remoteDiscovery{}, err
		}
		request.Header.Set("Accept", "application/json")
		response, err := s.clients.For(allowPrivate).Do(request)
		if err != nil {
			return remoteDiscovery{}, err
		}
		content, readErr := readLimited(response.Body, maxDiscoveryBytes)
		response.Body.Close()
		if location := response.Header.Get("Location"); response.StatusCode >= 300 && response.StatusCode < 400 && location != "" {
			next, err := parsed.Parse(location)
			if err != nil || !sameHost(next.Host, parsed.Host) {
				return remoteDiscovery{}, errors.New("discovery redirects to another server")
			}
			target = next.String()
			continue
		}
		if readErr != nil {
			return remoteDiscovery{}, readErr
		}
		if response.StatusCode != http.StatusOK {
			return remoteDiscovery{}, describeStatus(response)
		}
		var document remoteDiscovery
		if err := json.Unmarshal(content, &document); err != nil {
			return remoteDiscovery{}, errors.New("discovery is not valid JSON")
		}
		return document, nil
	}
	return remoteDiscovery{}, errors.New("too many redirects")
}

func serverFromDiscovery(remote string, document remoteDiscovery) (Server, error) {
	invalid := func(reason string) (Server, error) {
		return Server{}, apperr.Unavailable("%s has unusable federation discovery: %s", remote, reason)
	}
	if !document.Enabled {
		return invalid("federation is disabled there")
	}
	apiVersion := cleanProvider(firstNonEmpty(document.APIVersion, document.Version))
	if apiVersion == "" {
		return invalid("no API version")
	}
	host, _, _ := strings.Cut(remote, "/")
	endPoint, err := url.Parse(document.EndPoint)
	if err != nil || endPoint.Scheme != "https" || endPoint.User != nil || !sameHost(endPoint.Host, host) {
		return invalid("its endpoint must be an https address on the same server")
	}
	webdavPath, resourceTypes, err := webdavFrom(document.resources(), host)
	if err != nil {
		return invalid(err.Error())
	}
	server := Server{
		Remote:        remote,
		Provider:      cleanProvider(document.Provider),
		APIVersion:    truncate(apiVersion, 32),
		ocmEndpoint:   strings.TrimSuffix(endPoint.String(), "/"),
		webdavPath:    webdavPath,
		resourceTypes: resourceTypes,
		capabilities:  document.capabilities(),
	}
	if document.PublicKey != nil && document.PublicKey.KeyID != "" && document.PublicKey.PublicKeyPEM != "" {
		origin, err := signatureOrigin(document.PublicKey.KeyID)
		if err != nil || !sameHost(origin, host) {
			return invalid("its signing key does not belong to the server")
		}
		if _, err := parsePublicKey(document.PublicKey.PublicKeyPEM); err != nil {
			return invalid(err.Error())
		}
		server.keyID = document.PublicKey.KeyID
		server.publicKeyPEM = document.PublicKey.PublicKeyPEM
	}
	return server, nil
}

func webdavFrom(resources []discoveryResouce, host string) (string, []string, error) {
	path := ""
	var names []string
	for _, resource := range resources {
		if resource.Name != resourceFile && resource.Name != resourceFolder {
			continue
		}
		raw := resource.Protocols["webdav"]
		if raw == "" {
			continue
		}
		parsed, err := url.Parse(raw)
		if err != nil || (parsed.Host != "" && !sameHost(parsed.Host, host)) || parsed.RawQuery != "" {
			return "", nil, errors.New("its WebDAV address is not on the same server")
		}
		clean := "/" + strings.Trim(parsed.Path, "/")
		if hasDotSegment(clean) {
			return "", nil, errors.New("its WebDAV address is invalid")
		}
		if path == "" {
			path = clean
		}
		if !slices.Contains(names, resource.Name) {
			names = append(names, resource.Name)
		}
	}
	if path == "" {
		return "", nil, errors.New("it does not offer file sharing over WebDAV")
	}
	return path, names, nil
}

func (s Server) supports(resourceType string) bool {
	return slices.Contains(s.resourceTypes, resourceType)
}

func (s Server) legacyProtocol() bool {
	return strings.HasPrefix(s.APIVersion, "1.0")
}

func cleanProvider(provider string) string {
	provider = strings.Map(func(r rune) rune {
		if r < 0x20 || r == 0x7f {
			return -1
		}
		return r
	}, strings.TrimSpace(provider))
	if utf8.RuneCountInString(provider) > maxProviderNameRunes {
		provider = string([]rune(provider)[:maxProviderNameRunes])
	}
	return provider
}

func (s Server) webdavBase() string {
	endPoint, err := url.Parse(s.ocmEndpoint)
	if err != nil {
		return ""
	}
	path := s.webdavPath
	if _, prefix, found := strings.Cut(s.Remote, "/"); found && !strings.HasPrefix(path, "/"+prefix) {
		path = "/" + prefix + path
	}
	return "https://" + endPoint.Host + strings.TrimSuffix(path, "/")
}
