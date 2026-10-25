package linkpreview

import (
	"container/list"
	"context"
	"errors"
	"fmt"
	"io"
	"mime"
	"net"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"

	"golang.org/x/net/html/charset"
	"golang.org/x/sync/singleflight"

	"polder-server/internal/apperr"
	"polder-server/internal/netguard"
)

const (
	fetchTimeout        = 10 * time.Second
	maxRedirects        = 5
	maxPageBytes        = 1 << 20
	maxImageBytes       = 4 << 20
	maxURLLength        = 2048
	pageTTL             = 6 * time.Hour
	failedPageTTL       = 30 * time.Minute
	imageTTL            = 6 * time.Hour
	maxCachedPages      = 2000
	maxCachedImages     = 128
	failedImageTTL      = 30 * time.Minute
	maxCachedImageBytes = 512 << 10
	maxConcurrent       = 8
	maxPerOwner         = 2
	slotWait            = fetchTimeout
	userAgent           = "Mozilla/5.0 (compatible; PolderLinkPreview/1.0)"
)

var (
	errTooLarge = errors.New("the linked resource is too large")
	errBusy     = errors.New("every link preview slot is busy")
)

var allowedImageTypes = map[string]bool{
	"image/png":                true,
	"image/jpeg":               true,
	"image/gif":                true,
	"image/webp":               true,
	"image/bmp":                true,
	"image/x-icon":             true,
	"image/vnd.microsoft.icon": true,
}

type Page struct {
	URL         string
	Title       string
	Description string
	SiteName    string
	Image       string
	Icon        string
}

type Kind string

const (
	KindImage Kind = "image"
	KindIcon  Kind = "icon"
)

type Asset struct {
	ContentType string
	Body        []byte
}

type Options struct {
	AllowPrivate bool
}

type Service struct {
	client  *http.Client
	slots   chan struct{}
	owners  *ownerSlots
	flights singleflight.Group
	now     func() time.Time
	pages   *cache[Page]
	images  *cache[Asset]
}

func New(options Options) *Service {
	dialer := &net.Dialer{Timeout: fetchTimeout, Control: netguard.Control(options.AllowPrivate)}
	transport := &http.Transport{
		DialContext:           dialer.DialContext,
		TLSHandshakeTimeout:   fetchTimeout,
		ResponseHeaderTimeout: fetchTimeout,
		MaxIdleConns:          16,
		IdleConnTimeout:       90 * time.Second,
		ForceAttemptHTTP2:     true,
	}
	return &Service{
		client: &http.Client{Transport: transport, CheckRedirect: checkRedirect},
		slots:  make(chan struct{}, maxConcurrent),
		owners: newOwnerSlots(maxPerOwner),
		now:    time.Now,
		pages:  newCache[Page](maxCachedPages),
		images: newCache[Asset](maxCachedImages),
	}
}

func checkRedirect(request *http.Request, via []*http.Request) error {
	if len(via) >= maxRedirects {
		return errors.New("too many redirects")
	}
	if _, err := validURL(request.URL.String()); err != nil {
		return err
	}
	return nil
}

func validURL(raw string) (*url.URL, error) {
	if len(raw) > maxURLLength {
		return nil, apperr.Invalid("the link is too long")
	}
	parsed, err := url.Parse(strings.TrimSpace(raw))
	if err != nil || (parsed.Scheme != "http" && parsed.Scheme != "https") || parsed.Hostname() == "" || parsed.User != nil {
		return nil, apperr.Invalid("only http and https links can be previewed")
	}
	parsed.Fragment = ""
	parsed.RawFragment = ""
	return parsed, nil
}

func (s *Service) Page(ctx context.Context, owner int64, raw string) (Page, error) {
	target, err := validURL(raw)
	if err != nil {
		return Page{}, err
	}
	release, err := s.owners.acquire(ctx, owner)
	if err != nil {
		return Page{}, err
	}
	defer release()
	return s.page(ctx, target)
}

func (s *Service) Image(ctx context.Context, owner int64, raw string, kind Kind) (Asset, error) {
	target, err := validURL(raw)
	if err != nil {
		return Asset{}, err
	}
	release, err := s.owners.acquire(ctx, owner)
	if err != nil {
		return Asset{}, err
	}
	defer release()
	page, err := s.page(ctx, target)
	if err != nil {
		return Asset{}, err
	}
	source := page.Image
	if kind == KindIcon {
		source = page.Icon
	}
	if source == "" {
		return Asset{}, apperr.NotFound("the link has no %s", kind)
	}
	asset, err := s.image(ctx, source)
	if err != nil {
		return Asset{}, err
	}
	if len(asset.Body) == 0 {
		return Asset{}, apperr.NotFound("the link's %s could not be loaded", kind)
	}
	return asset, nil
}

func (s *Service) page(ctx context.Context, target *url.URL) (Page, error) {
	key := target.String()
	if page, ok := s.pages.get(key, s.now()); ok {
		return page, nil
	}
	return share[Page](ctx, &s.flights, "page|"+key, func() (Page, error) {
		page, err := s.fetchPage(context.Background(), target)
		if errors.Is(err, errBusy) {
			return Page{}, apperr.Unavailable("too many link previews are loading, try again shortly")
		}
		ttl := pageTTL
		if err != nil {
			page = Page{URL: key, SiteName: siteName(target), Icon: resolve(target, "/favicon.ico")}
			ttl = failedPageTTL
		}
		s.pages.put(key, page, s.now().Add(ttl))
		return page, nil
	})
}

func (s *Service) image(ctx context.Context, source string) (Asset, error) {
	if asset, ok := s.images.get(source, s.now()); ok {
		return asset, nil
	}
	return share[Asset](ctx, &s.flights, "image|"+source, func() (Asset, error) {
		target, err := validURL(source)
		if err != nil {
			s.images.put(source, Asset{}, s.now().Add(failedImageTTL))
			return Asset{}, nil
		}
		asset, err := s.fetchImage(context.Background(), target)
		if errors.Is(err, errBusy) {
			return Asset{}, apperr.Unavailable("too many link previews are loading, try again shortly")
		}
		if err != nil {
			s.images.put(source, Asset{}, s.now().Add(failedImageTTL))
			return Asset{}, nil
		}
		if len(asset.Body) <= maxCachedImageBytes {
			s.images.put(source, asset, s.now().Add(imageTTL))
		}
		return asset, nil
	})
}

func share[T any](ctx context.Context, flights *singleflight.Group, key string, load func() (T, error)) (T, error) {
	result := flights.DoChan(key, func() (any, error) { return load() })
	select {
	case outcome := <-result:
		if outcome.Err != nil {
			var zero T
			return zero, outcome.Err
		}
		return outcome.Val.(T), nil
	case <-ctx.Done():
		var zero T
		return zero, ctx.Err()
	}
}

func (s *Service) fetchPage(ctx context.Context, target *url.URL) (Page, error) {
	response, release, err := s.get(ctx, target, "text/html,application/xhtml+xml;q=0.9,*/*;q=0.5")
	if err != nil {
		return Page{}, err
	}
	defer release()
	final := response.Request.URL
	mediaType := mediaTypeOf(response)
	if allowedImageTypes[mediaType] {
		return Page{URL: target.String(), SiteName: siteName(final), Image: final.String(), Icon: resolve(final, "/favicon.ico")}, nil
	}
	if mediaType != "text/html" && mediaType != "application/xhtml+xml" {
		return Page{URL: target.String(), SiteName: siteName(final), Icon: resolve(final, "/favicon.ico")}, nil
	}
	body, err := charset.NewReader(io.LimitReader(response.Body, maxPageBytes), response.Header.Get("Content-Type"))
	if err != nil {
		return Page{}, err
	}
	page := pageFrom(readHead(body), final)
	page.URL = target.String()
	return page, nil
}

func (s *Service) fetchImage(ctx context.Context, target *url.URL) (Asset, error) {
	response, release, err := s.get(ctx, target, "image/*")
	if err != nil {
		return Asset{}, err
	}
	defer release()
	body, err := io.ReadAll(io.LimitReader(response.Body, maxImageBytes+1))
	if err != nil {
		return Asset{}, err
	}
	if len(body) > maxImageBytes {
		return Asset{}, errTooLarge
	}
	contentType := mediaTypeOf(response)
	if !allowedImageTypes[contentType] {
		contentType = http.DetectContentType(body)
	}
	if !allowedImageTypes[contentType] {
		return Asset{}, fmt.Errorf("unsupported image type %q", contentType)
	}
	return Asset{ContentType: contentType, Body: body}, nil
}

func (s *Service) get(ctx context.Context, target *url.URL, accept string) (*http.Response, func(), error) {
	wait := time.NewTimer(slotWait)
	defer wait.Stop()
	select {
	case s.slots <- struct{}{}:
	case <-wait.C:
		return nil, nil, errBusy
	}
	ctx, cancel := context.WithTimeout(ctx, fetchTimeout)
	release := func() {
		cancel()
		<-s.slots
	}
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, target.String(), nil)
	if err != nil {
		release()
		return nil, nil, err
	}
	request.Header.Set("User-Agent", userAgent)
	request.Header.Set("Accept", accept)
	response, err := s.client.Do(request)
	if err != nil {
		release()
		return nil, nil, err
	}
	if response.StatusCode < 200 || response.StatusCode > 299 {
		response.Body.Close()
		release()
		return nil, nil, fmt.Errorf("the link answered %s", response.Status)
	}
	return response, func() {
		response.Body.Close()
		release()
	}, nil
}

func mediaTypeOf(response *http.Response) string {
	mediaType, _, err := mime.ParseMediaType(response.Header.Get("Content-Type"))
	if err != nil {
		return ""
	}
	return strings.ToLower(mediaType)
}

type cached[T any] struct {
	key     string
	value   T
	expires time.Time
}

type cache[T any] struct {
	mu      sync.Mutex
	limit   int
	entries map[string]*list.Element
	recency *list.List
}

func newCache[T any](limit int) *cache[T] {
	return &cache[T]{limit: limit, entries: map[string]*list.Element{}, recency: list.New()}
}

func (c *cache[T]) get(key string, now time.Time) (T, bool) {
	c.mu.Lock()
	defer c.mu.Unlock()
	var zero T
	element, ok := c.entries[key]
	if !ok {
		return zero, false
	}
	entry := element.Value.(cached[T])
	if now.After(entry.expires) {
		c.recency.Remove(element)
		delete(c.entries, key)
		return zero, false
	}
	c.recency.MoveToFront(element)
	return entry.value, true
}

func (c *cache[T]) put(key string, value T, expires time.Time) {
	c.mu.Lock()
	defer c.mu.Unlock()
	entry := cached[T]{key: key, value: value, expires: expires}
	if element, ok := c.entries[key]; ok {
		element.Value = entry
		c.recency.MoveToFront(element)
		return
	}
	c.entries[key] = c.recency.PushFront(entry)
	for c.recency.Len() > c.limit {
		oldest := c.recency.Back()
		c.recency.Remove(oldest)
		delete(c.entries, oldest.Value.(cached[T]).key)
	}
}

type ownerSlots struct {
	mu     sync.Mutex
	limit  int
	owners map[int64]*ownerSlot
}

type ownerSlot struct {
	slots   chan struct{}
	holders int
}

func newOwnerSlots(limit int) *ownerSlots {
	return &ownerSlots{limit: limit, owners: map[int64]*ownerSlot{}}
}

func (o *ownerSlots) acquire(ctx context.Context, owner int64) (func(), error) {
	o.mu.Lock()
	slot, ok := o.owners[owner]
	if !ok {
		slot = &ownerSlot{slots: make(chan struct{}, o.limit)}
		o.owners[owner] = slot
	}
	slot.holders++
	o.mu.Unlock()
	select {
	case slot.slots <- struct{}{}:
		return func() {
			<-slot.slots
			o.leave(owner, slot)
		}, nil
	case <-ctx.Done():
		o.leave(owner, slot)
		return nil, ctx.Err()
	}
}

func (o *ownerSlots) leave(owner int64, slot *ownerSlot) {
	o.mu.Lock()
	defer o.mu.Unlock()
	slot.holders--
	if slot.holders == 0 {
		delete(o.owners, owner)
	}
}
