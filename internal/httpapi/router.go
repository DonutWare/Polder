package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"reflect"
	"strconv"
	"strings"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"nomad-server/internal/apperr"
	"nomad-server/internal/auth"
	"nomad-server/internal/files"
	"nomad-server/internal/preview"
	"nomad-server/internal/syncing"
	"nomad-server/internal/users"
)

type API struct {
	auth     *auth.Service
	sessions *auth.Sessions
	users    *users.Service
	files    *files.Service
	sync     *syncing.Service
	previews *preview.Worker
	limiter  *failedAttemptLimiter
}

type Dependencies struct {
	Auth                   *auth.Service
	Sessions               *auth.Sessions
	Users                  *users.Service
	Files                  *files.Service
	Sync                   *syncing.Service
	Previews               *preview.Worker
	LoginAttemptsPerMinute int
	// Web serves the browser client for every path outside the API; nil serves only the API.
	Web http.Handler
}

func NewRouter(deps Dependencies) http.Handler {
	api := &API{
		auth:     deps.Auth,
		sessions: deps.Sessions,
		users:    deps.Users,
		files:    deps.Files,
		sync:     deps.Sync,
		previews: deps.Previews,
		limiter:  newFailedAttemptLimiter(deps.LoginAttemptsPerMinute),
	}

	router := chi.NewRouter()
	router.Use(middleware.Recoverer)
	// Set before mounting so the API subrouter inherits it.
	router.NotFound(endpointNotFound)
	api.register(humachi.New(router, apiConfig()))
	// Unknown API paths answer like the API, never with the web client's index.html.
	router.Handle("/api/*", http.HandlerFunc(endpointNotFound))
	if deps.Web != nil {
		router.Handle("/*", middleware.Compress(5)(deps.Web))
	}
	return router
}

func OpenAPI() ([]byte, error) {
	humaAPI := humachi.New(chi.NewRouter(), apiConfig())
	(&API{}).register(humaAPI)
	return humaAPI.OpenAPI().Downgrade()
}

func (a *API) register(humaAPI huma.API) {
	huma.Register(humaAPI, huma.Operation{OperationID: "health", Method: http.MethodGet, Path: "/healthz", Summary: "Health check", Tags: []string{"server"}}, a.health)
	a.routes(humaAPI)
}

const (
	apiPrefix  = "/api/v1"
	bearerAuth = "bearer"
)

// apiConfig serves the OpenAPI document built from the registered operations at
// /api/v1/openapi.json (and .yaml), and an interactive reference at /api/v1/docs.
func apiConfig() huma.Config {
	config := huma.DefaultConfig("Nomad API", "1.0.0")
	config.Info.Description = "File storage and sync. Log in with POST /auth/login and send the access token " +
		"as `Authorization: Bearer <token>`; renew it with POST /auth/refresh before it expires."
	config.OpenAPIPath = apiPrefix + "/openapi"
	config.DocsPath = apiPrefix + "/docs"
	// No /schemas route and no $schema field added to responses.
	config.SchemasPath = ""
	config.CreateHooks = nil
	config.Components.SecuritySchemes = map[string]*huma.SecurityScheme{
		bearerAuth: {Type: "http", Scheme: "bearer", BearerFormat: "JWT"},
	}
	return config
}

func (a *API) routes(api huma.API) {
	v1 := huma.NewGroup(api, apiPrefix)
	v1.UseSimpleModifier(tagByPath)
	register(v1, http.MethodGet, "/setup", "getSetupStatus", "Whether the server still needs its first account", a.setupStatus)
	register(v1, http.MethodPost, "/setup", "setup", "Create the first administrator account", a.setup, created)
	register(v1, http.MethodPost, "/auth/login", "login", "Log in and get a token pair", a.login)
	register(v1, http.MethodPost, "/auth/refresh", "refresh", "Exchange a refresh token for a new token pair", a.refresh)
	register(v1, http.MethodPost, "/auth/logout", "logout", "Revoke a refresh token", a.logout)

	user := huma.NewGroup(v1)
	user.UseMiddleware(a.requireUser(api))
	user.UseSimpleModifier(requiresAuth(api, http.StatusUnauthorized))
	register(user, http.MethodGet, "/auth/me", "getMe", "The logged-in user", a.me)

	register(user, http.MethodGet, "/files/list", "listFiles", "List a directory", a.listFiles)
	register(user, http.MethodGet, "/files/stat", "statFile", "Get one file or directory", a.statFile)
	register(user, http.MethodGet, "/files/content", "downloadFile", "Download a file; supports Range and conditional requests", a.downloadFile,
		withResponse(http.StatusOK, "File content", binaryContent("application/octet-stream")))
	register(user, http.MethodPut, "/files/content", "uploadFile", "Upload a whole file as the request body", a.uploadFile,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodPost, "/files/mkdir", "makeDirectory", "Create a directory", a.makeDirectory, created)
	register(user, http.MethodPost, "/files/move", "moveFile", "Move or rename a file or directory", a.moveFile)
	register(user, http.MethodDelete, "/files", "deleteFile", "Delete a file or directory", a.deleteFile)
	register(user, http.MethodGet, "/files/preview", "previewFile", "Get a JPEG thumbnail of an image", a.previewFile,
		withResponse(http.StatusOK, "Thumbnail", binaryContent("image/jpeg")))

	register(user, http.MethodGet, "/sync/changes", "listChanges", "Page through changes since a cursor", a.changes)
	register(user, http.MethodGet, "/sync/manifest", "getManifest", "Get a file's chunk manifest for delta sync", a.manifest)
	register(user, http.MethodPost, "/sync/uploads", "createUpload", "Start a chunked upload; returns the chunks the server is missing", a.createUpload,
		created, maxBody(uploadPlanLimit))
	register(user, http.MethodGet, "/sync/uploads/{uploadID}", "getUpload", "Get the chunks an upload is still missing", a.uploadStatus)
	register(user, http.MethodPut, "/sync/uploads/{uploadID}/chunks/{chunkHash}", "putChunk", "Send one chunk as the request body", a.putChunk,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodPost, "/sync/uploads/{uploadID}/commit", "commitUpload", "Assemble the uploaded chunks into the file", a.commitUpload)
	register(user, http.MethodDelete, "/sync/uploads/{uploadID}", "abortUpload", "Cancel an upload", a.abortUpload)

	admin := huma.NewGroup(user)
	admin.UseMiddleware(requireAdmin(api))
	admin.UseSimpleModifier(requiresAuth(api, http.StatusForbidden))
	register(admin, http.MethodGet, "/admin/users", "listUsers", "List all users", a.listUsers)
	register(admin, http.MethodPost, "/admin/users", "createUser", "Create a user", a.createUser, created)
	register(admin, http.MethodPatch, "/admin/users/{userID}", "updateUser", "Change a user; password changes and disabling log the user out", a.updateUser)
	register(admin, http.MethodDelete, "/admin/users/{userID}", "deleteUser", "Delete a user; their files are archived on the server", a.deleteUser)
}

func register[I, O any](api huma.API, method, path, id, summary string, handler func(context.Context, *I) (*O, error), options ...func(*huma.Operation)) {
	operation := huma.Operation{OperationID: id, Method: method, Path: path, Summary: summary, MaxBodyBytes: smallBodyLimit}
	for _, option := range options {
		option(&operation)
	}
	huma.Register(api, operation, handler)
}

func created(operation *huma.Operation) {
	operation.DefaultStatus = http.StatusCreated
}

func maxBody(limit int64) func(*huma.Operation) {
	return func(operation *huma.Operation) { operation.MaxBodyBytes = limit }
}

func withRequestBody(content map[string]*huma.MediaType) func(*huma.Operation) {
	return func(operation *huma.Operation) {
		operation.RequestBody = &huma.RequestBody{Required: true, Content: content}
	}
}

func withResponse(status int, description string, content map[string]*huma.MediaType) func(*huma.Operation) {
	return func(operation *huma.Operation) {
		operation.Responses = map[string]*huma.Response{strconv.Itoa(status): {Description: description, Content: content}}
	}
}

// tagByPath groups operations in the docs by their first path segment, such as files or sync.
func tagByPath(operation *huma.Operation) {
	segment, _, _ := strings.Cut(strings.TrimPrefix(operation.Path, apiPrefix+"/"), "/")
	operation.Tags = []string{segment}
}

// requiresAuth documents a group's middleware: the bearer token it needs and the error it sends.
func requiresAuth(api huma.API, status int) func(*huma.Operation) {
	errorSchema := api.OpenAPI().Components.Schemas.Schema(reflect.TypeFor[errorResponse](), true, "")
	return func(operation *huma.Operation) {
		operation.Security = []map[string][]string{{bearerAuth: {}}}
		operation.Responses[strconv.Itoa(status)] = &huma.Response{
			Description: http.StatusText(status),
			Content:     map[string]*huma.MediaType{"application/json": {Schema: errorSchema}},
		}
	}
}

func endpointNotFound(w http.ResponseWriter, _ *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusNotFound)
	_ = json.NewEncoder(w).Encode(fromAppError(apperr.NotFound("no such endpoint")))
}

type healthStatus struct {
	Status string `json:"status" example:"ok"`
}

func (a *API) health(context.Context, *struct{}) (*jsonBody[healthStatus], error) {
	return respond(healthStatus{Status: "ok"}), nil
}
