package netguard

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
		if got := Allowed(address, false); got != c.public {
			t.Errorf("%s public: %v, want %v", c.address, got, c.public)
		}
		if got := Allowed(address, true); got != c.allowPrivate {
			t.Errorf("%s private allowed: %v, want %v", c.address, got, c.allowPrivate)
		}
	}
}
