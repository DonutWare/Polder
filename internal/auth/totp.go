package auth

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"encoding/base32"
	"encoding/binary"
	"fmt"
	"net/url"
	"strings"
	"time"
)

const (
	totpPeriod      = 30
	totpDigits      = 6
	totpSkewSteps   = 1
	totpSecretBytes = 20
)

var totpEncoding = base32.StdEncoding.WithPadding(base32.NoPadding)

func newTOTPSecret() string {
	secret := make([]byte, totpSecretBytes)
	_, _ = rand.Read(secret)
	return totpEncoding.EncodeToString(secret)
}

func totpStep(at time.Time) int64 {
	return at.Unix() / totpPeriod
}

func TOTPCode(secret string, at time.Time) (string, error) {
	return totpCodeAt(secret, totpStep(at))
}

func totpCodeAt(secret string, step int64) (string, error) {
	key, err := totpEncoding.DecodeString(strings.ToUpper(strings.TrimSpace(secret)))
	if err != nil {
		return "", err
	}
	counter := make([]byte, 8)
	binary.BigEndian.PutUint64(counter, uint64(step))
	mac := hmac.New(sha1.New, key)
	mac.Write(counter)
	sum := mac.Sum(nil)
	offset := sum[len(sum)-1] & 0x0f
	truncated := binary.BigEndian.Uint32(sum[offset:offset+4]) & 0x7fffffff
	return fmt.Sprintf("%0*d", totpDigits, truncated%1_000_000), nil
}

func totpURL(issuer, account, secret string) string {
	label := url.PathEscape(issuer + ":" + account)
	query := url.Values{
		"secret":    {secret},
		"issuer":    {issuer},
		"algorithm": {"SHA1"},
		"digits":    {fmt.Sprint(totpDigits)},
		"period":    {fmt.Sprint(totpPeriod)},
	}
	return "otpauth://totp/" + label + "?" + query.Encode()
}

func normalizeTOTPCode(code string) string {
	return strings.Map(func(r rune) rune {
		if r >= '0' && r <= '9' {
			return r
		}
		return -1
	}, code)
}
