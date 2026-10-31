package httpapi

import (
	"context"
	"encoding/json"
	"net/http"
	"net/netip"
	"reflect"
	"strconv"
	"strings"

	"github.com/danielgtaylor/huma/v2"
	"github.com/danielgtaylor/huma/v2/adapters/humachi"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"polder-server/internal/activity"
	"polder-server/internal/apperr"
	"polder-server/internal/auth"
	"polder-server/internal/extract"
	"polder-server/internal/federation"
	"polder-server/internal/files"
	"polder-server/internal/groups"
	"polder-server/internal/linkpreview"
	"polder-server/internal/links"
	"polder-server/internal/logging"
	"polder-server/internal/office"
	"polder-server/internal/preview"
	"polder-server/internal/search"
	"polder-server/internal/settings"
	"polder-server/internal/sharing"
	"polder-server/internal/syncing"
	"polder-server/internal/tags"
	"polder-server/internal/users"
	"polder-server/internal/versions"
	"polder-server/internal/webdav"
)

type API struct {
	auth         *auth.Service
	sessions     *auth.Sessions
	users        *users.Service
	files        *files.Service
	settings     *settings.Store
	images       *settings.Images
	avatars      *settings.Avatars
	sync         *syncing.Service
	previews     *preview.Worker
	activity     *activity.Hub
	search       *search.Service
	extract      *extract.Worker
	logs         *logging.Files
	office       *office.Service
	versions     *versions.Worker
	links        *links.Graph
	tags         *tags.Service
	linkPreviews *linkpreview.Service
	groups       *groups.Service
	sharing      *sharing.Service
	webdav       *webdav.Handler
	federation   *federation.Service
	limiter      *failedAttemptLimiter

	federationLimiter *failedAttemptLimiter

	webdavAllowInsecure bool

	linkLimiter  *failedAttemptLimiter
	archiveSlots chan struct{}

	requestTrashPurge func()
}

type Dependencies struct {
	Auth                   *auth.Service
	Sessions               *auth.Sessions
	Users                  *users.Service
	Files                  *files.Service
	Settings               *settings.Store
	Images                 *settings.Images
	Avatars                *settings.Avatars
	Sync                   *syncing.Service
	Previews               *preview.Worker
	Activity               *activity.Hub
	Search                 *search.Service
	Extractor              *extract.Worker
	Logs                   *logging.Files
	Office                 *office.Service
	Versions               *versions.Worker
	Links                  *links.Graph
	Tags                   *tags.Service
	LinkPreviews           *linkpreview.Service
	Groups                 *groups.Service
	Sharing                *sharing.Service
	WebDAV                 *webdav.Handler
	Federation             *federation.Service
	WebDAVAllowInsecure    bool
	RequestTrashPurge      func()
	LoginAttemptsPerMinute int
	TrustedProxies         []netip.Prefix
	// Web serves the browser client for every path outside the API; nil serves only the API.
	Web http.Handler
}

func NewRouter(deps Dependencies) http.Handler {
	api := &API{
		auth:         deps.Auth,
		sessions:     deps.Sessions,
		users:        deps.Users,
		files:        deps.Files,
		settings:     deps.Settings,
		images:       deps.Images,
		avatars:      deps.Avatars,
		sync:         deps.Sync,
		previews:     deps.Previews,
		activity:     deps.Activity,
		search:       deps.Search,
		extract:      deps.Extractor,
		logs:         deps.Logs,
		office:       deps.Office,
		versions:     deps.Versions,
		links:        deps.Links,
		tags:         deps.Tags,
		linkPreviews: deps.LinkPreviews,
		groups:       deps.Groups,
		sharing:      deps.Sharing,
		webdav:       deps.WebDAV,
		federation:   deps.Federation,
		limiter:      newFailedAttemptLimiter(deps.LoginAttemptsPerMinute),

		federationLimiter: newFailedAttemptLimiter(deps.LoginAttemptsPerMinute * federationLimitFactor),

		webdavAllowInsecure: deps.WebDAVAllowInsecure,

		linkLimiter:  newFailedAttemptLimiter(deps.LoginAttemptsPerMinute),
		archiveSlots: make(chan struct{}, maxConcurrentArchives),

		requestTrashPurge: deps.RequestTrashPurge,
	}

	router := chi.NewRouter()
	router.Use(forwardedClient(deps.TrustedProxies), logRequests, recoverPanics)
	// Set before mounting so the API subrouter inherits it.
	router.NotFound(endpointNotFound)
	api.register(humachi.New(router, apiConfig()))
	// Unknown API paths answer like the API, never with the web client's index.html.
	router.Handle("/api/*", http.HandlerFunc(endpointNotFound))
	deps.Office.Routes(router)
	api.webDAVRoutes(router)
	if deps.Federation != nil {
		deps.Federation.Routes(router, federationGuard{api: api}, deps.WebDAV)
	}
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
	apiPrefix             = "/api/v1"
	bearerAuth            = "bearer"
	federationLimitFactor = 6
)

// apiConfig serves the OpenAPI document built from the registered operations at
// /api/v1/openapi.json (and .yaml), and an interactive reference at /api/v1/docs.
func apiConfig() huma.Config {
	config := huma.DefaultConfig("Polder API", "0.0.1")
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
	register(v1, http.MethodGet, "/branding", "getBranding", "How the apps present this server, shown before logging in", a.branding)
	register(v1, http.MethodGet, "/branding/icon/{imageID}", "getBrandingIcon", "The server's icon", a.brandingIcon,
		withResponse(http.StatusOK, "Icon image", binaryContent("application/octet-stream")))
	register(v1, http.MethodGet, "/branding/backgrounds/{imageID}", "getBrandingBackground", "One of the login screen's backgrounds", a.brandingBackground,
		withResponse(http.StatusOK, "Background image", binaryContent("application/octet-stream")))
	register(v1, http.MethodGet, "/users/{userID}/avatar/{imageID}", "getUserAvatar", "A user's icon", a.userAvatar,
		withResponse(http.StatusOK, "Icon image", binaryContent("application/octet-stream")))
	register(v1, http.MethodPost, "/auth/login", "login", "Log in and get a token pair", a.login)
	register(v1, http.MethodPost, "/auth/refresh", "refresh", "Exchange a refresh token for a new token pair", a.refresh)
	register(v1, http.MethodPost, "/auth/logout", "logout", "Revoke a refresh token", a.logout)
	register(v1, http.MethodGet, "/events", "events", "Live activity over a WebSocket", a.events, withDescription(eventsDescription),
		withSocketMessages(api), withResponse(http.StatusSwitchingProtocols, "WebSocket connection; every message the server sends has this shape",
			map[string]*huma.MediaType{"application/json": {Schema: api.OpenAPI().Components.Schemas.Schema(reflect.TypeFor[eventMessage](), true, "")}}))

	register(v1, http.MethodGet, "/server/info", "getServerInfo", "Version, commit and build of the server binary", a.getServerInfo)

	register(v1, http.MethodGet, "/public/links/{code}", "getPublicLink", "What a share link points to; hidden while it needs a password", a.getPublicLink)
	register(v1, http.MethodPost, "/public/links/{code}/unlock", "unlockPublicLink", "Enter a share link's password, or open a link without one, to get a token for its contents", a.unlockPublicLink)
	register(v1, http.MethodGet, "/public/links/{code}/list", "listPublicLinkFiles", "List a folder inside a share link", a.listPublicLinkFiles)
	register(v1, http.MethodGet, "/public/links/{code}/content", "downloadPublicLinkFile", "Download a file inside a share link; supports Range", a.downloadPublicLinkFile,
		withResponse(http.StatusOK, "File content", binaryContent("application/octet-stream")))
	register(v1, http.MethodGet, "/public/links/{code}/preview", "previewPublicLinkFile", "Get a thumbnail (JPEG, or PNG when it has transparency) of a file inside a share link", a.previewPublicLinkFile,
		withResponse(http.StatusOK, "Thumbnail", thumbnailContent()))
	register(v1, http.MethodGet, "/public/links/{code}/archive", "downloadPublicLinkArchive", "Download a folder inside a share link as a zip", a.downloadPublicLinkArchive,
		withResponse(http.StatusOK, "Zip archive", binaryContent("application/zip")))
	register(v1, http.MethodPut, "/public/links/{code}/content", "uploadPublicLinkFile", "Upload a file into a share link that accepts uploads; it never replaces an existing file", a.uploadPublicLinkFile,
		withRequestBody(binaryContent("application/octet-stream")))

	user := huma.NewGroup(v1)
	user.UseMiddleware(a.requireUser(api))
	user.UseSimpleModifier(requiresAuth(api, http.StatusUnauthorized))
	register(user, http.MethodGet, "/auth/me", "getMe", "The logged-in user", a.me)
	register(user, http.MethodPost, "/auth/sessions", "startSession", "Start another session for the logged-in user, such as for a file provider on this device", a.startSession, created)
	register(user, http.MethodPut, "/account/profile", "setProfile", "Change the logged-in user's name and contact details", a.setProfile)
	register(user, http.MethodPut, "/account/password", "changePassword", "Change the logged-in user's password; their other sessions are logged out", a.changePassword)
	register(user, http.MethodPut, "/account/appearance", "setAppearance", "Choose the theme and accent color the apps use for the logged-in user", a.setAppearance)
	register(user, http.MethodPut, "/account/avatar", "setAvatar", "Replace the logged-in user's icon with the image in the request body", a.setAvatar,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodDelete, "/account/avatar", "removeAvatar", "Go back to showing the logged-in user's initials", a.removeAvatar)
	register(user, http.MethodGet, "/account/app-passwords", "listAppPasswords", "The logged-in user's app passwords, for WebDAV and other apps", a.listAppPasswords)
	register(user, http.MethodPost, "/account/app-passwords", "createAppPassword", "Create an app password; needs the account password and returns the new password once", a.createAppPassword, created)
	register(user, http.MethodDelete, "/account/app-passwords/{appPasswordID}", "deleteAppPassword", "Revoke an app password; it stops working at once", a.deleteAppPassword)

	register(user, http.MethodGet, "/files/list", "listFiles", "List a directory", a.listFiles)
	register(user, http.MethodGet, "/files/stat", "statFile", "Get one file or directory", a.statFile)
	register(user, http.MethodGet, "/files/links", "listFileLinks", "What a file links to and which files link to it", a.fileLinks)
	register(user, http.MethodPost, "/files/resolve", "resolveFiles", "Look files up by id, wherever they are now", a.resolveFiles)
	register(user, http.MethodGet, "/files/content", "downloadFile", "Download a file; supports Range and conditional requests", a.downloadFile,
		withResponse(http.StatusOK, "File content", binaryContent("application/octet-stream")))
	register(user, http.MethodPut, "/files/content", "uploadFile", "Upload a whole file as the request body", a.uploadFile,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodPost, "/files/mkdir", "makeDirectory", "Create a directory", a.makeDirectory, created)
	register(user, http.MethodPost, "/files/move", "moveFile", "Move or rename a file or directory", a.moveFile)
	register(user, http.MethodPost, "/files/copy", "copyFile", "Copy a file, or a directory with everything in it", a.copyFile)
	register(user, http.MethodDelete, "/files", "deleteFile", "Delete a file or directory", a.deleteFile)
	register(user, http.MethodGet, "/files/preview", "previewFile", "Get a thumbnail (JPEG, or PNG when it has transparency) of an image, video or document", a.previewFile,
		withResponse(http.StatusOK, "Thumbnail", thumbnailContent()))

	register(user, http.MethodGet, "/files/versions", "listFileVersions", "List a file's earlier versions, newest first", a.listVersions)
	register(user, http.MethodGet, "/files/versions/{versionID}/content", "downloadFileVersion", "Download an earlier version of a file", a.downloadVersion,
		withResponse(http.StatusOK, "Version content", binaryContent("application/octet-stream")))
	register(user, http.MethodGet, "/files/versions/{versionID}/preview", "previewFileVersion", "Get a thumbnail (JPEG, or PNG when it has transparency) of an earlier version", a.previewVersion,
		withResponse(http.StatusOK, "Thumbnail", thumbnailContent()))
	register(user, http.MethodPost, "/files/versions/{versionID}/restore", "restoreFileVersion", "Make an earlier version the current file; the current content is kept as a version", a.restoreVersion)
	register(user, http.MethodDelete, "/files/versions/{versionID}", "deleteFileVersion", "Delete one earlier version permanently", a.deleteVersion)
	register(user, http.MethodGet, "/versions/settings", "getVersionSettings", "How long earlier versions of files are kept", a.getVersionSettings)
	register(user, http.MethodPut, "/versions/settings", "setVersionSettings", "Choose how long earlier versions of files are kept, within the server's limits", a.setVersionSettings)

	register(user, http.MethodGet, "/notes/list", "listNotes", "List the folders and notes in a folder", a.listNotes)
	register(user, http.MethodGet, "/notes/settings", "getNotesSettings", "Which folder holds the user's notes", a.getNotesSettings)
	register(user, http.MethodPut, "/notes/settings", "setNotesSettings", "Choose the folder that holds the user's notes; it must already exist", a.setNotesSettings)

	register(user, http.MethodGet, "/search", "searchFiles", "Find files and folders by name, text inside them, type, date and size", a.searchFiles,
		withDescription(searchDescription))
	register(user, http.MethodGet, "/search/suggest", "suggestSearch", "Complete the search filter under the cursor", a.suggestSearch)

	register(user, http.MethodGet, "/tags", "listTags", "The logged-in user's tags with how many items carry each", a.listTags)
	register(user, http.MethodPost, "/tags", "createTag", "Create a tag; names are unique per user, ignoring case", a.createTag, created)
	register(user, http.MethodDelete, "/tags/unused", "deleteUnusedTags", "Delete the user's tags that no item or own note carries", a.deleteUnusedTags)
	register(user, http.MethodPatch, "/tags/{tagID}", "updateTag", "Rename or recolor a tag; a rename also rewrites the tag in the user's own notes", a.updateTag)
	register(user, http.MethodDelete, "/tags/{tagID}", "deleteTag", "Delete a tag and remove it from the user's items and own notes", a.deleteTag)
	register(user, http.MethodPost, "/tags/assign", "assignTags", "Add tags to files, folders and notes; unknown names become new tags", a.assignTags)
	register(user, http.MethodPost, "/tags/unassign", "unassignTags", "Remove tags from files, folders and notes", a.unassignTags)

	register(user, http.MethodGet, "/trash", "listTrash", "List deleted items, most recent first", a.listTrash)
	register(user, http.MethodDelete, "/trash", "emptyTrash", "Delete everything in the trash permanently", a.emptyTrash)
	register(user, http.MethodGet, "/trash/retention", "getTrashRetention", "How long deleted items stay in the trash", a.getTrashRetention)
	register(user, http.MethodPut, "/trash/retention", "setTrashRetention", "Choose how long deleted items stay in the trash", a.setTrashRetention)
	register(user, http.MethodPost, "/trash/{itemID}/restore", "restoreTrashItem", "Put a deleted item back where it was", a.restoreTrashItem)
	register(user, http.MethodGet, "/trash/{itemID}/content", "downloadTrashItem", "Download a deleted item without restoring it; a directory comes as a zip", a.downloadTrashItem,
		withResponse(http.StatusOK, "Item content", binaryContent("application/octet-stream")))
	register(user, http.MethodGet, "/trash/{itemID}/preview", "previewTrashItem", "Get a thumbnail (JPEG, or PNG when it has transparency) of a deleted image, video or document", a.previewTrashItem,
		withResponse(http.StatusOK, "Thumbnail", thumbnailContent()))
	register(user, http.MethodDelete, "/trash/{itemID}", "deleteTrashItem", "Delete one item in the trash permanently", a.deleteTrashItem)

	register(user, http.MethodGet, "/office/capabilities", "getOfficeCapabilities", "Which files the document editor can open", a.officeCapabilities)
	register(user, http.MethodPost, "/office/sessions", "startOfficeSession", "Let the document editor open a file", a.startOfficeSession, created)

	register(user, http.MethodGet, "/activity", "listActivity", "Page through what happened to files and sessions, newest first", a.listActivity)
	register(user, http.MethodGet, "/activity/live", "listLiveTransfers", "Uploads and downloads in progress", a.listLiveTransfers)

	register(user, http.MethodGet, "/directory", "searchDirectory", "Find users and groups to share with", a.searchDirectory)

	register(user, http.MethodGet, "/groups", "listGroups", "Groups the logged-in user is in or created, or every group for administrators", a.listGroups)
	register(user, http.MethodPost, "/groups", "createGroup", "Create a group; the creator becomes its admin", a.createGroup, created)
	register(user, http.MethodGet, "/groups/{groupID}", "getGroup", "A group and its members", a.getGroup)
	register(user, http.MethodPatch, "/groups/{groupID}", "renameGroup", "Rename a group; group admins only", a.renameGroup)
	register(user, http.MethodDelete, "/groups/{groupID}", "deleteGroup", "Delete a group; what was shared with it is no longer shared", a.deleteGroup)
	register(user, http.MethodPost, "/groups/{groupID}/members", "addGroupMember", "Add someone to a group; group admins only", a.addGroupMember, created)
	register(user, http.MethodPatch, "/groups/{groupID}/members/{userID}", "setGroupMemberRole", "Change a member's role; group admins only", a.setGroupMemberRole)
	register(user, http.MethodDelete, "/groups/{groupID}/members/{userID}", "removeGroupMember", "Remove someone from a group, or leave it yourself", a.removeGroupMember)
	register(user, http.MethodGet, "/groups/{groupID}/shares", "listGroupShares", "What is shared with a group", a.listGroupShares)

	register(user, http.MethodGet, "/shares/outgoing", "listOutgoingShares", "What the logged-in user shares with others", a.listOutgoingShares)
	register(user, http.MethodGet, "/shares/settings", "getShareDisplaySettings", "Whether shares appear in the logged-in user's files", a.getShareDisplaySettings)
	register(user, http.MethodPut, "/shares/settings", "setShareDisplaySettings", "Show or hide shares at the root of the logged-in user's files", a.setShareDisplaySettings)
	register(user, http.MethodGet, "/shares/incoming", "listIncomingShares", "What others share with the logged-in user, directly or through a group", a.listIncomingShares)
	register(user, http.MethodPost, "/shares", "createShare", "Share a file or folder with a user or group", a.createShare, created)
	register(user, http.MethodPatch, "/shares/{shareID}", "updateShare", "Change what a share's recipients may do", a.updateShare)
	register(user, http.MethodDelete, "/shares/{shareID}", "deleteShare", "Stop sharing; recipients of a direct share may also remove it", a.deleteShare)
	register(user, http.MethodGet, "/shares/{shareID}/list", "listShareFiles", "List a folder inside a share", a.listShareFiles)
	register(user, http.MethodGet, "/shares/{shareID}/stat", "statShareFile", "Get one file or folder inside a share", a.statShareFile)
	register(user, http.MethodGet, "/shares/{shareID}/content", "downloadShareFile", "Download a file inside a share; supports Range", a.downloadShareFile,
		withResponse(http.StatusOK, "File content", binaryContent("application/octet-stream")))
	register(user, http.MethodGet, "/shares/{shareID}/preview", "previewShareFile", "Get a thumbnail (JPEG, or PNG when it has transparency) of a file inside a share", a.previewShareFile,
		withResponse(http.StatusOK, "Thumbnail", thumbnailContent()))
	register(user, http.MethodGet, "/shares/{shareID}/archive", "downloadShareArchive", "Download a folder inside a share as a zip", a.downloadShareArchive,
		withResponse(http.StatusOK, "Zip archive", binaryContent("application/zip")))
	register(user, http.MethodPut, "/shares/{shareID}/content", "uploadShareFile", "Upload a file into a share that allows changes", a.uploadShareFile,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodPost, "/shares/{shareID}/mkdir", "makeShareDirectory", "Create a folder inside a share that allows changes", a.makeShareDirectory, created)
	register(user, http.MethodPost, "/shares/{shareID}/move", "moveShareFile", "Move or rename inside a share that allows changes", a.moveShareFile)
	register(user, http.MethodPost, "/shares/{shareID}/copy", "copyShareFile", "Copy inside a share that allows changes", a.copyShareFile)
	register(user, http.MethodDelete, "/shares/{shareID}/files", "deleteShareFile", "Delete inside a share that allows changes; it goes to the owner's trash", a.deleteShareFile)

	register(user, http.MethodGet, "/link-previews", "getLinkPreview", "Describe a web link with its title, summary and site, as the server sees it", a.linkPreview)
	register(user, http.MethodGet, "/link-previews/image", "getLinkPreviewImage", "Get a web link's preview image or site icon, fetched by the server", a.linkPreviewImage,
		withResponse(http.StatusOK, "Preview image", binaryContent("image/*")))
	register(user, http.MethodGet, "/links", "listShareLinks", "The logged-in user's share links", a.listShareLinks)
	register(user, http.MethodPost, "/links", "createShareLink", "Create a share link to a file or folder", a.createShareLink, created)
	register(user, http.MethodPatch, "/links/{linkID}", "updateShareLink", "Change a share link's access, password or expiry", a.updateShareLink)
	register(user, http.MethodDelete, "/links/{linkID}", "deleteShareLink", "Delete a share link; it stops working at once", a.deleteShareLink)
	register(user, http.MethodGet, "/links/match/{code}", "matchShareLink", "Find where a share link's item is for the logged-in user: their own file or inside a share", a.matchShareLink)

	register(user, http.MethodGet, "/federation/status", "getFederationStatus", "Whether federated sharing is available, and the logged-in user's cloud ID", a.federationStatus)
	register(user, http.MethodGet, "/federation/invites", "listFederationInvites", "The logged-in user's open invites for people on other servers", a.listInvites)
	register(user, http.MethodPost, "/federation/invites", "createFederationInvite", "Create an invite token that someone on another server can accept", a.createInvite, created)
	register(user, http.MethodDelete, "/federation/invites/{id}", "revokeFederationInvite", "Revoke an open invite", a.revokeInvite)
	register(user, http.MethodPost, "/federation/invites/accept", "acceptFederationInvite", "Accept an invite from someone on a trusted server; they become a contact", a.acceptInvite, created)
	register(user, http.MethodGet, "/federation/contacts", "listFederationContacts", "People on other servers who exchanged an invite with the logged-in user", a.listContacts)
	register(user, http.MethodDelete, "/federation/contacts/{id}", "removeFederationContact", "Remove a contact", a.removeContact)
	register(user, http.MethodGet, "/federation/shares/outgoing", "listOutgoingFederatedShares", "What the logged-in user shares with people on other servers", a.listOutgoingFederatedShares)
	register(user, http.MethodPost, "/federation/shares/outgoing", "createFederatedShare", "Share a file or folder with someone on a trusted server", a.createFederatedShare, created)
	register(user, http.MethodPatch, "/federation/shares/outgoing/{shareID}", "updateFederatedShare", "Change what a federated recipient may do", a.updateFederatedShare)
	register(user, http.MethodDelete, "/federation/shares/outgoing/{shareID}", "deleteFederatedShare", "Stop sharing with a federated recipient; their access ends at once", a.deleteFederatedShare)
	register(user, http.MethodGet, "/federation/shares/incoming", "listIncomingFederatedShares", "What people on other servers share with the logged-in user", a.listIncomingFederatedShares)
	register(user, http.MethodPost, "/federation/shares/incoming/{shareID}/accept", "acceptFederatedShare", "Accept a share from another server", a.acceptFederatedShare)
	register(user, http.MethodDelete, "/federation/shares/incoming/{shareID}", "removeIncomingFederatedShare", "Decline or remove a share from another server", a.removeIncomingFederatedShare)
	register(user, http.MethodGet, "/federation/shares/incoming/{shareID}/list", "listFederatedShareFiles", "List a folder inside a share from another server", a.listFederatedShareFiles)
	register(user, http.MethodGet, "/federation/shares/incoming/{shareID}/content", "downloadFederatedShareFile", "Download a file inside a share from another server; supports Range", a.downloadFederatedShareFile,
		withResponse(http.StatusOK, "File content", binaryContent("application/octet-stream")))
	register(user, http.MethodPut, "/federation/shares/incoming/{shareID}/content", "uploadFederatedShareFile", "Upload a file into a share from another server that allows changes", a.uploadFederatedShareFile,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodPost, "/federation/shares/incoming/{shareID}/mkdir", "makeFederatedShareDirectory", "Create a folder inside a share from another server", a.makeFederatedShareDirectory)
	register(user, http.MethodPost, "/federation/shares/incoming/{shareID}/move", "moveFederatedShareFile", "Move or rename inside a share from another server", a.moveFederatedShareFile)
	register(user, http.MethodPost, "/federation/shares/incoming/{shareID}/copy", "copyFederatedShareFile", "Copy inside a share from another server", a.copyFederatedShareFile)
	register(user, http.MethodDelete, "/federation/shares/incoming/{shareID}/files", "deleteFederatedShareFile", "Delete inside a share from another server", a.deleteFederatedShareFile)

	register(user, http.MethodGet, "/sync/changes", "listChanges", "Page through changes since a cursor", a.changes)
	register(user, http.MethodGet, "/sync/manifest", "getManifest", "Get a file's chunk manifest for delta sync", a.manifest)
	register(user, http.MethodPost, "/sync/downloads", "downloadSyncFiles",
		"Send several files in one response: per file a JSON header line, then exactly size bytes of content", a.downloadBatch,
		withResponse(http.StatusOK, "The files, back to back", binaryContent("application/octet-stream")))
	register(user, http.MethodPost, "/sync/batches", "createUploadBatch", "Start uploading a batch of files; returns the chunks the server is missing", a.createUploadBatch,
		created, maxBody(uploadPlanLimit))
	register(user, http.MethodGet, "/sync/batches/{batchID}", "getUploadBatch", "Get the chunks a batch is still missing and the files that are done", a.uploadBatchStatus)
	register(user, http.MethodPut, "/sync/batches/{batchID}/stream", "streamUploadBatch",
		"Send the missing chunks back to back as one body; each file is stored once it is complete", a.streamUploadBatch,
		withRequestBody(binaryContent("application/octet-stream")))
	register(user, http.MethodDelete, "/sync/batches/{batchID}", "abortUploadBatch", "Cancel a batch; files already stored stay", a.abortUploadBatch)

	admin := huma.NewGroup(user)
	admin.UseMiddleware(requireAdmin(api))
	admin.UseSimpleModifier(requiresAuth(api, http.StatusForbidden))
	register(admin, http.MethodGet, "/admin/users", "listUsers", "List all users", a.listUsers)
	register(admin, http.MethodPost, "/admin/users", "createUser", "Create a user", a.createUser, created)
	register(admin, http.MethodPatch, "/admin/users/{userID}", "updateUser", "Change a user; password changes and disabling log the user out", a.updateUser)
	register(admin, http.MethodGet, "/admin/settings", "getServerSettings", "Server-wide settings", a.getServerSettings)
	register(admin, http.MethodPatch, "/admin/settings", "updateServerSettings", "Change server-wide settings", a.updateServerSettings)
	register(admin, http.MethodPut, "/admin/branding/icon", "setBrandingIcon", "Replace the server's icon with the image in the request body", a.setBrandingIcon,
		withRequestBody(binaryContent("application/octet-stream")))
	register(admin, http.MethodDelete, "/admin/branding/icon", "removeBrandingIcon", "Go back to the apps' own icon", a.removeBrandingIcon)
	register(admin, http.MethodPost, "/admin/branding/backgrounds", "addBrandingBackground", "Add the image in the request body to the login screen's backgrounds", a.addBrandingBackground,
		created, withRequestBody(binaryContent("application/octet-stream")))
	register(admin, http.MethodDelete, "/admin/branding/backgrounds/{imageID}", "removeBrandingBackground", "Remove one of the login screen's backgrounds", a.removeBrandingBackground)
	register(admin, http.MethodGet, "/admin/search", "getSearchStatus", "State of the search index and of reading text from files", a.searchStatus)
	register(admin, http.MethodPost, "/admin/search/rebuild", "rebuildSearchIndex", "Rebuild the search index from scratch in the background", a.rebuildSearchIndex, accepted)
	register(admin, http.MethodPost, "/admin/previews/regenerate", "regeneratePreviews", "Make every file's preview again in the background", a.regeneratePreviews, accepted)
	register(admin, http.MethodDelete, "/admin/users/{userID}", "deleteUser", "Delete a user; their files are archived on the server", a.deleteUser)
	register(admin, http.MethodGet, "/admin/federation/servers", "listTrustedServers", "Servers this server federates with", a.listTrustedServers)
	register(admin, http.MethodPost, "/admin/federation/servers", "addTrustedServer", "Trust a server for federated sharing; its signing key is pinned", a.addTrustedServer, created)
	register(admin, http.MethodPatch, "/admin/federation/servers/{serverID}", "updateTrustedServer", "Change how a trusted server is reached and checked", a.updateTrustedServer)
	register(admin, http.MethodPost, "/admin/federation/servers/{serverID}/refresh", "refreshTrustedServer", "Discover a trusted server again and pin its current signing key", a.refreshTrustedServer)
	register(admin, http.MethodDelete, "/admin/federation/servers/{serverID}", "removeTrustedServer", "Stop trusting a server; every share with it ends", a.removeTrustedServer)
	register(admin, http.MethodGet, "/admin/logs", "listLogs", "Page through the server log, newest first", a.listLogs)
	register(admin, http.MethodGet, "/admin/logs/components", "listLogComponents", "Parts of the server that appear in the log", a.listLogComponents)
	register(admin, http.MethodGet, "/admin/logs/files", "listLogFiles", "The log files, one per day, newest first", a.listLogFiles)
	register(admin, http.MethodGet, "/admin/logs/files/{name}", "downloadLogFile", "Download one day's log file as JSON lines", a.downloadLogFile,
		withResponse(http.StatusOK, "Log file", binaryContent("application/x-ndjson")))

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

func accepted(operation *huma.Operation) {
	operation.DefaultStatus = http.StatusAccepted
}

func maxBody(limit int64) func(*huma.Operation) {
	return func(operation *huma.Operation) { operation.MaxBodyBytes = limit }
}

func withRequestBody(content map[string]*huma.MediaType) func(*huma.Operation) {
	return func(operation *huma.Operation) {
		operation.RequestBody = &huma.RequestBody{Required: true, Content: content}
	}
}

func withDescription(description string) func(*huma.Operation) {
	return func(operation *huma.Operation) { operation.Description = description }
}

func withResponse(status int, description string, content map[string]*huma.MediaType) func(*huma.Operation) {
	return func(operation *huma.Operation) {
		operation.Responses = map[string]*huma.Response{strconv.Itoa(status): {Description: description, Content: content}}
	}
}

// withSocketMessages names the schema of what clients send over the events socket. Huma drops
// schemas nothing references, and a socket message has no request body to reference it from.
func withSocketMessages(api huma.API) func(*huma.Operation) {
	schema := api.OpenAPI().Components.Schemas.Schema(reflect.TypeFor[clientMessage](), true, "")
	return func(operation *huma.Operation) {
		operation.Extensions = map[string]any{"x-client-message": schema}
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
