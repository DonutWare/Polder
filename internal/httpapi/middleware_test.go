package httpapi

import (
	"net/http"
	"net/http/httptest"
	"net/netip"
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
