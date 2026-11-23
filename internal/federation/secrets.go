package federation

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
)

const (
	SecretKeyPurpose = "federation-secrets"
	shareSecretBytes = 32
)

func newShareSecret() string {
	secret := make([]byte, shareSecretBytes)
	_, _ = rand.Read(secret)
	return base64.RawURLEncoding.EncodeToString(secret)
}

func hashSecret(secret string) string {
	sum := sha256.Sum256([]byte(secret))
	return hex.EncodeToString(sum[:])
}
