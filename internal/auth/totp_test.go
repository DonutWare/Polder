package auth

import (
	"encoding/base32"
	"strings"
	"testing"
	"time"
)

func TestTOTPMatchesRFC6238(t *testing.T) {
	secret := base32.StdEncoding.WithPadding(base32.NoPadding).EncodeToString([]byte("12345678901234567890"))
	cases := map[int64]string{59: "287082", 1111111109: "081804", 1234567890: "005924", 2000000000: "279037"}
	for unix, want := range cases {
		got, err := TOTPCode(secret, time.Unix(unix, 0))
		if err != nil || got != want {
			t.Errorf("code at %d = %q, %v; want %q", unix, got, err, want)
		}
	}
}

func TestTOTPURLNamesIssuerAndAccount(t *testing.T) {
	link := totpURL("My Cloud", "alice", "ABC")
	if !strings.HasPrefix(link, "otpauth://totp/My%20Cloud:alice?") || !strings.Contains(link, "issuer=My+Cloud") || !strings.Contains(link, "secret=ABC") {
		t.Fatalf("unexpected link %s", link)
	}
}
