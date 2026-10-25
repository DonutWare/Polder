package linkpreview

import (
	"bytes"
	"context"
	"image"
	"image/color"
	"image/png"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"
	"time"

	"polder-server/internal/apperr"
)

func pngBytes(t *testing.T) []byte {
	t.Helper()
	picture := image.NewRGBA(image.Rect(0, 0, 2, 2))
	picture.Set(0, 0, color.White)
	var buffer bytes.Buffer
	if err := png.Encode(&buffer, picture); err != nil {
		t.Fatal(err)
	}
	return buffer.Bytes()
}

func TestPageReadsOpenGraphAndFallbacks(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/article":
			w.Header().Set("Content-Type", "text/html; charset=utf-8")
			_, _ = w.Write([]byte(`<!doctype html><html><head>
<title>  Fallback   title </title>
<meta property="og:title" content="Rock &amp; Roll">
<meta name="description" content="A plain description">
<meta property="og:image" content="/images/cover.png">
<link rel="icon" href="favicon.png">
</head><body><meta property="og:title" content="ignored"></body></html>`))
		case "/plain":
			w.Header().Set("Content-Type", "text/html")
			_, _ = w.Write([]byte(`<html><head><title>Only a title</title></head></html>`))
		case "/moved":
			http.Redirect(w, r, "/plain", http.StatusFound)
		default:
			http.NotFound(w, r)
		}
	}))
	defer server.Close()
	service := New(Options{AllowPrivate: true})

	page, err := service.Page(context.Background(), 1, server.URL+"/article#section")
	if err != nil {
		t.Fatal(err)
	}
	if page.URL != server.URL+"/article" || page.Title != "Rock & Roll" || page.Description != "A plain description" {
		t.Fatalf("unexpected page %+v", page)
	}
	if page.Image != server.URL+"/images/cover.png" || page.Icon != server.URL+"/favicon.png" {
		t.Fatalf("relative links not resolved: %+v", page)
	}
	if page.SiteName != "127.0.0.1" {
		t.Fatalf("site name %q", page.SiteName)
	}

	moved, err := service.Page(context.Background(), 1, server.URL+"/moved")
	if err != nil {
		t.Fatal(err)
	}
	if moved.Title != "Only a title" || moved.URL != server.URL+"/moved" || moved.Icon != server.URL+"/favicon.ico" {
		t.Fatalf("redirected page %+v", moved)
	}
}

func TestPageOfAnUnreachableLinkStillNamesTheSite(t *testing.T) {
	server := httptest.NewServer(http.NotFoundHandler())
	defer server.Close()
	page, err := New(Options{AllowPrivate: true}).Page(context.Background(), 1, server.URL+"/gone")
	if err != nil {
		t.Fatal(err)
	}
	if page.Title != "" || page.SiteName != "127.0.0.1" {
		t.Fatalf("unexpected page %+v", page)
	}
}

func TestPagesAreCached(t *testing.T) {
	var hits atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		hits.Add(1)
		w.Header().Set("Content-Type", "text/html")
		_, _ = w.Write([]byte(`<title>Cached</title>`))
	}))
	defer server.Close()
	service := New(Options{AllowPrivate: true})
	for range 3 {
		if _, err := service.Page(context.Background(), 1, server.URL); err != nil {
			t.Fatal(err)
		}
	}
	if hits.Load() != 1 {
		t.Fatalf("fetched %d times", hits.Load())
	}
}

func TestPrivateAddressesAreRefusedByDefault(t *testing.T) {
	var hits atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		hits.Add(1)
		_, _ = w.Write([]byte(`<title>Secret</title>`))
	}))
	defer server.Close()
	page, err := New(Options{}).Page(context.Background(), 1, server.URL)
	if err != nil {
		t.Fatal(err)
	}
	if hits.Load() != 0 || page.Title != "" {
		t.Fatalf("reached a private address: %+v", page)
	}
}

func TestOnlyWebLinksArePreviewed(t *testing.T) {
	service := New(Options{AllowPrivate: true})
	for _, raw := range []string{"file:///etc/passwd", "ftp://example.com", "https://user:pass@example.com", "notaurl", strings.Repeat("a", 3000)} {
		if _, err := service.Page(context.Background(), 1, raw); !apperr.Is(err, apperr.KindInvalid) {
			t.Errorf("%q: got %v", raw, err)
		}
	}
}

func TestImagesComeFromThePagePreview(t *testing.T) {
	picture := pngBytes(t)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/":
			w.Header().Set("Content-Type", "text/html")
			_, _ = w.Write([]byte(`<head><meta property="og:image" content="/cover"><link rel="icon" href="/logo.svg"></head>`))
		case "/cover":
			w.Header().Set("Content-Type", "application/octet-stream")
			_, _ = w.Write(picture)
		case "/logo.svg":
			w.Header().Set("Content-Type", "image/svg+xml")
			_, _ = w.Write([]byte(`<svg xmlns="http://www.w3.org/2000/svg"><script>alert(1)</script></svg>`))
		}
	}))
	defer server.Close()
	service := New(Options{AllowPrivate: true})

	asset, err := service.Image(context.Background(), 1, server.URL+"/", KindImage)
	if err != nil {
		t.Fatal(err)
	}
	if asset.ContentType != "image/png" || !bytes.Equal(asset.Body, picture) {
		t.Fatalf("unexpected image %q", asset.ContentType)
	}
	if _, err := service.Image(context.Background(), 1, server.URL+"/", KindIcon); !apperr.Is(err, apperr.KindNotFound) {
		t.Fatalf("svg icon served: %v", err)
	}
}

func TestMissingIconsAreRememberedAsMissing(t *testing.T) {
	var iconHits atomic.Int32
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/favicon.ico" {
			iconHits.Add(1)
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html")
		_, _ = w.Write([]byte(`<title>No icon</title>`))
	}))
	defer server.Close()
	service := New(Options{AllowPrivate: true})
	for range 3 {
		if _, err := service.Image(context.Background(), 1, server.URL+"/", KindIcon); !apperr.Is(err, apperr.KindNotFound) {
			t.Fatalf("missing icon: %v", err)
		}
	}
	if iconHits.Load() != 1 {
		t.Fatalf("fetched the icon %d times", iconHits.Load())
	}
}

func TestCancelledRequestsDoNotCacheAnEmptyPage(t *testing.T) {
	release := make(chan struct{})
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		<-release
		w.Header().Set("Content-Type", "text/html")
		_, _ = w.Write([]byte(`<title>Slow</title>`))
	}))
	defer server.Close()
	service := New(Options{AllowPrivate: true})
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	if _, err := service.Page(ctx, 1, server.URL); err == nil {
		t.Fatal("a cancelled request returned a page")
	}
	close(release)
	page, err := service.Page(context.Background(), 1, server.URL)
	if err != nil {
		t.Fatal(err)
	}
	if page.Title != "Slow" {
		t.Fatalf("cached an empty page: %+v", page)
	}
}

func TestCacheEvictsTheLeastRecentlyUsed(t *testing.T) {
	now := time.Now()
	later := now.Add(time.Hour)
	entries := newCache[int](2)
	entries.put("a", 1, later)
	entries.put("b", 2, later)
	entries.get("a", now)
	entries.put("c", 3, later)
	if _, ok := entries.get("b", now); ok {
		t.Fatal("kept the least recently used entry")
	}
	if _, ok := entries.get("a", now); !ok {
		t.Fatal("evicted a recently used entry")
	}
}
