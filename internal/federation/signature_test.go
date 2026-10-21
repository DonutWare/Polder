package federation

import (
	"bytes"
	"crypto/rsa"
	"encoding/json"
	"errors"
	"net/http"
	"path/filepath"
	"slices"
	"strings"
	"testing"
	"time"
)

func signedRequest(t *testing.T, key *signingKey, now time.Time, body []byte) *http.Request {
	t.Helper()
	request, err := http.NewRequest(http.MethodPost, "https://polder.example.com/ocm/shares", bytes.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	s := signer{key: key, keyID: "https://nc.example.com/ocm#signature", now: func() time.Time { return now }}
	if err := s.sign(request, body); err != nil {
		t.Fatal(err)
	}
	request.Host = request.URL.Host
	request.RequestURI = request.URL.RequestURI()
	return request
}

func TestSignatureRoundTrip(t *testing.T) {
	keyPath := filepath.Join(t.TempDir(), "federation.key")
	key, err := loadOrCreateSigningKey(keyPath)
	if err != nil {
		t.Fatal(err)
	}
	other, err := loadOrCreateSigningKey(filepath.Join(t.TempDir(), "other.key"))
	if err != nil {
		t.Fatal(err)
	}
	reloaded, err := loadOrCreateSigningKey(keyPath)
	if err != nil || reloaded.publicPEM != key.publicPEM {
		t.Fatalf("the key must survive a restart: %v", err)
	}
	now := time.Now()
	body := []byte(`{"shareWith":"alice@polder.example.com"}`)
	lookup := func(want *signingKey) publicKeyLookup {
		return func(keyID, origin string) (*rsa.PublicKey, error) {
			if keyID != "https://nc.example.com/ocm#signature" || origin != "nc.example.com" {
				return nil, errInvalidSignature
			}
			return &want.private.PublicKey, nil
		}
	}

	verified, err := verifyRequest(signedRequest(t, key, now, body), body, now, lookup(key))
	if err != nil || verified.origin != "nc.example.com" {
		t.Fatalf("valid signature: %+v %v", verified, err)
	}
	if _, err := verifyRequest(signedRequest(t, key, now, body), []byte(`{"shareWith":"mallory"}`), now, lookup(key)); !errors.Is(err, errInvalidSignature) {
		t.Fatalf("tampered body: %v", err)
	}
	if _, err := verifyRequest(signedRequest(t, key, now.Add(-10*time.Minute), body), body, now, lookup(key)); !errors.Is(err, errInvalidSignature) {
		t.Fatalf("stale date: %v", err)
	}
	if _, err := verifyRequest(signedRequest(t, key, now, body), body, now, lookup(other)); !errors.Is(err, errInvalidSignature) {
		t.Fatalf("wrong key: %v", err)
	}
	moved := signedRequest(t, key, now, body)
	moved.URL.Path = "/ocm/notifications"
	if _, err := verifyRequest(moved, body, now, lookup(key)); !errors.Is(err, errInvalidSignature) {
		t.Fatalf("other path: %v", err)
	}
	stripped := signedRequest(t, key, now, body)
	stripped.Header.Set("Signature", strings.Replace(stripped.Header.Get("Signature"), "(request-target) ", "", 1))
	if _, err := verifyRequest(stripped, body, now, lookup(key)); !errors.Is(err, errInvalidSignature) {
		t.Fatalf("request target must be signed: %v", err)
	}
	unsigned, _ := http.NewRequest(http.MethodPost, "https://polder.example.com/ocm/shares", nil)
	if _, err := verifyRequest(unsigned, nil, now, lookup(key)); !errors.Is(err, errUnsigned) {
		t.Fatalf("unsigned: %v", err)
	}
}

func TestSignatureHeaderFormatMatchesNextcloud(t *testing.T) {
	key, err := loadOrCreateSigningKey(filepath.Join(t.TempDir(), "federation.key"))
	if err != nil {
		t.Fatal(err)
	}
	header := signedRequest(t, key, time.Now(), []byte("{}")).Header.Get("Signature")
	if strings.Contains(header, ", ") || !strings.HasPrefix(header, `keyId="https://nc.example.com/ocm#signature",algorithm="rsa-sha512",headers="(request-target) content-length date digest host",signature="`) {
		t.Fatalf("header %s", header)
	}
}

func discoveryFrom(t *testing.T, raw string) remoteDiscovery {
	t.Helper()
	var document remoteDiscovery
	if err := json.Unmarshal([]byte(raw), &document); err != nil {
		t.Fatal(err)
	}
	return document
}

func TestDiscoveryValidation(t *testing.T) {
	ocis := discoveryFrom(t, `{"enabled":true,"apiVersion":"1.2.0","endPoint":"https://cloud.example.com/ocm","provider":"OpenCloud",
		"resourceTypes":[{"name":"file","shareTypes":["user"],"protocols":{"webdav":"/dav/ocm/"}},{"name":"folder","shareTypes":["user"],"protocols":{"webdav":"/dav/ocm/"}}],
		"capabilities":["invites","/invite-accepted","protocol-object"]}`)
	server, err := serverFromDiscovery("cloud.example.com", ocis)
	if err != nil || server.webdavBase() != "https://cloud.example.com/dav/ocm" || !server.supports(resourceFolder) || server.legacyProtocol() || server.SignsRequests {
		t.Fatalf("%+v %v", server, err)
	}
	if !slices.Contains(server.capabilities, "invite-accepted") {
		t.Fatalf("capabilities %v", server.capabilities)
	}

	owncloud := discoveryFrom(t, `{"enabled":true,"apiVersion":"1.0-proposal1","endPoint":"https://oc.example.com/index.php/apps/federatedfilesharing",
		"shareTypes":[{"name":"file","protocols":{"webdav":"/public.php/webdav/"}}]}`)
	server, err = serverFromDiscovery("oc.example.com", owncloud)
	if err != nil || server.webdavBase() != "https://oc.example.com/public.php/webdav" || !server.legacyProtocol() || server.supports(resourceFolder) {
		t.Fatalf("ownCloud: %+v %v", server, err)
	}

	seafileShape := discoveryFrom(t, `{"enabled":true,"apiVersion":"1.0-proposal1","endPoint":"https://sf.example.com/ocm-via-webdav/","resourceTypes":{"name":"file"}}`)
	if _, err := serverFromDiscovery("sf.example.com", seafileShape); err == nil {
		t.Fatal("a server without a WebDAV path must be refused")
	}

	for name, raw := range map[string]string{
		"other host":  `{"enabled":true,"apiVersion":"1.1.0","endPoint":"https://evil.example/ocm","resourceTypes":[{"name":"file","protocols":{"webdav":"/dav/"}}]}`,
		"plain http":  `{"enabled":true,"apiVersion":"1.1.0","endPoint":"http://cloud.example.com/ocm","resourceTypes":[{"name":"file","protocols":{"webdav":"/dav/"}}]}`,
		"foreign key": `{"enabled":true,"apiVersion":"1.1.0","endPoint":"https://cloud.example.com/ocm","resourceTypes":[{"name":"file","protocols":{"webdav":"/dav/"}}],"publicKey":{"keyId":"https://evil.example/ocm#signature","publicKeyPem":"x"}}`,
		"disabled":    `{"enabled":false,"apiVersion":"1.1.0","endPoint":"https://cloud.example.com/ocm","resourceTypes":[{"name":"file","protocols":{"webdav":"/dav/"}}]}`,
	} {
		if _, err := serverFromDiscovery("cloud.example.com", discoveryFrom(t, raw)); err == nil {
			t.Errorf("%s must be refused", name)
		}
	}

	sub, err := serverFromDiscovery("cloud.example.com/nc", ocis)
	if err != nil || sub.webdavBase() != "https://cloud.example.com/nc/dav/ocm" {
		t.Fatalf("subfolder: %+v %v", sub, err)
	}
}

func TestIncomingResourceURL(t *testing.T) {
	server := Server{Remote: "cloud.example.com", ocmEndpoint: "https://cloud.example.com/ocm", webdavPath: "/dav/ocm"}
	for uri, want := range map[string]string{
		"":                                       "https://cloud.example.com/dav/ocm",
		"abc-123":                                "https://cloud.example.com/dav/ocm/abc-123",
		"/remote.php/dav/ocm/abc":                "https://cloud.example.com/remote.php/dav/ocm/abc",
		"https://cloud.example.com/dav/ocm/abc/": "https://cloud.example.com/dav/ocm/abc/",
	} {
		cleaned, ok := cleanWebDAVURI(uri, server)
		row := incomingRow{server: server, webdavURI: cleaned}
		if !ok || row.resourceURL() != want {
			t.Errorf("%q: %q %v, want %q", uri, row.resourceURL(), ok, want)
		}
	}
	for _, uri := range []string{"https://evil.example/dav/ocm/abc", "http://cloud.example.com/dav/ocm/abc", "../../etc", "//evil.example/x",
		"https://user:pass@cloud.example.com/x", "https://cloud.example.com/x?y=1"} {
		if _, ok := cleanWebDAVURI(uri, server); ok {
			t.Errorf("%q must be refused", uri)
		}
	}
}
