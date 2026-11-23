package sso

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"sync"

	"github.com/coreos/go-oidc/v3/oidc"
	"golang.org/x/oauth2"

	"polder-server/internal/apperr"
)

type Identity struct {
	Subject           string
	Email             string
	EmailVerified     bool
	PreferredUsername string
	Name              string
}

type connector interface {
	authCodeURL(state, nonce, verifier string) string
	exchange(ctx context.Context, code, nonce, verifier string) (Identity, error)
}

type GitHubEndpoints struct {
	AuthURL  string
	TokenURL string
	APIURL   string
}

var gitHub = GitHubEndpoints{
	AuthURL:  "https://github.com/login/oauth/authorize",
	TokenURL: "https://github.com/login/oauth/access_token",
	APIURL:   "https://api.github.com",
}

var gitHubMu sync.RWMutex

func UseGitHubEndpoints(endpoints GitHubEndpoints) func() {
	gitHubMu.Lock()
	previous := gitHub
	gitHub = endpoints
	gitHubMu.Unlock()
	return func() {
		gitHubMu.Lock()
		gitHub = previous
		gitHubMu.Unlock()
	}
}

func currentGitHub() GitHubEndpoints {
	gitHubMu.RLock()
	defer gitHubMu.RUnlock()
	return gitHub
}

func (s *Service) connectorFor(ctx context.Context, provider AuthProvider) (connector, error) {
	s.mu.Lock()
	cached, ok := s.connectors[provider.ID]
	s.mu.Unlock()
	if ok {
		return cached, nil
	}
	built, err := s.buildConnector(ctx, provider)
	if err != nil {
		return nil, err
	}
	s.mu.Lock()
	s.connectors[provider.ID] = built
	s.mu.Unlock()
	return built, nil
}

func (s *Service) forget(providerID string) {
	s.mu.Lock()
	delete(s.connectors, providerID)
	s.mu.Unlock()
}

func (s *Service) buildConnector(ctx context.Context, provider AuthProvider) (connector, error) {
	config := oauth2.Config{
		ClientID:     provider.ClientID,
		ClientSecret: provider.clientSecret,
		RedirectURL:  s.callbackURL(provider.ID),
		Scopes:       strings.Fields(provider.Scopes),
	}
	if provider.Kind == KindGitHub {
		endpoints := currentGitHub()
		config.Endpoint = oauth2.Endpoint{AuthURL: endpoints.AuthURL, TokenURL: endpoints.TokenURL, AuthStyle: oauth2.AuthStyleInParams}
		return &gitHubConnector{config: config, client: s.client, apiURL: endpoints.APIURL}, nil
	}
	clientContext := oidc.ClientContext(ctx, s.client)
	discovered, err := oidc.NewProvider(clientContext, provider.Issuer)
	tenantIssuer := ""
	var mismatch *oidc.IssuerMismatchError
	if errors.As(err, &mismatch) && strings.Contains(mismatch.Discovered, tenantPlaceholder) {
		tenantIssuer = mismatch.Discovered
		discovered, err = oidc.NewProvider(oidc.InsecureIssuerURLContext(clientContext, tenantIssuer), provider.Issuer)
	}
	if errors.As(err, &mismatch) {
		return nil, apperr.Invalid("the provider calls itself %s; use that as the issuer instead of %s", mismatch.Discovered, provider.Issuer)
	}
	if err != nil {
		return nil, apperr.Unavailable("could not reach the sign-in provider at %s: %v", provider.Issuer, err)
	}
	config.Endpoint = discovered.Endpoint()
	return &oidcConnector{
		config:       config,
		client:       s.client,
		provider:     discovered,
		verifier:     discovered.Verifier(&oidc.Config{ClientID: provider.ClientID, SkipIssuerCheck: tenantIssuer != ""}),
		username:     provider.UsernameClaim,
		tenantIssuer: tenantIssuer,
	}, nil
}

const tenantPlaceholder = "{tenantid}"

type oidcConnector struct {
	config       oauth2.Config
	client       *http.Client
	provider     *oidc.Provider
	verifier     *oidc.IDTokenVerifier
	username     string
	tenantIssuer string
}

func (c *oidcConnector) authCodeURL(state, nonce, verifier string) string {
	return c.config.AuthCodeURL(state, oidc.Nonce(nonce), oauth2.S256ChallengeOption(verifier))
}

func (c *oidcConnector) exchange(ctx context.Context, code, nonce, verifier string) (Identity, error) {
	ctx = oidc.ClientContext(ctx, c.client)
	token, err := c.config.Exchange(ctx, code, oauth2.VerifierOption(verifier))
	if err != nil {
		return Identity{}, fmt.Errorf("exchange the code: %w", err)
	}
	rawIDToken, ok := token.Extra("id_token").(string)
	if !ok {
		return Identity{}, errors.New("the provider sent no ID token")
	}
	idToken, err := c.verifier.Verify(ctx, rawIDToken)
	if err != nil {
		return Identity{}, fmt.Errorf("verify the ID token: %w", err)
	}
	if idToken.Nonce != nonce {
		return Identity{}, errors.New("the ID token is for another sign-in")
	}
	claims := map[string]any{}
	if err := idToken.Claims(&claims); err != nil {
		return Identity{}, err
	}
	if err := c.checkTenant(idToken.Issuer, claims); err != nil {
		return Identity{}, err
	}
	if _, hasEmail := claims["email"]; !hasEmail {
		if info, err := c.provider.UserInfo(ctx, oauth2.StaticTokenSource(token)); err == nil {
			extra := map[string]any{}
			if info.Claims(&extra) == nil && extra["sub"] == idToken.Subject {
				for key, value := range extra {
					if _, present := claims[key]; !present {
						claims[key] = value
					}
				}
			}
		}
	}
	return Identity{
		Subject:           idToken.Subject,
		Email:             claimText(claims, "email"),
		EmailVerified:     claimBool(claims, "email_verified") || claimBool(claims, "xms_edov"),
		PreferredUsername: claimText(claims, c.username),
		Name:              claimText(claims, "name"),
	}, nil
}

func (c *oidcConnector) checkTenant(issuer string, claims map[string]any) error {
	if c.tenantIssuer == "" {
		return nil
	}
	tenant := claimText(claims, "tid")
	if tenant == "" || issuer != strings.Replace(c.tenantIssuer, tenantPlaceholder, tenant, 1) {
		return fmt.Errorf("the ID token was issued by %s, not by the tenant %q it names", issuer, tenant)
	}
	return nil
}

func claimText(claims map[string]any, name string) string {
	value, _ := claims[name].(string)
	return strings.TrimSpace(value)
}

func claimBool(claims map[string]any, name string) bool {
	switch value := claims[name].(type) {
	case bool:
		return value
	case string:
		parsed, _ := strconv.ParseBool(value)
		return parsed
	}
	return false
}

type gitHubConnector struct {
	config oauth2.Config
	client *http.Client
	apiURL string
}

func (c *gitHubConnector) authCodeURL(state, _, verifier string) string {
	return c.config.AuthCodeURL(state, oauth2.S256ChallengeOption(verifier))
}

type gitHubUser struct {
	ID    int64  `json:"id"`
	Login string `json:"login"`
	Name  string `json:"name"`
}

type gitHubEmail struct {
	Email    string `json:"email"`
	Primary  bool   `json:"primary"`
	Verified bool   `json:"verified"`
}

func (c *gitHubConnector) exchange(ctx context.Context, code, _, verifier string) (Identity, error) {
	ctx = context.WithValue(ctx, oauth2.HTTPClient, c.client)
	token, err := c.config.Exchange(ctx, code, oauth2.VerifierOption(verifier))
	if err != nil {
		return Identity{}, fmt.Errorf("exchange the code: %w", err)
	}
	client := c.config.Client(ctx, token)
	var user gitHubUser
	if err := getJSON(ctx, client, c.apiURL+"/user", &user); err != nil {
		return Identity{}, err
	}
	if user.ID == 0 {
		return Identity{}, errors.New("GitHub sent no user")
	}
	var emails []gitHubEmail
	if err := getJSON(ctx, client, c.apiURL+"/user/emails", &emails); err != nil {
		return Identity{}, err
	}
	identity := Identity{Subject: strconv.FormatInt(user.ID, 10), PreferredUsername: user.Login, Name: user.Name}
	for _, email := range emails {
		if email.Primary {
			identity.Email, identity.EmailVerified = email.Email, email.Verified
		}
	}
	return identity, nil
}

func getJSON(ctx context.Context, client *http.Client, target string, into any) error {
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, target, nil)
	if err != nil {
		return err
	}
	request.Header.Set("Accept", "application/vnd.github+json")
	response, err := client.Do(request)
	if err != nil {
		return err
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return fmt.Errorf("%s answered %s", target, response.Status)
	}
	return json.NewDecoder(response.Body).Decode(into)
}
