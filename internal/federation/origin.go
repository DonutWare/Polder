package federation

import (
	"context"
	"errors"
	"net"
	"net/http"
	"net/netip"
	"strings"
)

var (
	errUntrustedServer = errors.New("the request does not come from a trusted server")
	errMustSign        = errors.New("this server signs its requests, but this one is unsigned")
	errWrongAddress    = errors.New("the request does not come from the server's own address")
)

type resolver interface {
	LookupNetIP(ctx context.Context, network, host string) ([]netip.Addr, error)
}

func (s *Service) serverForHost(ctx context.Context, host string) (Server, error) {
	servers, err := s.servers.list(ctx)
	if err != nil {
		return Server{}, err
	}
	for _, server := range servers {
		if sameHost(server.host(), host) {
			return server, nil
		}
	}
	return Server{}, errUntrustedServer
}

func (s *Service) acceptUnsigned(ctx context.Context, server Server, r *http.Request) error {
	if server.SignsRequests {
		return errMustSign
	}
	if server.VerifySenderAddress && !s.comesFrom(ctx, server, clientAddress(r)) {
		return errWrongAddress
	}
	return nil
}

func (s *Service) comesFrom(ctx context.Context, server Server, address string) bool {
	client, err := netip.ParseAddr(address)
	if err != nil {
		return false
	}
	client = client.Unmap()
	hostname := server.host()
	if h, _, err := net.SplitHostPort(hostname); err == nil {
		hostname = h
	}
	hostname = strings.Trim(hostname, "[]")
	if literal, err := netip.ParseAddr(hostname); err == nil {
		return literal.Unmap() == client
	}
	ctx, cancel := withTimeout(ctx)
	defer cancel()
	addresses, err := s.resolver.LookupNetIP(ctx, "ip", hostname)
	if err != nil {
		return false
	}
	for _, candidate := range addresses {
		if candidate.Unmap() == client {
			return true
		}
	}
	return false
}
