package httpapi

import (
	"net/http"
	"net/http/httptest"
	"net/netip"
	"strings"
	"testing"
)

func TestForwardedClient(t *testing.T) {
	trusted := []netip.Prefix{netip.MustParsePrefix("10.0.0.0/8"), netip.MustParsePrefix("::1/128")}
	cases := []struct {
		name      string
		peer      string
		forwarded []string
		realIP    string
		want      string
	}{
		{name: "untrusted peer keeps its address", peer: "203.0.113.9:4000", forwarded: []string{"198.51.100.1"}, want: "203.0.113.9:4000"},
		{name: "trusted peer names the client", peer: "10.0.0.2:4000", forwarded: []string{"198.51.100.1"}, want: "198.51.100.1"},
		{name: "forged entries left of the client are ignored", peer: "10.0.0.2:4000", forwarded: []string{"192.0.2.66, 198.51.100.1"}, want: "198.51.100.1"},
		{name: "proxy chains are skipped", peer: "10.0.0.2:4000", forwarded: []string{"198.51.100.1, 10.0.0.7", "10.0.0.3"}, want: "198.51.100.1"},
		{name: "ipv6 peer and port in the header", peer: "[::1]:4000", forwarded: []string{"[2001:db8::5]:1234"}, want: "2001:db8::5"},
		{name: "x-real-ip without x-forwarded-for", peer: "10.0.0.2:4000", realIP: "198.51.100.1", want: "198.51.100.1"},
		{name: "unreadable header is not trusted", peer: "10.0.0.2:4000", forwarded: []string{"not-an-address"}, want: "10.0.0.2:4000"},
		{name: "no header keeps the proxy", peer: "10.0.0.2:4000", want: "10.0.0.2:4000"},
	}
	for _, c := range cases {
		t.Run(c.name, func(t *testing.T) {
			var seen string
			handler := forwardedClient(trusted)(http.HandlerFunc(func(_ http.ResponseWriter, r *http.Request) { seen = r.RemoteAddr }))
			request := httptest.NewRequest(http.MethodGet, "/", nil)
			request.RemoteAddr = c.peer
			for _, value := range c.forwarded {
				request.Header.Add("X-Forwarded-For", value)
			}
			if c.realIP != "" {
				request.Header.Set("X-Real-IP", c.realIP)
			}
			handler.ServeHTTP(httptest.NewRecorder(), request)
			if seen != c.want {
				t.Fatalf("remote address = %q, want %q", seen, c.want)
			}
		})
	}
}

func TestCompressJSON(t *testing.T) {
	handler := compressJSON(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"items":[` + strings.Repeat(`{"name":"x"},`, 200) + `{}]}`))
	}))
	cases := []struct {
		path    string
		headers map[string]string
		want    string
	}{
		{path: "/api/v1/calendars/events", want: "gzip"},
		{path: "/api/v1/files/list", want: "gzip"},
		{path: "/api/v1/files/content", want: ""},
		{path: "/api/v1/shares/3/archive", want: ""},
		{path: "/api/v1/events", want: ""},
		{path: "/api/v1/files/list", headers: map[string]string{"Range": "bytes=0-9"}, want: ""},
		{path: "/index.html", want: ""},
	}
	for _, c := range cases {
		t.Run(c.path, func(t *testing.T) {
			request := httptest.NewRequest(http.MethodGet, c.path, nil)
			request.Header.Set("Accept-Encoding", "gzip")
			for name, value := range c.headers {
				request.Header.Set(name, value)
			}
			recorder := httptest.NewRecorder()
			handler.ServeHTTP(recorder, request)
			if got := recorder.Header().Get("Content-Encoding"); got != c.want {
				t.Fatalf("Content-Encoding = %q, want %q", got, c.want)
			}
		})
	}
}
