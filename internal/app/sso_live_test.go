//go:build ssolive

package app_test

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"errors"
	"html"
	"io"
	"io/fs"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"regexp"
	"strings"
	"testing"

	"polder-server/internal/config"
)

const livePublicURL = "http://localhost:6060"

type liveAccount struct {
	username string
	password string
	email    string
}

var (
	liveAlice = liveAccount{username: "alice", password: "alice-password", email: "alice@example.com"}
	liveBob   = liveAccount{username: "bob", password: "bob-password", email: "bob@example.com"}
)

type liveIdP struct {
	name      string
	discovery string
	provider  map[string]any
	signIn    func(b *browser, authorize *url.URL, account liveAccount) *url.URL

	allVerified        bool
	emailNeverVerified bool
}

type browser struct {
	t      *testing.T
	client *http.Client
}

func newBrowser(t *testing.T) *browser {
	t.Helper()
	jar, err := cookiejar.New(nil)
	if err != nil {
		t.Fatal(err)
	}
	return &browser{t: t, client: &http.Client{
		Jar:           jar,
		CheckRedirect: func(*http.Request, []*http.Request) error { return http.ErrUseLastResponse },
	}}
}

func (b *browser) do(request *http.Request) (*http.Response, string) {
	b.t.Helper()
	response, err := b.client.Do(request)
	if err != nil {
		b.t.Fatal(err)
	}
	defer response.Body.Close()
	body, err := io.ReadAll(response.Body)
	if err != nil {
		b.t.Fatal(err)
	}
	return response, string(body)
}

func (b *browser) get(target string) (*http.Response, string) {
	b.t.Helper()
	request, err := http.NewRequest(http.MethodGet, target, nil)
	if err != nil {
		b.t.Fatal(err)
	}
	return b.do(request)
}

func (b *browser) postForm(target string, form url.Values) (*http.Response, string) {
	b.t.Helper()
	request, err := http.NewRequest(http.MethodPost, target, strings.NewReader(form.Encode()))
	if err != nil {
		b.t.Fatal(err)
	}
	request.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	return b.do(request)
}

func (b *browser) postJSON(target, body string, headers map[string]string) (*http.Response, string) {
	b.t.Helper()
	request, err := http.NewRequest(http.MethodPost, target, strings.NewReader(body))
	if err != nil {
		b.t.Fatal(err)
	}
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")
	for key, value := range headers {
		request.Header.Set(key, value)
	}
	return b.do(request)
}

func (b *browser) followUntilPolder(start string) *url.URL {
	b.t.Helper()
	return b.followUntil(start, func(target *url.URL) bool { return strings.HasPrefix(target.String(), livePublicURL+"/") })
}

func (b *browser) followUntil(start string, done func(*url.URL) bool) *url.URL {
	b.t.Helper()
	current := start
	for range 20 {
		if parsed, _ := url.Parse(current); done(parsed) {
			return parsed
		}
		response, body := b.get(current)
		location := response.Header.Get("Location")
		if location == "" {
			b.t.Fatalf("%s answered %d without a redirect: %.400s", current, response.StatusCode, body)
		}
		next, err := response.Request.URL.Parse(location)
		if err != nil {
			b.t.Fatal(err)
		}
		current = next.String()
	}
	b.t.Fatalf("too many redirects from %s", start)
	return nil
}

func (b *browser) redirectOf(response *http.Response, body string) *url.URL {
	b.t.Helper()
	location := response.Header.Get("Location")
	if location == "" {
		b.t.Fatalf("%s answered %d without a redirect: %.600s", response.Request.URL, response.StatusCode, body)
	}
	next, err := response.Request.URL.Parse(location)
	if err != nil {
		b.t.Fatal(err)
	}
	return b.followUntilPolder(next.String())
}

func trustLiveCertificate(t *testing.T) {
	t.Helper()
	const path = "../../dev/sso/certs/cert.pem"
	pem, err := os.ReadFile(path)
	if errors.Is(err, fs.ErrNotExist) {
		return
	}
	if err != nil {
		t.Fatal(err)
	}
	pool, err := x509.SystemCertPool()
	if err != nil {
		pool = x509.NewCertPool()
	}
	if !pool.AppendCertsFromPEM(pem) {
		t.Fatalf("no certificate in %s", path)
	}
	transport := http.DefaultTransport.(*http.Transport)
	previous := transport.TLSClientConfig
	transport.TLSClientConfig = &tls.Config{RootCAs: pool}
	t.Cleanup(func() { transport.TLSClientConfig = previous })
}

type liveResult struct {
	code     string
	failure  string
	tokens   ssoTokens
	callback *url.URL
}

func (s *testServer) liveSignIn(idp liveIdP, providerID string, account liveAccount) liveResult {
	s.t.Helper()
	attempt := s.startSSO(providerID, "polder://auth")
	b := newBrowser(s.t)
	callback := idp.signIn(b, attempt.location, account)
	if !strings.HasPrefix(callback.Path, "/api/v1/auth/sso/"+providerID+"/callback") {
		s.t.Fatalf("%s sent the browser to %s, not to the callback", idp.name, callback)
	}
	response := s.withoutRedirects(strings.TrimPrefix(callback.RequestURI(), "/api/v1"))
	if response.StatusCode != http.StatusFound {
		s.t.Fatalf("callback answered %d", response.StatusCode)
	}
	back, _ := url.Parse(response.Header.Get("Location"))
	result := liveResult{failure: back.Query().Get("error"), code: back.Query().Get("code"), callback: callback}
	if result.failure != "" {
		s.t.Logf("%s sent the callback %s", idp.name, callback)
	}
	if result.code != "" {
		s.anonymous().mustJSON(http.MethodPost, "/auth/sso/token",
			map[string]string{"code": result.code, "codeVerifier": attempt.verifier}, http.StatusOK, &result.tokens)
	}
	return result
}

func reachable(t *testing.T, target string) bool {
	t.Helper()
	response, err := http.Get(target)
	if err != nil {
		return false
	}
	response.Body.Close()
	return response.StatusCode == http.StatusOK
}

func liveIdPs() []liveIdP {
	return []liveIdP{keycloakIdP(), autheliaIdP(), pocketIDIdP(), authentikIdP()}
}

func TestLiveSingleSignOn(t *testing.T) {
	trustLiveCertificate(t)
	for _, idp := range liveIdPs() {
		t.Run(idp.name, func(t *testing.T) {
			if !reachable(t, idp.discovery) {
				t.Skipf("%s is not running; start dev/sso first", idp.name)
			}
			server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.PublicURL = livePublicURL })
			admin := server.setupAdmin()
			provider := addProvider(admin, idp.provider)
			var tested authProviderTestResult
			admin.mustJSON(http.MethodPost, "/admin/auth-providers/"+provider.ID+"/test", nil, http.StatusOK, &tested)
			if !tested.OK {
				t.Fatalf("test connection failed: %s", tested.Message)
			}

			admin.mustJSON(http.MethodPost, "/admin/users", map[string]any{"username": "alice-local", "password": "password1",
				"role": "user", "email": liveAlice.email}, http.StatusCreated, nil)
			setSignup := func(allow bool) {
				admin.mustJSON(http.MethodPatch, "/admin/auth-providers/"+provider.ID, map[string]any{"allowSignup": allow}, http.StatusOK, nil)
			}

			setSignup(false)
			if idp.emailNeverVerified {
				refused := server.liveSignIn(idp, provider.ID, liveAlice)
				if refused.failure != "signup_disabled" {
					t.Fatalf("%s never marks addresses as verified, so alice can't be matched by email: %+v", idp.name, refused)
				}
				aliceLocal := server.login("alice-local", "password1")
				var start struct {
					URL string `json:"url"`
				}
				aliceLocal.mustJSON(http.MethodPost, "/account/identities/"+provider.ID+"/link", map[string]string{"redirectUri": "polder://auth"},
					http.StatusOK, &start)
				authorize, _ := url.Parse(start.URL)
				callback := idp.signIn(newBrowser(t), authorize, liveAlice)
				response := server.withoutRedirects(strings.TrimPrefix(callback.RequestURI(), "/api/v1"))
				if back, _ := url.Parse(response.Header.Get("Location")); back == nil || back.Query().Get("linked") != provider.ID {
					t.Fatalf("linking from settings answered %d %s", response.StatusCode, response.Header.Get("Location"))
				}
			}
			linked := server.liveSignIn(idp, provider.ID, liveAlice)
			if linked.tokens.User.Username != "alice-local" {
				t.Fatalf("alice should be linked to alice-local: %+v (callback %s)", linked, linked.callback)
			}
			again := server.liveSignIn(idp, provider.ID, liveAlice)
			if again.tokens.User.Username != "alice-local" {
				t.Fatalf("the second sign-in should use the link: %+v", again)
			}

			if !idp.allVerified {
				admin.mustJSON(http.MethodPost, "/admin/users", map[string]any{"username": "bob-local", "password": "password1",
					"role": "user", "email": liveBob.email}, http.StatusCreated, nil)
				refused := server.liveSignIn(idp, provider.ID, liveBob)
				if refused.failure != "signup_disabled" {
					t.Fatalf("bob's address isn't verified, so he must not be linked to bob-local: %+v", refused)
				}
			} else if refused := server.liveSignIn(idp, provider.ID, liveBob); refused.failure != "signup_disabled" {
				t.Fatalf("bob has no account and sign-up is off: %+v", refused)
			}
			setSignup(true)
			created := server.liveSignIn(idp, provider.ID, liveBob)
			if created.tokens.User.Username != "bob" || !created.tokens.User.SSO || created.tokens.User.HasPassword {
				t.Fatalf("expected a new account bob without a password: %+v", created.tokens.User)
			}
		})
	}
}

type authProviderTestResult struct {
	OK      bool   `json:"ok"`
	Message string `json:"message"`
}

var formAction = regexp.MustCompile(`<form[^>]*id="kc-form-login"[^>]*action="([^"]+)"`)

func keycloakIdP() liveIdP {
	return liveIdP{
		name:      "keycloak",
		discovery: "http://localhost:8180/realms/polder/.well-known/openid-configuration",
		provider: map[string]any{"preset": "keycloak", "serverUrl": "http://localhost:8180", "realm": "polder",
			"clientId": "polder", "clientSecret": "polder-keycloak-secret"},
		signIn: func(b *browser, authorize *url.URL, account liveAccount) *url.URL {
			_, page := b.get(authorize.String())
			match := formAction.FindStringSubmatch(page)
			if match == nil {
				b.t.Fatalf("no Keycloak login form: %.600s", page)
			}
			return b.redirectOf(b.postForm(html.UnescapeString(match[1]),
				url.Values{"username": {account.username}, "password": {account.password}, "credentialId": {""}}))
		},
	}
}

func autheliaIdP() liveIdP {
	const base = "https://127.0.0.1:9091"
	return liveIdP{
		name:      "authelia",
		discovery: base + "/.well-known/openid-configuration",
		provider: map[string]any{"preset": "authelia", "serverUrl": base, "clientId": "polder",
			"clientSecret": "polder-authelia-secret"},
		allVerified: true,
		signIn: func(b *browser, authorize *url.URL, account liveAccount) *url.URL {
			portal := b.followUntil(authorize.String(), func(target *url.URL) bool {
				return target.Host == "127.0.0.1:9091" && !strings.HasPrefix(target.Path, "/api/")
			})
			query := portal.Query()
			body, _ := json.Marshal(map[string]any{"username": account.username, "password": account.password,
				"keepMeLoggedIn": false, "flow": query.Get("flow"), "flowID": query.Get("flow_id"),
				"subflow": query.Get("subflow"), "targetURL": query.Get("rd")})
			response, answer := b.postJSON(base+"/api/firstfactor", string(body), nil)
			var result struct {
				Status string `json:"status"`
				Data   struct {
					Redirect string `json:"redirect"`
				} `json:"data"`
			}
			if response.StatusCode != http.StatusOK || json.Unmarshal([]byte(answer), &result) != nil || result.Data.Redirect == "" {
				b.t.Fatalf("Authelia first factor answered %d: %s (portal %s)", response.StatusCode, answer, portal)
			}
			return b.followUntilPolder(result.Data.Redirect)
		},
	}
}

func pocketIDIdP() liveIdP {
	const base = "http://localhost:1411"
	apiKey := map[string]string{"X-API-Key": "polder-dev-pocket-id-api-key"}
	signedIn := map[string]*browser{}
	return liveIdP{
		name:      "pocket-id",
		discovery: base + "/.well-known/openid-configuration",
		provider: map[string]any{"preset": "pocket-id", "serverUrl": base, "clientId": "polder",
			"clientSecret": "polder-pocket-id-secret"},
		signIn: func(fresh *browser, authorize *url.URL, account liveAccount) *url.URL {
			b, ok := signedIn[account.username]
			if ok && b.t == fresh.t {
				return pocketIDAuthorize(b, base, authorize)
			}
			b = fresh
			signedIn[account.username] = b
			admin := newBrowser(b.t)
			request, _ := http.NewRequest(http.MethodGet, base+"/api/users?search="+account.username, nil)
			request.Header.Set("X-API-Key", apiKey["X-API-Key"])
			_, listed := admin.do(request)
			var users struct {
				Data []struct {
					ID       string `json:"id"`
					Username string `json:"username"`
				} `json:"data"`
			}
			userID := ""
			if json.Unmarshal([]byte(listed), &users) == nil {
				for _, user := range users.Data {
					if user.Username == account.username {
						userID = user.ID
					}
				}
			}
			if userID == "" {
				b.t.Fatalf("no Pocket ID user %s: %s", account.username, listed)
			}
			_, created := admin.postJSON(base+"/api/users/"+userID+"/one-time-access-token", `{}`, apiKey)
			var token struct {
				Token string `json:"token"`
			}
			if json.Unmarshal([]byte(created), &token) != nil || token.Token == "" {
				b.t.Fatalf("no one-time access token: %s", created)
			}
			if response, body := b.postJSON(base+"/api/one-time-access-token/"+token.Token, "", nil); response.StatusCode != http.StatusOK {
				b.t.Fatalf("signing in to Pocket ID answered %d: %s", response.StatusCode, body)
			}
			return pocketIDAuthorize(b, base, authorize)
		},
	}
}

func pocketIDAuthorize(b *browser, base string, authorize *url.URL) *url.URL {
	b.t.Helper()
	next := authorize.String()
	for range 6 {
		stop := b.followUntil(next, func(target *url.URL) bool {
			return strings.HasPrefix(target.String(), livePublicURL+"/") || target.Path == "/interaction"
		})
		if stop.Path != "/interaction" {
			return stop
		}
		interaction := stop.Query().Get("interaction")
		_, session := b.get(base + "/api/oidc/interactions/" + interaction)
		var current struct {
			CurrentStep string `json:"currentStep"`
		}
		_ = json.Unmarshal([]byte(session), &current)
		body, _ := json.Marshal(map[string]any{"step": current.CurrentStep})
		response, answer := b.postJSON(base+"/api/oidc/interactions/"+interaction+"/complete", string(body), nil)
		var completed struct {
			RedirectURL string `json:"redirectUrl"`
		}
		if response.StatusCode != http.StatusOK || json.Unmarshal([]byte(answer), &completed) != nil || completed.RedirectURL == "" {
			b.t.Fatalf("completing the %q step answered %d: %s", current.CurrentStep, response.StatusCode, answer)
		}
		next = base + completed.RedirectURL
	}
	b.t.Fatal("Pocket ID kept asking for interaction")
	return nil
}

func authentikIdP() liveIdP {
	const base = "http://localhost:9000"
	return liveIdP{
		name:      "authentik",
		discovery: base + "/application/o/polder/.well-known/openid-configuration",
		provider: map[string]any{"preset": "authentik", "serverUrl": base, "slug": "polder", "clientId": "polder",
			"clientSecret": "polder-authentik-secret"},
		emailNeverVerified: true,
		signIn: func(b *browser, authorize *url.URL, account liveAccount) *url.URL {
			isFlow := func(target *url.URL) bool { return strings.HasPrefix(target.Path, "/if/flow/") }
			next := b.followUntil(authorize.String(), func(target *url.URL) bool {
				return strings.HasPrefix(target.String(), livePublicURL+"/") || isFlow(target)
			})
			for range 6 {
				if !isFlow(next) {
					return next
				}
				slug := strings.Trim(strings.TrimPrefix(next.Path, "/if/flow/"), "/")
				executor := base + "/api/v3/flows/executor/" + slug + "/?" + url.Values{"query": {next.RawQuery}}.Encode()
				to := authentikFlow(b, base, executor, account)
				target, _ := url.Parse(base)
				resolved, _ := target.Parse(to)
				next = b.followUntil(resolved.String(), func(target *url.URL) bool {
					return strings.HasPrefix(target.String(), livePublicURL+"/") || isFlow(target)
				})
			}
			b.t.Fatal("authentik kept starting flows")
			return nil
		},
	}
}

type authentikChallenge struct {
	Component      string `json:"component"`
	To             string `json:"to"`
	Token          string `json:"token"`
	PasswordFields bool   `json:"password_fields"`
}

func authentikFlow(b *browser, base, executor string, account liveAccount) string {
	b.t.Helper()
	response, body := b.get(executor)
	for range 8 {
		if location := response.Header.Get("Location"); location != "" {
			target, _ := response.Request.URL.Parse(location)
			response, body = b.get(target.String())
			continue
		}
		var challenge authentikChallenge
		if err := json.Unmarshal([]byte(body), &challenge); err != nil {
			b.t.Fatalf("authentik answered %d: %.400s", response.StatusCode, body)
		}
		answer := map[string]any{"component": challenge.Component}
		switch challenge.Component {
		case "xak-flow-redirect":
			return challenge.To
		case "ak-stage-identification":
			answer["uid_field"] = account.username
			if challenge.PasswordFields {
				answer["password"] = account.password
			}
		case "ak-stage-password":
			answer["password"] = account.password
		case "ak-stage-consent":
			answer["token"] = challenge.Token
		default:
			b.t.Fatalf("authentik asked for %s: %.400s", challenge.Component, body)
		}
		encoded, _ := json.Marshal(answer)
		headers := map[string]string{"Origin": base, "Referer": base + "/"}
		parsed, _ := url.Parse(base)
		for _, cookie := range b.client.Jar.Cookies(parsed) {
			if cookie.Name == "authentik_csrf" {
				headers["X-authentik-CSRF"] = cookie.Value
				headers["X-CSRFToken"] = cookie.Value
			}
		}
		response, body = b.postJSON(executor, string(encoded), headers)
	}
	b.t.Fatal("authentik's flow didn't finish")
	return ""
}
