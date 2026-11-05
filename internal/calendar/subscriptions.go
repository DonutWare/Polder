package calendar

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/url"
	"strings"
	"time"
	"unicode/utf8"

	"github.com/emersion/go-ical"

	"polder-server/internal/apperr"
	"polder-server/internal/netguard"
	"polder-server/internal/users"
)

const (
	fetchTimeout          = 30 * time.Second
	maxFeedBytes          = 20 << 20
	maxFeedRedirects      = 5
	maxSourceURLLength    = 2048
	subscriptionCheckTick = 5 * time.Minute
	feedUserAgent         = "Polder-Calendar/1.0"
)

type NewSubscription struct {
	URL            string `json:"url" minLength:"1" maxLength:"2048" doc:"An http, https or webcal address of an ICS feed"`
	Name           string `json:"name,omitempty" required:"false" maxLength:"128"`
	Color          string `json:"color,omitempty" required:"false"`
	RefreshSeconds int    `json:"refreshSeconds,omitempty" required:"false" doc:"How often to refresh; the server enforces a minimum"`
}

func newFeedClient(allowPrivate bool) *http.Client {
	dialer := &net.Dialer{Timeout: fetchTimeout, Control: netguard.Control(allowPrivate)}
	transport := &http.Transport{
		DialContext:           dialer.DialContext,
		TLSHandshakeTimeout:   fetchTimeout,
		ResponseHeaderTimeout: fetchTimeout,
		MaxIdleConns:          8,
		IdleConnTimeout:       90 * time.Second,
		ForceAttemptHTTP2:     true,
	}
	return &http.Client{Transport: transport, Timeout: 2 * fetchTimeout, CheckRedirect: checkFeedRedirect}
}

func checkFeedRedirect(request *http.Request, via []*http.Request) error {
	if len(via) >= maxFeedRedirects {
		return errors.New("too many redirects")
	}
	_, err := sourceURL(request.URL.String())
	return err
}

func sourceURL(raw string) (string, error) {
	raw = strings.TrimSpace(raw)
	if len(raw) > maxSourceURLLength {
		return "", apperr.Invalid("the address is too long")
	}
	parsed, err := url.Parse(raw)
	if err != nil || parsed.Host == "" || parsed.User != nil {
		return "", apperr.Invalid("%q is not an address of a calendar feed", raw)
	}
	switch strings.ToLower(parsed.Scheme) {
	case "webcal", "webcals":
		parsed.Scheme = "https"
	case "http", "https":
	default:
		return "", apperr.Invalid("a calendar feed is reached over http, https or webcal")
	}
	parsed.Fragment = ""
	return parsed.String(), nil
}

func (s *Service) Subscribe(ctx context.Context, viewer users.User, request NewSubscription) (Calendar, error) {
	source, err := sourceURL(request.URL)
	if err != nil {
		return Calendar{}, err
	}
	name := strings.TrimSpace(request.Name)
	if name == "" {
		name = hostOf(source)
	}
	c := Calendar{
		OwnerID: viewer.ID, Kind: KindSubscription, Name: name, Color: normalizeColor(request.Color), SourceURL: source,
		RefreshSeconds: max(request.RefreshSeconds, int(s.options.SubscriptionMinRefresh/time.Second)),
	}
	if err := validateDetails(c); err != nil {
		return Calendar{}, err
	}
	existing, err := s.store.OwnedCalendars(ctx, viewer.ID)
	if err != nil {
		return Calendar{}, err
	}
	if c.Color == "" {
		c.Color = palette[len(existing)%len(palette)]
	}
	c.Order = len(existing)
	if c.URI, err = chooseURI("", name, existing); err != nil {
		return Calendar{}, err
	}
	id, err := s.store.InsertCalendar(ctx, c)
	if err != nil {
		return Calendar{}, err
	}
	stored, err := s.store.CalendarByID(ctx, id)
	if err != nil {
		return Calendar{}, err
	}
	s.refresh(ctx, stored)
	return s.Get(ctx, viewer, id)
}

func (s *Service) adoptFeedName(ctx context.Context, c Calendar, header ical.Props) {
	if c.Name != hostOf(c.SourceURL) {
		return
	}
	prop := header.Get("X-WR-CALNAME")
	if prop == nil {
		return
	}
	name := strings.TrimSpace(prop.Value)
	if name == "" || name == c.Name || utf8.RuneCountInString(name) > maxNameLength {
		return
	}
	c.Name = name
	if err := s.store.UpdateCalendar(ctx, c); err != nil {
		logger.Warn("name a calendar subscription after its feed", "calendar", c.ID, "error", err)
	}
}

func hostOf(raw string) string {
	if parsed, err := url.Parse(raw); err == nil && parsed.Hostname() != "" {
		return parsed.Hostname()
	}
	return "Subscription"
}

func (s *Service) Refresh(ctx context.Context, viewer users.User, calendarID int64) (Calendar, error) {
	c, err := s.ownedCalendar(ctx, viewer, calendarID)
	if err != nil {
		return Calendar{}, err
	}
	if c.Kind != KindSubscription {
		return Calendar{}, apperr.Invalid("only subscriptions can be refreshed")
	}
	stored, err := s.store.CalendarByID(ctx, calendarID)
	if err != nil {
		return Calendar{}, err
	}
	s.refresh(ctx, stored)
	return s.Get(ctx, viewer, calendarID)
}

func (s *Service) RequestRefresh() {
	select {
	case s.refreshRequests <- struct{}{}:
	default:
	}
}

func (s *Service) RefreshRequests() <-chan struct{} {
	return s.refreshRequests
}

func (s *Service) RefreshDueSubscriptions(ctx context.Context) error {
	due, err := s.store.DueSubscriptions(ctx, s.now())
	if err != nil {
		return err
	}
	for _, c := range due {
		if ctx.Err() != nil {
			return ctx.Err()
		}
		s.refresh(ctx, c)
	}
	return nil
}

func (s *Service) refresh(ctx context.Context, c Calendar) {
	etag, lastModified, err := s.fetchSubscription(ctx, c)
	message := ""
	if err != nil {
		message = err.Error()
		etag, lastModified = c.FetchETag, c.FetchLastModified
		logger.Info("refresh a calendar subscription", "calendar", c.ID, "source", c.SourceURL, "error", err)
	}
	if err := s.store.RecordFetch(ctx, c.ID, etag, lastModified, message); err != nil {
		logger.Warn("record a calendar subscription refresh", "calendar", c.ID, "error", err)
	}
}

func (s *Service) fetchSubscription(ctx context.Context, c Calendar) (string, string, error) {
	ctx, cancel := context.WithTimeout(ctx, 2*fetchTimeout)
	defer cancel()
	request, err := http.NewRequestWithContext(ctx, http.MethodGet, c.SourceURL, nil)
	if err != nil {
		return "", "", err
	}
	request.Header.Set("User-Agent", feedUserAgent)
	request.Header.Set("Accept", "text/calendar, */*;q=0.5")
	if c.FetchETag != "" {
		request.Header.Set("If-None-Match", c.FetchETag)
	}
	if c.FetchLastModified != "" {
		request.Header.Set("If-Modified-Since", c.FetchLastModified)
	}
	response, err := s.fetcher.Do(request)
	if err != nil {
		return "", "", err
	}
	defer response.Body.Close()
	if response.StatusCode == http.StatusNotModified {
		return c.FetchETag, c.FetchLastModified, nil
	}
	if response.StatusCode != http.StatusOK {
		return "", "", fmt.Errorf("the feed answered %s", response.Status)
	}
	body, err := io.ReadAll(io.LimitReader(response.Body, maxFeedBytes+1))
	if err != nil {
		return "", "", err
	}
	if len(body) > maxFeedBytes {
		return "", "", fmt.Errorf("the feed is larger than %d bytes", maxFeedBytes)
	}
	if err := s.syncSubscription(ctx, c, body); err != nil {
		return "", "", err
	}
	return response.Header.Get("ETag"), response.Header.Get("Last-Modified"), nil
}

func (s *Service) syncSubscription(ctx context.Context, c Calendar, body []byte) error {
	if closed, truncated := closeTruncated(body); truncated {
		logger.Warn("a calendar feed ended early; keeping its complete events", "calendar", c.ID)
		body = closed
	}
	split, err := splitByUID(body)
	if err != nil {
		return err
	}
	s.adoptFeedName(ctx, c, split.header)
	tidyFeed(c.SourceURL, split)
	existing, err := s.store.ObjectMetas(ctx, c.ID)
	if err != nil {
		return err
	}
	byUID := map[string]Object{}
	for _, object := range existing {
		byUID[object.UID] = object
	}
	kept := map[string]bool{}
	for _, uid := range split.order {
		if uid == "" || len(kept) >= s.options.MaxObjectsPerCalendar {
			continue
		}
		kept[uid] = true
		if err := s.syncSubscribedEvent(ctx, c, split, uid, byUID[uid]); err != nil {
			logger.Debug("skip an event in a calendar feed", "calendar", c.ID, "uid", uid, "error", err)
			delete(kept, uid)
		}
	}
	for uid, object := range byUID {
		if !kept[uid] {
			if err := s.store.DeleteObject(ctx, c.ID, object.URI); err != nil {
				return err
			}
		}
	}
	s.publishCalendar(ctx, c)
	return nil
}

func (s *Service) syncSubscribedEvent(ctx context.Context, c Calendar, split splitCalendar, uid string, existing Object) error {
	resource, err := split.resource(uid, c.Location())
	if err != nil {
		return err
	}
	data, err := resource.Bytes()
	if err != nil {
		return err
	}
	if existing.ID != 0 && etagOf(data) == existing.ETag {
		return nil
	}
	uri := existing.URI
	if uri == "" {
		uri = ObjectURIForUID(uid)
	}
	_, err = s.save(ctx, c, uri, resource, "")
	return err
}

func SubscriptionCheckInterval() time.Duration {
	return subscriptionCheckTick
}
