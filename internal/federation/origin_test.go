package federation

import (
	"context"
	"errors"
	"net/http/httptest"
	"net/netip"
	"testing"
)

type fixedResolver map[string][]netip.Addr

func (f fixedResolver) LookupNetIP(_ context.Context, _, host string) ([]netip.Addr, error) {
	if addresses, ok := f[host]; ok {
		return addresses, nil
	}
	return nil, errors.New("no such host")
}

func TestUnsignedRequestsMustComeFromTheServer(t *testing.T) {
	service := &Service{resolver: fixedResolver{"cloud.example.com": {netip.MustParseAddr("203.0.113.10"), netip.MustParseAddr("2001:db8::10")}}}
	keyless := Server{Remote: "cloud.example.com", VerifySenderAddress: true}
	request := func(remoteAddr string) error {
		r := httptest.NewRequest("POST", "/ocm/shares", nil)
		r.RemoteAddr = remoteAddr
		return service.acceptUnsigned(context.Background(), keyless, r)
	}
	if err := request("203.0.113.10:5555"); err != nil {
		t.Fatalf("own address: %v", err)
	}
	if err := request("[2001:db8::10]:5555"); err != nil {
		t.Fatalf("own IPv6 address: %v", err)
	}
	if err := request("198.51.100.7:5555"); !errors.Is(err, errWrongAddress) {
		t.Fatalf("other address: %v", err)
	}
	keyless.VerifySenderAddress = false
	if err := request("198.51.100.7:5555"); err != nil {
		t.Fatalf("check turned off: %v", err)
	}
	signing := Server{Remote: "cloud.example.com", SignsRequests: true}
	r := httptest.NewRequest("POST", "/ocm/shares", nil)
	r.RemoteAddr = "203.0.113.10:5555"
	if err := service.acceptUnsigned(context.Background(), signing, r); !errors.Is(err, errMustSign) {
		t.Fatalf("a server that signs must always sign: %v", err)
	}
}
