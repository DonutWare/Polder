package auth

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"fmt"
	"strings"

	"golang.org/x/crypto/argon2"
)

const (
	argonKeyLen = 32
	saltLength  = 16
)

type Argon2Cost struct {
	Time      uint32
	MemoryKiB uint32
	Threads   uint8
}

var HashCost = Argon2Cost{Time: 2, MemoryKiB: 64 * 1024, Threads: 2}

type Argon2Hasher struct{}

func (Argon2Hasher) Hash(password string) (string, error) {
	salt := make([]byte, saltLength)
	if _, err := rand.Read(salt); err != nil {
		return "", err
	}
	cost := HashCost
	key := argon2.IDKey([]byte(password), salt, cost.Time, cost.MemoryKiB, cost.Threads, argonKeyLen)
	encoding := base64.RawStdEncoding
	return fmt.Sprintf("$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version, cost.MemoryKiB, cost.Time, cost.Threads, encoding.EncodeToString(salt), encoding.EncodeToString(key)), nil
}

func (Argon2Hasher) Verify(password, encodedHash string) bool {
	parts := strings.Split(encodedHash, "$")
	if len(parts) != 6 || parts[1] != "argon2id" {
		return false
	}
	var memory uint32
	var iterations uint32
	var threads uint8
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &memory, &iterations, &threads); err != nil {
		return false
	}
	salt, saltErr := base64.RawStdEncoding.DecodeString(parts[4])
	expected, keyErr := base64.RawStdEncoding.DecodeString(parts[5])
	if saltErr != nil || keyErr != nil {
		return false
	}
	actual := argon2.IDKey([]byte(password), salt, iterations, memory, threads, uint32(len(expected)))
	return subtle.ConstantTimeCompare(actual, expected) == 1
}
