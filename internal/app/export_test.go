package app

import (
	"context"
	"crypto/x509"
	"time"

	"polder-server/internal/emails"
)

func TrustFederationCertificates(pool *x509.CertPool) {
	federationRootCAs = pool
}

func UseMailer(mailer emails.Mailer) func() {
	mailerOverride = mailer
	return func() { mailerOverride = nil }
}

func (a *App) AgeSignIns(ctx context.Context, by time.Duration) error {
	_, err := a.db.ExecContext(ctx, `UPDATE sessions SET authenticated_at = authenticated_at - $1`, int64(by.Seconds()))
	return err
}
