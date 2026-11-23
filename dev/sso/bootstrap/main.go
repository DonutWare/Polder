package main

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"
)

const (
	callbackBase        = "http://localhost:6060/api/v1/auth/sso/"
	pocketIDURL         = "http://localhost:1411"
	pocketIDAPIKey      = "polder-dev-pocket-id-api-key"
	pocketIDClientID    = "polder"
	pocketIDSecret      = "polder-pocket-id-secret"
	authentikURL        = "http://localhost:9000"
	authentikToken      = "polder-dev-authentik-api-token"
	authentikClientID   = "polder"
	authentikSecret     = "polder-authentik-secret"
	authentikSlug       = "polder"
	accountPassword     = "-password"
	waitForServicesTime = 5 * time.Minute
)

type account struct {
	Username  string
	FirstName string
	Email     string
	Verified  bool
}

var accounts = []account{
	{Username: "alice", FirstName: "Alice", Email: "alice@example.com", Verified: true},
	{Username: "bob", FirstName: "Bob", Email: "bob@example.com", Verified: false},
}

type api struct {
	base    string
	headers map[string]string
}

func (a api) call(method, path string, body, into any) (int, error) {
	var reader io.Reader
	if body != nil {
		encoded, err := json.Marshal(body)
		if err != nil {
			return 0, err
		}
		reader = bytes.NewReader(encoded)
	}
	request, err := http.NewRequest(method, a.base+path, reader)
	if err != nil {
		return 0, err
	}
	request.Header.Set("Content-Type", "application/json")
	request.Header.Set("Accept", "application/json")
	for key, value := range a.headers {
		request.Header.Set(key, value)
	}
	response, err := http.DefaultClient.Do(request)
	if err != nil {
		return 0, err
	}
	defer response.Body.Close()
	answer, err := io.ReadAll(response.Body)
	if err != nil {
		return response.StatusCode, err
	}
	if response.StatusCode >= 300 {
		return response.StatusCode, fmt.Errorf("%s %s answered %s: %s", method, path, response.Status, answer)
	}
	if into != nil && len(answer) > 0 {
		return response.StatusCode, json.Unmarshal(answer, into)
	}
	return response.StatusCode, nil
}

func waitFor(url string) error {
	deadline := time.Now().Add(waitForServicesTime)
	for time.Now().Before(deadline) {
		response, err := http.Get(url)
		if err == nil {
			response.Body.Close()
			if response.StatusCode == http.StatusOK {
				return nil
			}
		}
		time.Sleep(2 * time.Second)
	}
	return fmt.Errorf("%s did not come up", url)
}

func main() {
	steps := []struct {
		name string
		run  func() error
	}{
		{"Pocket ID", setUpPocketID},
		{"authentik", setUpAuthentik},
	}
	failed := false
	for _, step := range steps {
		if err := step.run(); err != nil {
			fmt.Fprintf(os.Stderr, "%s: %v\n", step.name, err)
			failed = true
			continue
		}
		fmt.Printf("%s is ready\n", step.name)
	}
	if failed {
		os.Exit(1)
	}
}

func setUpPocketID() error {
	if err := waitFor(pocketIDURL + "/.well-known/openid-configuration"); err != nil {
		return err
	}
	pocket := api{base: pocketIDURL, headers: map[string]string{"X-API-Key": pocketIDAPIKey}}
	var existing struct {
		Data []struct {
			Username string `json:"username"`
		} `json:"data"`
	}
	if _, err := pocket.call(http.MethodGet, "/api/users?pagination[limit]=100", nil, &existing); err != nil {
		return err
	}
	known := map[string]bool{}
	for _, user := range existing.Data {
		known[user.Username] = true
	}
	for _, person := range accounts {
		if known[person.Username] {
			continue
		}
		_, err := pocket.call(http.MethodPost, "/api/users", map[string]any{
			"username": person.Username, "email": person.Email, "emailVerified": person.Verified,
			"firstName": person.FirstName, "lastName": "Example", "displayName": person.FirstName + " Example",
			"isAdmin": person.Username == "alice",
		}, nil)
		if err != nil {
			return err
		}
	}
	status, err := pocket.call(http.MethodGet, "/api/oidc/clients/"+pocketIDClientID, nil, nil)
	if status == http.StatusNotFound {
		_, err = pocket.call(http.MethodPost, "/api/oidc/clients", map[string]any{
			"id": pocketIDClientID, "name": "Polder", "callbackURLs": []string{callbackBase + "pocket-id/callback"},
			"isPublic": false, "pkceEnabled": true,
		}, nil)
		if err != nil {
			return err
		}
		_, err = pocket.call(http.MethodPost, "/api/oidc/clients/"+pocketIDClientID+"/secrets", map[string]any{"secret": pocketIDSecret}, nil)
	}
	if err != nil {
		return errors.Join(errors.New("set up the Polder client"), err)
	}
	return nil
}

type page[T any] struct {
	Results []T `json:"results"`
}

type authentikObject struct {
	PK       any    `json:"pk"`
	Username string `json:"username"`
	Slug     string `json:"slug"`
	Name     string `json:"name"`
	Managed  string `json:"managed"`
}

func (a api) first(path string) (authentikObject, bool, error) {
	var found page[authentikObject]
	if _, err := a.call(http.MethodGet, path, nil, &found); err != nil {
		return authentikObject{}, false, err
	}
	if len(found.Results) == 0 {
		return authentikObject{}, false, nil
	}
	return found.Results[0], true, nil
}

func (a api) require(path string) (any, error) {
	deadline := time.Now().Add(waitForServicesTime)
	for time.Now().Before(deadline) {
		object, ok, err := a.first(path)
		if err != nil {
			return nil, err
		}
		if ok {
			return object.PK, nil
		}
		time.Sleep(3 * time.Second)
	}
	return nil, fmt.Errorf("%s stayed empty; is the authentik worker running?", path)
}

func (a api) waitUntilAccepted(path string) error {
	deadline := time.Now().Add(waitForServicesTime)
	for {
		_, err := a.call(http.MethodGet, path, nil, nil)
		if err == nil || time.Now().After(deadline) {
			return err
		}
		time.Sleep(3 * time.Second)
	}
}

func setUpAuthentik() error {
	if err := waitFor(authentikURL + "/-/health/ready/"); err != nil {
		return err
	}
	authentik := api{base: authentikURL + "/api/v3", headers: map[string]string{"Authorization": "Bearer " + authentikToken}}
	if err := authentik.waitUntilAccepted("/core/users/me/"); err != nil {
		return err
	}
	for _, person := range accounts {
		if _, ok, err := authentik.first("/core/users/?username=" + person.Username); err != nil || ok {
			if err != nil {
				return err
			}
			continue
		}
		var created authentikObject
		_, err := authentik.call(http.MethodPost, "/core/users/", map[string]any{
			"username": person.Username, "name": person.FirstName + " Example", "email": person.Email, "is_active": true,
		}, &created)
		if err != nil {
			return err
		}
		_, err = authentik.call(http.MethodPost, fmt.Sprintf("/core/users/%v/set_password/", created.PK),
			map[string]string{"password": person.Username + accountPassword}, nil)
		if err != nil {
			return err
		}
	}
	if _, ok, err := authentik.first("/core/applications/?slug=" + authentikSlug); err != nil || ok {
		return err
	}
	authorization, err := authentik.require("/flows/instances/?slug=default-provider-authorization-implicit-consent")
	if err != nil {
		return err
	}
	invalidation, err := authentik.require("/flows/instances/?slug=default-provider-invalidation-flow")
	if err != nil {
		return err
	}
	signingKey, err := authentik.require("/crypto/certificatekeypairs/?has_key=true")
	if err != nil {
		return err
	}
	var mappings []any
	for _, scope := range []string{"openid", "email", "profile"} {
		mapping, err := authentik.require("/propertymappings/provider/scope/?managed=goauthentik.io/providers/oauth2/scope-" + scope)
		if err != nil {
			return err
		}
		mappings = append(mappings, mapping)
	}
	var provider authentikObject
	_, err = authentik.call(http.MethodPost, "/providers/oauth2/", map[string]any{
		"name": "Polder", "authorization_flow": authorization, "invalidation_flow": invalidation,
		"client_type": "confidential", "client_id": authentikClientID, "client_secret": authentikSecret,
		"redirect_uris":     []map[string]string{{"matching_mode": "strict", "url": callbackBase + "authentik/callback"}},
		"property_mappings": mappings, "signing_key": signingKey,
		"grant_types": []string{"authorization_code", "refresh_token"},
	}, &provider)
	if err != nil {
		return err
	}
	_, err = authentik.call(http.MethodPost, "/core/applications/", map[string]any{
		"name": "Polder", "slug": authentikSlug, "provider": provider.PK,
	}, nil)
	return err
}
