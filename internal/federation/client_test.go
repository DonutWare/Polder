package federation

import (
	"net/netip"
	"testing"
)

func TestAddressAllowed(t *testing.T) {
	cases := []struct {
		address      string
		public       bool
		allowPrivate bool
	}{
		{"93.184.216.34", true, true},
		{"2606:2800:220:1::1", true, true},
		{"10.1.2.3", false, true},
		{"192.168.1.10", false, true},
		{"127.0.0.1", false, true},
		{"::1", false, true},
		{"fd00::1", false, true},
		{"100.64.0.1", false, true},
		{"169.254.169.254", false, false},
		{"fe80::1", false, false},
		{"0.0.0.0", false, false},
		{"::", false, false},
		{"224.0.0.1", false, false},
		{"::ffff:169.254.169.254", false, false},
		{"::ffff:10.0.0.1", false, true},
	}
	for _, c := range cases {
		address := netip.MustParseAddr(c.address)
		if got := addressAllowed(address, false); got != c.public {
			t.Errorf("%s public: %v, want %v", c.address, got, c.public)
		}
		if got := addressAllowed(address, true); got != c.allowPrivate {
			t.Errorf("%s private allowed: %v, want %v", c.address, got, c.allowPrivate)
		}
	}
}

func TestParseCloudID(t *testing.T) {
	valid := map[string]CloudID{
		"alice@cloud.example.com":                   {User: "alice", Remote: "cloud.example.com"},
		"alice@example.com@cloud.example.com":       {User: "alice@example.com", Remote: "cloud.example.com"},
		"Bob Smith@Cloud.Example.com:8443/nc/":      {User: "Bob Smith", Remote: "cloud.example.com:8443/nc"},
		"carol@https://cloud.example.com/index.php": {User: "carol", Remote: "cloud.example.com"},
	}
	for raw, want := range valid {
		got, err := ParseCloudID(raw)
		if err != nil || got != want {
			t.Errorf("%q: %+v %v, want %+v", raw, got, err, want)
		}
	}
	for _, raw := range []string{"", "alice", "@host", "alice@", "alice@http://cloud.example.com", "a<b@host", "alice@host/../x",
		"alice@host?x=1", "alice@ho st"} {
		if got, err := ParseCloudID(raw); err == nil {
			t.Errorf("%q should be rejected, got %+v", raw, got)
		}
	}
}

func TestSecretBox(t *testing.T) {
	box, err := newSecretBox(make([]byte, 32))
	if err != nil {
		t.Fatal(err)
	}
	sealed := box.seal("secret", "share:1")
	if opened, err := box.open(sealed, "share:1"); err != nil || opened != "secret" {
		t.Fatalf("open: %q %v", opened, err)
	}
	if _, err := box.open(sealed, "share:2"); err == nil {
		t.Fatal("a secret sealed for another row must not open")
	}
}
