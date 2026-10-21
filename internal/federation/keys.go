package federation

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

const signingKeyBits = 2048

type signingKey struct {
	private   *rsa.PrivateKey
	publicPEM string
}

func loadOrCreateSigningKey(path string) (*signingKey, error) {
	content, err := os.ReadFile(path)
	if errors.Is(err, fs.ErrNotExist) {
		content, err = createSigningKey(path)
	}
	if err != nil {
		return nil, fmt.Errorf("federation key: %w", err)
	}
	block, _ := pem.Decode(content)
	if block == nil {
		return nil, errors.New("federation key: not a PEM file")
	}
	parsed, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("federation key: %w", err)
	}
	private, ok := parsed.(*rsa.PrivateKey)
	if !ok {
		return nil, errors.New("federation key: not an RSA key")
	}
	publicDER, err := x509.MarshalPKIXPublicKey(&private.PublicKey)
	if err != nil {
		return nil, err
	}
	publicPEM := pem.EncodeToMemory(&pem.Block{Type: "PUBLIC KEY", Bytes: publicDER})
	return &signingKey{private: private, publicPEM: string(publicPEM)}, nil
}

func createSigningKey(path string) ([]byte, error) {
	private, err := rsa.GenerateKey(rand.Reader, signingKeyBits)
	if err != nil {
		return nil, err
	}
	der, err := x509.MarshalPKCS8PrivateKey(private)
	if err != nil {
		return nil, err
	}
	content := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: der})
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return nil, err
	}
	return content, os.WriteFile(path, content, 0o600)
}

func parsePublicKey(publicPEM string) (*rsa.PublicKey, error) {
	block, _ := pem.Decode([]byte(publicPEM))
	if block == nil {
		return nil, errors.New("public key is not PEM")
	}
	parsed, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	public, ok := parsed.(*rsa.PublicKey)
	if !ok || public.N.BitLen() < 2048 {
		return nil, errors.New("public key must be RSA with at least 2048 bits")
	}
	return public, nil
}
