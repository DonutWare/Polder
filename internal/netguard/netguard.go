package netguard

import (
	"errors"
	"net"
	"net/netip"
	"syscall"
)

var ErrForbiddenAddress = errors.New("the server resolves to an address Polder may not reach")

var alwaysForbidden = []netip.Prefix{
	netip.MustParsePrefix("0.0.0.0/8"),
	netip.MustParsePrefix("169.254.0.0/16"),
	netip.MustParsePrefix("192.0.0.0/24"),
	netip.MustParsePrefix("192.0.2.0/24"),
	netip.MustParsePrefix("198.18.0.0/15"),
	netip.MustParsePrefix("198.51.100.0/24"),
	netip.MustParsePrefix("203.0.113.0/24"),
	netip.MustParsePrefix("224.0.0.0/4"),
	netip.MustParsePrefix("240.0.0.0/4"),
	netip.MustParsePrefix("100::/64"),
	netip.MustParsePrefix("2001:db8::/32"),
	netip.MustParsePrefix("fe80::/10"),
	netip.MustParsePrefix("ff00::/8"),
}

var privateUnlessAllowed = []netip.Prefix{
	netip.MustParsePrefix("10.0.0.0/8"),
	netip.MustParsePrefix("100.64.0.0/10"),
	netip.MustParsePrefix("127.0.0.0/8"),
	netip.MustParsePrefix("172.16.0.0/12"),
	netip.MustParsePrefix("192.168.0.0/16"),
	netip.MustParsePrefix("::1/128"),
	netip.MustParsePrefix("fc00::/7"),
}

func Allowed(address netip.Addr, allowPrivate bool) bool {
	address = address.Unmap()
	if !address.IsValid() || address.IsUnspecified() {
		return false
	}
	for _, prefix := range alwaysForbidden {
		if prefix.Contains(address) {
			return false
		}
	}
	if allowPrivate {
		return true
	}
	for _, prefix := range privateUnlessAllowed {
		if prefix.Contains(address) {
			return false
		}
	}
	return true
}

func Control(allowPrivate bool) func(network, address string, conn syscall.RawConn) error {
	return func(_, address string, _ syscall.RawConn) error {
		host, _, err := net.SplitHostPort(address)
		if err != nil {
			return err
		}
		ip, err := netip.ParseAddr(host)
		if err != nil || !Allowed(ip, allowPrivate) {
			return ErrForbiddenAddress
		}
		return nil
	}
}
