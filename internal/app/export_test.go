package app

import "crypto/x509"

func TrustFederationCertificates(pool *x509.CertPool) {
	federationRootCAs = pool
}
