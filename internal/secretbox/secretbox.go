package secretbox

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"errors"
)

var ErrUnreadable = errors.New("stored secret cannot be opened")

type Box struct {
	aead cipher.AEAD
}

func New(key []byte) (*Box, error) {
	if len(key) < 32 {
		return nil, errors.New("secret box key must be at least 32 bytes")
	}
	block, err := aes.NewCipher(key[:32])
	if err != nil {
		return nil, err
	}
	aead, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}
	return &Box{aead: aead}, nil
}

func (b *Box) Seal(plaintext, context string) string {
	nonce := make([]byte, b.aead.NonceSize())
	_, _ = rand.Read(nonce)
	sealed := b.aead.Seal(nonce, nonce, []byte(plaintext), []byte(context))
	return base64.RawStdEncoding.EncodeToString(sealed)
}

func (b *Box) Open(sealed, context string) (string, error) {
	raw, err := base64.RawStdEncoding.DecodeString(sealed)
	if err != nil || len(raw) < b.aead.NonceSize() {
		return "", ErrUnreadable
	}
	nonce, ciphertext := raw[:b.aead.NonceSize()], raw[b.aead.NonceSize():]
	plaintext, err := b.aead.Open(nil, nonce, ciphertext, []byte(context))
	if err != nil {
		return "", ErrUnreadable
	}
	return string(plaintext), nil
}
