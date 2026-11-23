package app_test

import (
	"cmp"
	"context"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"maps"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/go-jose/go-jose/v4"

	"polder-server/internal/config"
	"polder-server/internal/sso"
)

type fakeIdentity struct {
	Subject       string
	Email         string
	EmailVerified bool
	Username      string
	Name          string
	Tenant        string
	IssuedBy      string
	Extra         map[string]any
}

type fakeGrant struct {
	identity  fakeIdentity
	nonce     string
	challenge string
}

type fakeIdP struct {
	t      *testing.T
	server *httptest.Server
	key    *rsa.PrivateKey
	mu     sync.Mutex
	grants map[string]fakeGrant
}

func startFakeIdP(t *testing.T) *fakeIdP {
	t.Helper()
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	idp := &fakeIdP{t: t, key: key, grants: map[string]fakeGrant{}}
	mux := http.NewServeMux()
	mux.HandleFunc("/.well-known/openid-configuration", idp.discovery)
	mux.HandleFunc("/common/v2.0/.well-known/openid-configuration", idp.tenantDiscovery)
	mux.HandleFunc("/jwks", idp.keys)
	mux.HandleFunc("/token", idp.token)
	mux.HandleFunc("/login/oauth/access_token", idp.gitHubToken)
	mux.HandleFunc("/user", idp.gitHubUser)
	mux.HandleFunc("/user/emails", idp.gitHubEmails)
	idp.server = httptest.NewServer(mux)
	t.Cleanup(idp.server.Close)
	return idp
}

func (f *fakeIdP) discovery(w http.ResponseWriter, _ *http.Request) {
	f.describe(w, f.server.URL)
}

func (f *fakeIdP) tenantDiscovery(w http.ResponseWriter, _ *http.Request) {
	f.describe(w, f.server.URL+"/{tenantid}/v2.0")
}

func (f *fakeIdP) describe(w http.ResponseWriter, issuer string) {
	base := f.server.URL
	_ = json.NewEncoder(w).Encode(map[string]any{
		"issuer":                                issuer,
		"authorization_endpoint":                base + "/authorize",
		"token_endpoint":                        base + "/token",
		"jwks_uri":                              base + "/jwks",
		"userinfo_endpoint":                     base + "/userinfo",
		"id_token_signing_alg_values_supported": []string{"RS256"},
	})
}

func (f *fakeIdP) keys(w http.ResponseWriter, _ *http.Request) {
	_ = json.NewEncoder(w).Encode(jose.JSONWebKeySet{Keys: []jose.JSONWebKey{{Key: &f.key.PublicKey, KeyID: "test", Algorithm: "RS256", Use: "sig"}}})
}

func (f *fakeIdP) grant(authorizeURL string, identity fakeIdentity) (code, state string) {
	f.t.Helper()
	parsed, err := url.Parse(authorizeURL)
	if err != nil {
		f.t.Fatal(err)
	}
	query := parsed.Query()
	if query.Get("code_challenge_method") != "S256" {
		f.t.Fatalf("authorize URL %s has no PKCE", authorizeURL)
	}
	code = strconv.FormatInt(time.Now().UnixNano(), 36)
	f.mu.Lock()
	f.grants[code] = fakeGrant{identity: identity, nonce: query.Get("nonce"), challenge: query.Get("code_challenge")}
	f.mu.Unlock()
	return code, query.Get("state")
}

func (f *fakeIdP) redeem(r *http.Request) (fakeGrant, bool) {
	_ = r.ParseForm()
	f.mu.Lock()
	grant, ok := f.grants[r.Form.Get("code")]
	delete(f.grants, r.Form.Get("code"))
	f.mu.Unlock()
	return grant, ok && pkceOf(r.Form.Get("code_verifier")) == grant.challenge
}

func (f *fakeIdP) token(w http.ResponseWriter, r *http.Request) {
	grant, ok := f.redeem(r)
	if !ok {
		http.Error(w, `{"error":"invalid_grant"}`, http.StatusBadRequest)
		return
	}
	clientID := r.Form.Get("client_id")
	if user, _, found := r.BasicAuth(); found {
		clientID = user
	}
	claims := map[string]any{
		"iss": f.server.URL, "sub": grant.identity.Subject, "aud": clientID, "nonce": grant.nonce,
		"exp": time.Now().Add(time.Minute).Unix(), "iat": time.Now().Unix(),
		"email": grant.identity.Email, "email_verified": grant.identity.EmailVerified,
		"preferred_username": grant.identity.Username, "name": grant.identity.Name,
	}
	if tenant := grant.identity.Tenant; tenant != "" {
		claims["tid"] = tenant
		claims["iss"] = f.server.URL + "/" + cmp.Or(grant.identity.IssuedBy, tenant) + "/v2.0"
	}
	maps.Copy(claims, grant.identity.Extra)
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{"access_token": "access", "token_type": "Bearer", "expires_in": 60, "id_token": f.sign(claims)})
}

func (f *fakeIdP) sign(claims map[string]any) string {
	signer, err := jose.NewSigner(jose.SigningKey{Algorithm: jose.RS256, Key: f.key}, (&jose.SignerOptions{}).WithHeader("kid", "test"))
	if err != nil {
		f.t.Fatal(err)
	}
	payload, _ := json.Marshal(claims)
	signed, err := signer.Sign(payload)
	if err != nil {
		f.t.Fatal(err)
	}
	compact, _ := signed.CompactSerialize()
	return compact
}

func (f *fakeIdP) gitHubToken(w http.ResponseWriter, r *http.Request) {
	grant, ok := f.redeem(r)
	if !ok {
		http.Error(w, `{"error":"bad_verification_code"}`, http.StatusBadRequest)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	_ = json.NewEncoder(w).Encode(map[string]any{"access_token": "gh-" + grant.identity.Subject, "token_type": "bearer"})
}

func (f *fakeIdP) gitHubIdentity(r *http.Request) fakeIdentity {
	subject := strings.TrimPrefix(strings.TrimPrefix(r.Header.Get("Authorization"), "Bearer "), "gh-")
	return fakeIdentity{Subject: subject, Username: "octo-" + subject, Email: "octo" + subject + "@example.com", EmailVerified: true}
}

func (f *fakeIdP) gitHubUser(w http.ResponseWriter, r *http.Request) {
	identity := f.gitHubIdentity(r)
	id, _ := strconv.ParseInt(identity.Subject, 10, 64)
	_ = json.NewEncoder(w).Encode(map[string]any{"id": id, "login": identity.Username, "name": "Octo Cat"})
}

func (f *fakeIdP) gitHubEmails(w http.ResponseWriter, r *http.Request) {
	identity := f.gitHubIdentity(r)
	_ = json.NewEncoder(w).Encode([]map[string]any{{"email": identity.Email, "primary": true, "verified": true}})
}

func pkceOf(verifier string) string {
	sum := sha256.Sum256([]byte(verifier))
	return base64.RawURLEncoding.EncodeToString(sum[:])
}

type ssoProvider struct {
	ID              string `json:"id"`
	ClientSecretSet bool   `json:"clientSecretSet"`
	CallbackURL     string `json:"callbackUrl"`
	ManagedByConfig bool   `json:"managedByConfig"`
	Issuer          string `json:"issuer"`
}

type ssoUser struct {
	Username    string `json:"username"`
	HasPassword bool   `json:"hasPassword"`
	SSO         bool   `json:"sso"`
}

type ssoTokens struct {
	AccessToken string  `json:"accessToken"`
	User        ssoUser `json:"user"`
}

func (s *testServer) withoutRedirects(path string) *http.Response {
	s.t.Helper()
	client := &http.Client{CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse }}
	response, err := client.Get(s.server.URL + "/api/v1" + path)
	if err != nil {
		s.t.Fatal(err)
	}
	response.Body.Close()
	return response
}

type ssoAttempt struct {
	server   *testServer
	verifier string
	location *url.URL
}

func (s *testServer) startSSO(providerID, redirectURI string) ssoAttempt {
	s.t.Helper()
	verifier := strings.Repeat("v", 50) + strconv.FormatInt(time.Now().UnixNano(), 10)
	query := url.Values{"redirect_uri": {redirectURI}, "code_challenge": {pkceOf(verifier)}, "device_name": {"Browser"}}
	response := s.withoutRedirects("/auth/sso/" + providerID + "/authorize?" + query.Encode())
	if response.StatusCode != http.StatusFound {
		s.t.Fatalf("authorize answered %d", response.StatusCode)
	}
	location, _ := url.Parse(response.Header.Get("Location"))
	return ssoAttempt{server: s, verifier: verifier, location: location}
}

func (a ssoAttempt) finish(idp *fakeIdP, providerID string, identity fakeIdentity) *url.URL {
	a.server.t.Helper()
	code, state := idp.grant(a.location.String(), identity)
	response := a.server.withoutRedirects("/auth/sso/" + providerID + "/callback?" + url.Values{"code": {code}, "state": {state}}.Encode())
	if response.StatusCode != http.StatusFound {
		a.server.t.Fatalf("callback answered %d", response.StatusCode)
	}
	location, _ := url.Parse(response.Header.Get("Location"))
	return location
}

func (a ssoAttempt) signIn(idp *fakeIdP, providerID string, identity fakeIdentity) ssoTokens {
	a.server.t.Helper()
	back := a.finish(idp, providerID, identity)
	if back.Query().Get("code") == "" {
		a.server.t.Fatalf("expected a code on %s", back)
	}
	var tokens ssoTokens
	a.server.anonymous().mustJSON(http.MethodPost, "/auth/sso/token",
		map[string]string{"code": back.Query().Get("code"), "codeVerifier": a.verifier}, http.StatusOK, &tokens)
	return tokens
}

func addProvider(admin *client, body map[string]any) ssoProvider {
	var provider ssoProvider
	admin.mustJSON(http.MethodPost, "/admin/auth-providers", body, http.StatusCreated, &provider)
	return provider
}

func TestSingleSignOnCreatesAndSignsInAccounts(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		provider := addProvider(admin, map[string]any{"preset": "pocket-id", "serverUrl": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret"})
		if provider.ID != "pocket-id" || !provider.ClientSecretSet || provider.CallbackURL != "https://cloud.example.com/api/v1/auth/sso/pocket-id/callback" {
			t.Fatalf("unexpected provider %+v", provider)
		}
		var listed []map[string]any
		admin.mustJSON(http.MethodGet, "/admin/auth-providers", nil, http.StatusOK, &listed)
		if _, leaked := listed[0]["clientSecret"]; leaked {
			t.Fatal("the client secret must never be returned")
		}

		var branding struct {
			AuthProviders []struct {
				ID    string `json:"id"`
				Label string `json:"label"`
				Icon  string `json:"icon"`
			} `json:"authProviders"`
		}
		server.anonymous().mustJSON(http.MethodGet, "/branding", nil, http.StatusOK, &branding)
		if len(branding.AuthProviders) != 1 || branding.AuthProviders[0].Label != "Pocket ID" || branding.AuthProviders[0].Icon != "pocket-id" {
			t.Fatalf("branding = %+v", branding.AuthProviders)
		}

		alice := fakeIdentity{Subject: "a-1", Email: "alice@example.com", EmailVerified: true, Username: "Alice", Name: "Alice Example"}
		attempt := server.startSSO("pocket-id", "polder://auth/done")
		back := attempt.finish(idp, "pocket-id", alice)
		if back.Scheme != "polder" || back.Host != "auth" {
			t.Fatalf("redirected to %s", back)
		}
		server.anonymous().mustJSON(http.MethodPost, "/auth/sso/token",
			map[string]string{"code": back.Query().Get("code"), "codeVerifier": "wrong-verifier"}, http.StatusUnauthorized, nil)

		tokens := server.startSSO("pocket-id", "polder://auth").signIn(idp, "pocket-id", alice)
		if tokens.User.Username != "alice" || tokens.User.HasPassword || !tokens.User.SSO {
			t.Fatalf("signed in as %+v", tokens.User)
		}
		again := server.startSSO("pocket-id", "http://127.0.0.1:43123/callback").signIn(idp, "pocket-id", alice)
		if again.User.Username != "alice" {
			t.Fatalf("second sign-in made another account: %+v", again.User)
		}

		session := &client{server: server, token: tokens.AccessToken}
		var identities []struct {
			ID int64 `json:"id"`
		}
		session.mustJSON(http.MethodGet, "/account/identities", nil, http.StatusOK, &identities)
		if len(identities) != 1 {
			t.Fatalf("identities = %+v", identities)
		}
		session.mustJSON(http.MethodDelete, "/account/identities/"+strconv.FormatInt(identities[0].ID, 10), nil, http.StatusForbidden, nil)
		session.mustJSON(http.MethodPut, "/account/password", map[string]string{"currentPassword": "", "newPassword": "alicepass1"}, http.StatusNoContent, nil)
		server.login("alice", "alicepass1")
	})
}

func TestSingleSignOnLinksOnlyVerifiedEmail(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		server.createUserWithEmail(admin, "bob", "bob@example.com", 0)
		addProvider(admin, map[string]any{"preset": "oidc", "issuer": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret", "label": "Company"})

		unverified := fakeIdentity{Subject: "b-1", Email: "bob@example.com", Username: "bobby"}
		back := server.startSSO("company", "polder://auth").finish(idp, "company", unverified)
		if back.Query().Get("error") != sso.FailureSignupDisabled {
			t.Fatalf("an unverified address must not sign in to bob: %s", back)
		}

		verified := unverified
		verified.EmailVerified = true
		tokens := server.startSSO("company", "polder://auth").signIn(idp, "company", verified)
		if tokens.User.Username != "bob" || !tokens.User.HasPassword {
			t.Fatalf("signed in as %+v", tokens.User)
		}

		admin.mustJSON(http.MethodPatch, "/admin/settings", map[string]any{"requireTwoFactor": true, "twoFactorGraceDays": 0}, http.StatusOK, nil)
		ssoSession := &client{server: server, token: tokens.AccessToken}
		ssoSession.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusOK, nil)
		passwordSession := server.login("bob", "password1")
		passwordSession.mustJSON(http.MethodGet, "/files/list?path=/", nil, http.StatusForbidden, nil)
	})
}

func TestSingleSignOnRefusesUnknownRedirects(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		addProvider(admin, map[string]any{"preset": "oidc", "issuer": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret"})
		for _, redirect := range []string{"https://evil.example.com/cb", "polder://share", "http://localhost/cb", "javascript:alert(1)"} {
			query := url.Values{"redirect_uri": {redirect}, "code_challenge": {pkceOf("verifier")}}
			if status := server.withoutRedirects("/auth/sso/openid-connect/authorize?" + query.Encode()).StatusCode; status != http.StatusBadRequest {
				t.Errorf("redirect %s answered %d", redirect, status)
			}
		}
		if status := server.withoutRedirects("/auth/sso/openid-connect/authorize?" + url.Values{"redirect_uri": {"https://cloud.example.com/auth.html"},
			"code_challenge": {pkceOf("verifier")}}.Encode()).StatusCode; status != http.StatusFound {
			t.Errorf("the web app's own address answered %d", status)
		}
	})
}

func TestGitHubNeitherCreatesNorMatchesAccountsByDefault(t *testing.T) {
	idp := startFakeIdP(t)
	t.Cleanup(sso.UseGitHubEndpoints(sso.GitHubEndpoints{
		AuthURL: idp.server.URL + "/login/oauth/authorize", TokenURL: idp.server.URL + "/login/oauth/access_token", APIURL: idp.server.URL,
	}))
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		addProvider(admin, map[string]any{"preset": "github", "clientId": "gh", "clientSecret": "s3cret"})
		back := server.startSSO("github", "polder://auth").finish(idp, "github", fakeIdentity{Subject: "7"})
		if back.Query().Get("error") != sso.FailureSignupDisabled {
			t.Fatalf("GitHub must not create accounts by default: %s", back)
		}
		carol := server.createUserWithEmail(admin, "carol", "octo7@example.com", 0)
		back = server.startSSO("github", "polder://auth").finish(idp, "github", fakeIdentity{Subject: "7"})
		if back.Query().Get("error") != sso.FailureSignupDisabled {
			t.Fatalf("GitHub must not match accounts by email by default: %s", back)
		}
		carol.linkIdentity(idp, "github", fakeIdentity{Subject: "7"})
		tokens := server.startSSO("github", "polder://auth").signIn(idp, "github", fakeIdentity{Subject: "7"})
		if tokens.User.Username != "carol" {
			t.Fatalf("signed in as %+v", tokens.User)
		}
	})
}

func TestSingleSignOnProviderFromConfig(t *testing.T) {
	idp := startFakeIdP(t)
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) {
		cfg.PublicURL = "https://cloud.example.com"
		cfg.SSOPreset = "keycloak"
		cfg.SSOServerURL = idp.server.URL
		cfg.SSORealm = "home"
		cfg.SSOClientID = "polder"
		cfg.SSOClientSecret = "s3cret"
	})
	admin := server.setupAdmin()
	var providers []ssoProvider
	admin.mustJSON(http.MethodGet, "/admin/auth-providers", nil, http.StatusOK, &providers)
	if len(providers) != 1 || providers[0].ID != sso.ConfigID || !providers[0].ManagedByConfig || providers[0].Issuer != idp.server.URL+"/realms/home" {
		t.Fatalf("providers = %+v", providers)
	}
	admin.mustJSON(http.MethodPatch, "/admin/auth-providers/config", map[string]any{"label": "Other"}, http.StatusBadRequest, nil)
	admin.mustJSON(http.MethodPatch, "/admin/auth-providers/config", map[string]any{"enabled": false}, http.StatusOK, nil)
	admin.mustJSON(http.MethodDelete, "/admin/auth-providers/config", nil, http.StatusBadRequest, nil)
}

func TestLinkingAnAccountFromSettings(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		bob := server.createUser(admin, "bob", 0)
		addProvider(admin, map[string]any{"preset": "pocket-id", "serverUrl": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret",
			"allowSignup": false, "linkByEmail": false})

		identity := fakeIdentity{Subject: "bob-at-idp", Email: "someone-else@example.com"}
		bob.linkIdentity(idp, "pocket-id", identity)

		tokens := server.startSSO("pocket-id", "polder://auth").signIn(idp, "pocket-id", identity)
		if tokens.User.Username != "bob" {
			t.Fatalf("signed in as %+v", tokens.User)
		}

		var identities []struct {
			ID int64 `json:"id"`
		}
		bob.mustJSON(http.MethodGet, "/account/identities", nil, http.StatusOK, &identities)
		bob.mustJSON(http.MethodDelete, "/account/identities/"+strconv.FormatInt(identities[0].ID, 10), nil, http.StatusNoContent, nil)
		back := server.startSSO("pocket-id", "polder://auth").finish(idp, "pocket-id", identity)
		if back.Query().Get("error") != sso.FailureSignupDisabled {
			t.Fatalf("after unlinking, signing in should fail: %s", back)
		}
	})
}

func (c *client) startLink(providerID string) ssoAttempt {
	c.server.t.Helper()
	verifier := strings.Repeat("l", 50) + strconv.FormatInt(time.Now().UnixNano(), 10)
	var start struct {
		URL string `json:"url"`
	}
	c.mustJSON(http.MethodPost, "/account/identities/"+providerID+"/link",
		map[string]string{"redirectUri": "polder://auth", "codeChallenge": pkceOf(verifier)}, http.StatusOK, &start)
	attempt := ssoAttempt{server: c.server, verifier: verifier}
	attempt.location, _ = url.Parse(start.URL)
	return attempt
}

func (c *client) linkIdentity(idp *fakeIdP, providerID string, identity fakeIdentity) {
	c.server.t.Helper()
	attempt := c.startLink(providerID)
	back := attempt.finish(idp, providerID, identity)
	var linked struct {
		ProviderID string `json:"providerId"`
	}
	c.mustJSON(http.MethodPost, "/account/identities/confirm",
		map[string]string{"code": back.Query().Get("code"), "codeVerifier": attempt.verifier}, http.StatusOK, &linked)
	if linked.ProviderID != providerID {
		c.server.t.Fatalf("linked = %+v", linked)
	}
}

func TestALinkStartedByOneAccountCannotBeFinishedElsewhere(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		mallory := server.createUser(admin, "mallory", 0)
		victim := server.createUser(admin, "victim", 0)
		addProvider(admin, map[string]any{"preset": "pocket-id", "serverUrl": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret",
			"allowSignup": false, "linkByEmail": false})

		attempt := mallory.startLink("pocket-id")
		back := attempt.finish(idp, "pocket-id", fakeIdentity{Subject: "victim-at-idp"})
		code := back.Query().Get("code")
		if code == "" {
			t.Fatalf("redirected to %s", back)
		}
		mallory.mustJSON(http.MethodPost, "/account/identities/confirm", map[string]string{"code": code, "codeVerifier": "not-the-verifier"},
			http.StatusBadRequest, nil)
		victim.mustJSON(http.MethodPost, "/account/identities/confirm", map[string]string{"code": code, "codeVerifier": attempt.verifier},
			http.StatusBadRequest, nil)
		server.anonymous().mustJSON(http.MethodPost, "/auth/sso/token", map[string]string{"code": code, "codeVerifier": attempt.verifier},
			http.StatusUnauthorized, nil)
		var identities []struct{}
		mallory.mustJSON(http.MethodGet, "/account/identities", nil, http.StatusOK, &identities)
		if len(identities) != 0 {
			t.Fatalf("nothing may be linked without the verifier: %+v", identities)
		}
	})
}

func TestEmailMatchingSkipsProtectedAndSharedAccounts(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		admin.mustJSON(http.MethodPut, "/account/profile", map[string]any{"email": "boss@example.com", "firstName": "", "lastName": "", "displayName": "", "address": ""}, http.StatusOK, nil)
		protected := server.createUserWithEmail(admin, "dana", "dana@example.com", 0)
		protected.enableTwoFactor("password1")
		server.createUserWithEmail(admin, "erin", "shared@example.com", 0)
		server.createUserWithEmail(admin, "frank", "shared@example.com", 0)
		addProvider(admin, map[string]any{"preset": "pocket-id", "serverUrl": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret",
			"allowSignup": true, "linkByEmail": true})

		for index, email := range []string{"boss@example.com", "dana@example.com", "shared@example.com"} {
			identity := fakeIdentity{Subject: "s-" + strconv.Itoa(index), Email: email, EmailVerified: true, Username: "x" + strconv.Itoa(index)}
			back := server.startSSO("pocket-id", "polder://auth").finish(idp, "pocket-id", identity)
			if back.Query().Get("error") != sso.FailureLinkRequired {
				t.Errorf("%s: redirected to %s", email, back)
			}
		}
	})
}

func TestAccountsWithoutPasswordNeedARecentSignInForSensitiveChanges(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		addProvider(admin, map[string]any{"preset": "pocket-id", "serverUrl": idp.server.URL, "clientId": "polder", "clientSecret": "s3cret"})
		tokens := server.startSSO("pocket-id", "polder://auth").signIn(idp, "pocket-id",
			fakeIdentity{Subject: "g-1", Email: "gina@example.com", EmailVerified: true, Username: "gina"})
		gina := &client{server: server, token: tokens.AccessToken}
		newAppPassword := map[string]any{"name": "Laptop", "currentPassword": ""}
		gina.mustJSON(http.MethodPost, "/account/app-passwords", newAppPassword, http.StatusCreated, nil)

		if err := server.app.AgeSignIns(context.Background(), time.Hour); err != nil {
			t.Fatal(err)
		}
		gina.mustJSON(http.MethodPost, "/account/app-passwords", newAppPassword, http.StatusForbidden, nil)
		var copied ssoTokens
		gina.mustJSON(http.MethodPost, "/auth/sessions", map[string]string{"deviceName": "Copy"}, http.StatusCreated, &copied)
		(&client{server: server, token: copied.AccessToken}).mustJSON(http.MethodPut, "/account/password",
			map[string]string{"currentPassword": "", "newPassword": "a-new-password"}, http.StatusForbidden, nil)

		fresh := server.startSSO("pocket-id", "polder://auth").signIn(idp, "pocket-id",
			fakeIdentity{Subject: "g-1", Email: "gina@example.com", EmailVerified: true, Username: "gina"})
		(&client{server: server, token: fresh.AccessToken}).mustJSON(http.MethodPost, "/account/app-passwords", newAppPassword, http.StatusCreated, nil)
	})
}

func TestMultiTenantProviderChecksTheTenantOfEveryToken(t *testing.T) {
	idp := startFakeIdP(t)
	forEachDatabaseWithMail(t, func(t *testing.T, server *testServer, mailer *capturingMailer) {
		admin := server.setupAdmin()
		server.createUserWithEmail(admin, "alice", "alice@contoso.example", 0)
		provider := addProvider(admin, map[string]any{"preset": sso.PresetGeneric, "issuer": idp.server.URL + "/common/v2.0",
			"clientId": "polder", "clientSecret": "s3cret", "linkByEmail": true})
		var tested struct {
			OK      bool   `json:"ok"`
			Message string `json:"message"`
		}
		admin.mustJSON(http.MethodPost, "/admin/auth-providers/"+provider.ID+"/test", nil, http.StatusOK, &tested)
		if !tested.OK {
			t.Fatalf("a multi-tenant issuer should pass the test: %s", tested.Message)
		}

		unverified := fakeIdentity{Subject: "alice-entra", Email: "alice@contoso.example", Tenant: "contoso"}
		back := server.startSSO(provider.ID, "polder://auth").finish(idp, provider.ID, unverified)
		if back.Query().Get("error") != sso.FailureSignupDisabled {
			t.Fatalf("Entra addresses aren't verified without xms_edov: %s", back)
		}

		verified := unverified
		verified.Extra = map[string]any{"xms_edov": true}
		tokens := server.startSSO(provider.ID, "polder://auth").signIn(idp, provider.ID, verified)
		if tokens.User.Username != "alice" {
			t.Fatalf("xms_edov marks the address as verified: %+v", tokens.User)
		}

		forged := verified
		forged.IssuedBy = "fabrikam"
		back = server.startSSO(provider.ID, "polder://auth").finish(idp, provider.ID, forged)
		if back.Query().Get("error") != sso.FailureProvider {
			t.Fatalf("a token whose issuer doesn't match its tenant must be refused: %s", back)
		}
	})
}
