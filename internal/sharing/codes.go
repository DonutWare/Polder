package sharing

import (
	"crypto/rand"
	"math/big"
	"regexp"
)

const (
	codeLength   = 10
	codeAlphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
)

var codePattern = regexp.MustCompile(`^[0-9A-Za-z]{6,32}$`)

func newCode() (string, error) {
	limit := big.NewInt(int64(len(codeAlphabet)))
	code := make([]byte, codeLength)
	for i := range code {
		index, err := rand.Int(rand.Reader, limit)
		if err != nil {
			return "", err
		}
		code[i] = codeAlphabet[index.Int64()]
	}
	return string(code), nil
}

func validCode(code string) bool {
	return codePattern.MatchString(code)
}
