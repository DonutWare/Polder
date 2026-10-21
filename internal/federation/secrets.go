package federation

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
)

const (
	SecretKeyPurpose = "federation-secrets"
	shareSecretBytes = 32
)

var errSealedSecret = errors.New("stored federation secret cannot be opened")

type secretBox struct {
	aead cipher.AEAD
}

func newSecretBox(key []byte) (*secretBox, error) {
	block, err := aes.NewCipher(key[:32])
	if err != nil {
		return nil, err
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	return &secretBox{aead: aead}, nil
}

func (b *secretBox) seal(plaintext, context string) string {
	nonce := make([]byte, b.aead.NonceSize())
	_, _ = rand.Read(nonce)
	sealed := b.aead.Seal(nonce, nonce, []byte(plaintext), []byte(context))
	return base64.RawStdEncoding.EncodeToString(sealed)
}

func (b *secretBox) open(sealed, context string) (string, error) {
	raw, err := base64.RawStdEncoding.DecodeString(sealed)
	if err != nil || len(raw) < b.aead.NonceSize() {
		return "", errSealedSecret
	}
	nonce, ciphertext := raw[:b.aead.NonceSize()], raw[b.aead.NonceSize():]
	plaintext, err := b.aead.Open(nil, nonce, ciphertext, []byte(context))
	if err != nil {
		return "", errSealedSecret
	}
	return string(plaintext), nil
}

func newShareSecret() string {
	secret := make([]byte, shareSecretBytes)
	_, _ = rand.Read(secret)
	return base64.RawURLEncoding.EncodeToString(secret)
}

func hashSecret(secret string) string {
	sum := sha256.Sum256([]byte(secret))
	return hex.EncodeToString(sum[:])
}
