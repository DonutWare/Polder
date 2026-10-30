package app_test

import (
	"archive/zip"
	"bytes"
	"fmt"
	"image"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"

	"polder-server/internal/config"
	"polder-server/internal/preview"
)

func TestVideosGetFrameThumbnails(t *testing.T) {
	requireFFmpeg(t)
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/Videos/clip.mp4", 0, portraitVideo(t), http.StatusOK, nil)

	ready := waitForPreview(t, alice, "/Videos/clip.mp4")
	if ready.PreviewState != "ready" || ready.Meta["width"] != float64(240) || ready.Meta["height"] != float64(320) ||
		ready.Meta["duration"] != float64(2) {
		t.Fatalf("preview not generated correctly: %+v", ready)
	}
	thumbnail := fetchThumbnail(t, alice, "/Videos/clip.mp4")
	if thumbnail.Bounds().Dx() != 96 || thumbnail.Bounds().Dy() != 128 {
		t.Fatalf("thumbnail should be upright, got %v", thumbnail.Bounds())
	}
}

func TestTiledPhotosGetWholeUprightThumbnails(t *testing.T) {
	requireFFmpeg(t)
	photo, err := os.ReadFile(filepath.Join("testdata", "rotated-grid.heic"))
	if err != nil {
		t.Fatal(err)
	}
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 0)
	alice.put("/Photos/grid.heic", 0, photo, http.StatusOK, nil)

	ready := waitForPreview(t, alice, "/Photos/grid.heic")
	if ready.PreviewState != "ready" || ready.Meta["width"] != float64(768) || ready.Meta["height"] != float64(1024) ||
		!strings.HasPrefix(fmt.Sprint(ready.Meta["takenAt"]), "2024-05-01T") || ready.Meta["duration"] != nil {
		t.Fatalf("preview not generated correctly: %+v", ready)
	}
	thumbnail := fetchThumbnail(t, alice, "/Photos/grid.heic")
	if thumbnail.Bounds().Dx() != 96 || thumbnail.Bounds().Dy() != 128 {
		t.Fatalf("thumbnail should show every tile, upright, got %v", thumbnail.Bounds())
	}
}

func TestDocumentsShowTheThumbnailTheyCarry(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 0)

	alice.put("/Docs/notes.odt", 0, zipArchive(t, map[string][]byte{
		"Thumbnails/thumbnail.png": encodedPNG(t, 181, 256),
		"meta.xml": []byte(`<office:document-meta xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" ` +
			`xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0"><office:meta>` +
			`<meta:document-statistic meta:page-count="3"/></office:meta></office:document-meta>`),
	}), http.StatusOK, nil)
	alice.put("/Docs/slides.pptx", 0, zipArchive(t, map[string][]byte{
		"_rels/.rels": []byte(`<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">` +
			`<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/thumbnail" Target="docProps/thumbnail.png"/>` +
			`</Relationships>`),
		"docProps/thumbnail.png": encodedPNG(t, 256, 144),
		"docProps/app.xml":       []byte(`<Properties><Slides>12</Slides></Properties>`),
	}), http.StatusOK, nil)
	alice.put("/Docs/plain.docx", 0, documentWithoutThumbnail(t), http.StatusOK, nil)
	alice.put("/Docs/data.bin", 0, []byte{0, 1, 2}, http.StatusOK, nil)

	if notes := waitForPreview(t, alice, "/Docs/notes.odt"); notes.PreviewState != "ready" || notes.Meta["pages"] != float64(3) {
		t.Fatalf("OpenDocument thumbnail: %+v", notes)
	}
	if slides := waitForPreview(t, alice, "/Docs/slides.pptx"); slides.PreviewState != "ready" || slides.Meta["pages"] != float64(12) {
		t.Fatalf("Office Open XML thumbnail: %+v", slides)
	}
	if thumbnail := fetchThumbnail(t, alice, "/Docs/slides.pptx"); thumbnail.Bounds().Dx() != 128 || thumbnail.Bounds().Dy() != 72 {
		t.Fatalf("thumbnail: %v", thumbnail.Bounds())
	}
	if plain := waitForPreview(t, alice, "/Docs/plain.docx"); plain.PreviewState != "none" {
		t.Fatalf("without Collabora a document without a thumbnail has no preview, got %s", plain.PreviewState)
	}
	if other := waitForPreview(t, alice, "/Docs/data.bin"); other.PreviewState != "none" {
		t.Fatalf("a file nothing can read should have no preview, got %s", other.PreviewState)
	}
}

func TestCollaboraDrawsDocumentsWithoutAThumbnail(t *testing.T) {
	collabora, converted := startFakeCollabora(t, http.StatusOK)
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.CollaboraURL = collabora })
	alice := server.createUser(server.setupAdmin(), "alice", 0)

	alice.put("/Docs/plain.docx", 0, documentWithoutThumbnail(t), http.StatusOK, nil)
	alice.put("/Docs/notes.odt", 0, zipArchive(t, map[string][]byte{"Thumbnails/thumbnail.png": encodedPNG(t, 181, 256)}),
		http.StatusOK, nil)

	if plain := waitForPreview(t, alice, "/Docs/plain.docx"); plain.PreviewState != "ready" || plain.Meta["pages"] != float64(1) {
		t.Fatalf("Collabora should draw a document without a thumbnail: %+v", plain)
	}
	if notes := waitForPreview(t, alice, "/Docs/notes.odt"); notes.PreviewState != "ready" {
		t.Fatalf("embedded thumbnail: %+v", notes)
	}
	if names := converted(); !slices.Equal(names, []string{"plain.docx"}) {
		t.Fatalf("only the document without a thumbnail should go to Collabora, under its name; got %v", names)
	}
}

func TestDocumentsAreNotFailedWhenCollaboraRefusesToConvert(t *testing.T) {
	collabora, _ := startFakeCollabora(t, http.StatusForbidden)
	server := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.CollaboraURL = collabora })
	alice := server.createUser(server.setupAdmin(), "alice", 0)

	alice.put("/Docs/plain.docx", 0, documentWithoutThumbnail(t), http.StatusOK, nil)
	if plain := waitForPreview(t, alice, "/Docs/plain.docx"); plain.PreviewState != "none" {
		t.Fatalf("a refusal is Collabora's setup, not the file's fault, so it should not fail the file; got %s", plain.PreviewState)
	}
}

func TestVideosGetThumbnailsOnceFFmpegIsInstalled(t *testing.T) {
	requireFFmpeg(t)
	before := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) { cfg.FFmpegPath = "missing-ffmpeg" })
	alice := before.createUser(before.setupAdmin(), "alice", 0)
	alice.put("/Videos/clip.mp4", 0, portraitVideo(t), http.StatusOK, nil)
	if entry := waitForPreview(t, alice, "/Videos/clip.mp4"); entry.PreviewState != "none" {
		t.Fatalf("without ffmpeg a video has no preview, got %s", entry.PreviewState)
	}
	before.stop()

	after := startServer(t, config.DriverSQLite, "", func(cfg *config.Config) {
		cfg.ConfigDir, cfg.DataDir = before.app.Config.ConfigDir, before.app.Config.DataDir
	})
	alice = after.login("alice", "password1")
	deadline := time.Now().Add(time.Minute)
	entry := waitForPreview(t, alice, "/Videos/clip.mp4")
	for entry.PreviewState == "none" && time.Now().Before(deadline) {
		time.Sleep(50 * time.Millisecond)
		entry = waitForPreview(t, alice, "/Videos/clip.mp4")
	}
	if entry.PreviewState != "ready" {
		t.Fatalf("existing videos should get a preview once ffmpeg is there, got %s", entry.PreviewState)
	}
}

func startFakeCollabora(t *testing.T, conversionStatus int) (string, func() []string) {
	var mu sync.Mutex
	var converted []string
	collabora := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/hosting/discovery":
			_, _ = io.WriteString(w, fakeDiscovery)
		case "/cool/convert-to/pdf":
			if conversionStatus != http.StatusOK {
				w.WriteHeader(conversionStatus)
				return
			}
			file, header, err := r.FormFile("data")
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			defer file.Close()
			mu.Lock()
			converted = append(converted, header.Filename)
			mu.Unlock()
			_, _ = io.WriteString(w, redHalfPDF)
		default:
			http.NotFound(w, r)
		}
	}))
	t.Cleanup(collabora.Close)
	return collabora.URL, func() []string {
		mu.Lock()
		defer mu.Unlock()
		return slices.Clone(converted)
	}
}

func documentWithoutThumbnail(t *testing.T) []byte {
	return zipArchive(t, map[string][]byte{"_rels/.rels": []byte(`<Relationships/>`)})
}

func requireFFmpeg(t *testing.T) {
	t.Helper()
	if _, err := exec.LookPath("ffmpeg"); err != nil {
		t.Skip("ffmpeg is not installed")
	}
}

func portraitVideo(t *testing.T) []byte {
	t.Helper()
	dir := t.TempDir()
	plain, clip := filepath.Join(dir, "plain.mp4"), filepath.Join(dir, "clip.mp4")
	runFFmpeg(t, "-f", "lavfi", "-i", "testsrc=size=320x240:rate=10:duration=2", "-pix_fmt", "yuv420p", plain)
	runFFmpeg(t, "-display_rotation", "90", "-i", plain, "-c", "copy", clip)
	content, err := os.ReadFile(clip)
	if err != nil {
		t.Fatal(err)
	}
	return content
}

func runFFmpeg(t *testing.T, args ...string) {
	t.Helper()
	command := exec.Command("ffmpeg", append([]string{"-hide_banner", "-loglevel", "error"}, args...)...)
	if output, err := command.CombinedOutput(); err != nil {
		t.Fatalf("ffmpeg %v: %v: %s", args, err, output)
	}
}

func zipArchive(t *testing.T, parts map[string][]byte) []byte {
	t.Helper()
	var archive bytes.Buffer
	writer := zip.NewWriter(&archive)
	for name, content := range parts {
		part, err := writer.Create(name)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := part.Write(content); err != nil {
			t.Fatal(err)
		}
	}
	if err := writer.Close(); err != nil {
		t.Fatal(err)
	}
	return archive.Bytes()
}

func waitForPreview(t *testing.T, user *client, path string) fileEntry {
	t.Helper()
	var entry fileEntry
	for deadline := time.Now().Add(time.Minute); time.Now().Before(deadline); time.Sleep(50 * time.Millisecond) {
		entry = user.stat(path)
		if entry.PreviewState != "pending" {
			return entry
		}
	}
	t.Fatalf("%s is still awaiting a preview", path)
	return entry
}

func fetchThumbnail(t *testing.T, user *client, path string) image.Image {
	t.Helper()
	response := user.request(http.MethodGet, "/files/preview?size=128&path="+url.QueryEscape(path), nil, nil)
	defer response.Body.Close()
	thumbnail, _, err := image.Decode(response.Body)
	if response.StatusCode != http.StatusOK || err != nil {
		t.Fatalf("thumbnail of %s: status %d err %v", path, response.StatusCode, err)
	}
	return thumbnail
}

func TestAdminsCanRegenerateEveryPreview(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	admin := server.setupAdmin()
	alice := server.createUser(admin, "alice", 0)
	hash := uploadWithPreview(t, alice, "/cat.png", encodedPNG(t, 400, 300))
	alice.put("/notes.txt", 0, []byte("hello"), http.StatusOK, nil)
	thumbnails := filepath.Join(server.app.Config.PreviewCacheDir(), hash[:2], hash+"-*")
	matches, _ := filepath.Glob(thumbnails)
	for _, match := range matches {
		if err := os.Remove(match); err != nil {
			t.Fatal(err)
		}
	}

	alice.mustJSON(http.MethodPost, "/admin/previews/regenerate", nil, http.StatusForbidden, nil)
	var queued struct {
		Files int64 `json:"files"`
	}
	admin.mustJSON(http.MethodPost, "/admin/previews/regenerate", nil, http.StatusAccepted, &queued)
	if queued.Files != 2 {
		t.Fatalf("want both files queued, got %d", queued.Files)
	}
	if ready := waitForPreview(t, alice, "/cat.png"); ready.PreviewState != "ready" {
		t.Fatalf("preview not regenerated: %+v", ready)
	}
	if notes := waitForPreview(t, alice, "/notes.txt"); notes.PreviewState != "none" {
		t.Fatalf("files without a preview should go back to none, got %s", notes.PreviewState)
	}
	expectFiles(t, thumbnails, len(preview.Sizes))
}
