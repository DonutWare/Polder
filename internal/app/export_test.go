package app

import (
	"crypto/x509"

	"polder-server/internal/emails"
)

func TrustFederationCertificates(pool *x509.CertPool) {
	federationRootCAs = pool
}

func UseMailer(mailer emails.Mailer) func() {
	mailerOverride = mailer
	return func() { mailerOverride = nil }
}
