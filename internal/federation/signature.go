package federation

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"crypto/sha512"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"hash"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
)

const (
	signatureMaxAge     = 5 * time.Minute
	signedHeaders       = "(request-target) content-length date digest host"
	signatureAlgorithm  = "rsa-sha512"
	requestTargetHeader = "(request-target)"
)

var (
	errUnsigned         = errors.New("the request is not signed")
	errInvalidSignature = errors.New("invalid signature")
)

type signer struct {
	key   *signingKey
	keyID string
	now   func() time.Time
}

func (s signer) sign(request *http.Request, body []byte) error {
	digest := sha512.Sum512(body)
	request.ContentLength = int64(len(body))
	request.Header.Set("Content-Length", strconv.Itoa(len(body)))
	request.Header.Set("Date", s.now().UTC().Format(http.TimeFormat))
	request.Header.Set("Digest", "SHA-512="+base64.StdEncoding.EncodeToString(digest[:]))
	lines := []string{
		requestTargetHeader + ": " + strings.ToLower(request.Method) + " " + request.URL.RequestURI(),
		"content-length: " + request.Header.Get("Content-Length"),
		"date: " + request.Header.Get("Date"),
		"digest: " + request.Header.Get("Digest"),
		"host: " + request.URL.Host,
	}
	hashed := sha512.Sum512([]byte(strings.Join(lines, "\n")))
	signature, err := rsa.SignPKCS1v15(rand.Reader, s.key.private, crypto.SHA512, hashed[:])
	if err != nil {
		return err
	}
	request.Header.Set("Signature", `keyId="`+s.keyID+`",algorithm="`+signatureAlgorithm+`",headers="`+signedHeaders+
		`",signature="`+base64.StdEncoding.EncodeToString(signature)+`"`)
	return nil
}

type signatureParams struct {
	keyID     string
	algorithm string
	headers   []string
	signature []byte
}

func parseSignatureHeader(header string) (signatureParams, error) {
	fields := map[string]string{}
	for _, part := range strings.Split(header, ",") {
		name, value, found := strings.Cut(strings.TrimSpace(part), "=")
		if !found || len(value) < 2 || value[0] != '"' || value[len(value)-1] != '"' {
			return signatureParams{}, errInvalidSignature
		}
		fields[name] = value[1 : len(value)-1]
	}
	signature, err := base64.StdEncoding.DecodeString(fields["signature"])
	if err != nil || fields["keyId"] == "" || fields["headers"] == "" || len(signature) == 0 {
		return signatureParams{}, errInvalidSignature
	}
	return signatureParams{
		keyID:     fields["keyId"],
		algorithm: strings.ToLower(fields["algorithm"]),
		headers:   strings.Fields(strings.ToLower(fields["headers"])),
		signature: signature,
	}, nil
}

func signatureOrigin(keyID string) (string, error) {
	parsed, err := url.Parse(keyID)
	if err != nil || parsed.Scheme != "https" || parsed.Host == "" {
		return "", errInvalidSignature
	}
	return strings.ToLower(parsed.Host), nil
}

type verifiedSignature struct {
	keyID  string
	origin string
}

type publicKeyLookup func(keyID, origin string) (*rsa.PublicKey, error)

func verifyRequest(request *http.Request, body []byte, now time.Time, lookup publicKeyLookup) (verifiedSignature, error) {
	header := request.Header.Get("Signature")
	if header == "" {
		return verifiedSignature{}, errUnsigned
	}
	params, err := parseSignatureHeader(header)
	if err != nil {
		return verifiedSignature{}, err
	}
	for _, required := range []string{requestTargetHeader, "date", "host", "content-length", "digest"} {
		if !contains(params.headers, required) {
			return verifiedSignature{}, errInvalidSignature
		}
	}
	if err := checkDate(request.Header.Get("Date"), now); err != nil {
		return verifiedSignature{}, err
	}
	if request.Header.Get("Content-Length") != strconv.Itoa(len(body)) {
		return verifiedSignature{}, errInvalidSignature
	}
	if !digestMatches(request.Header.Get("Digest"), body) {
		return verifiedSignature{}, errInvalidSignature
	}
	origin, err := signatureOrigin(params.keyID)
	if err != nil {
		return verifiedSignature{}, err
	}
	publicKey, err := lookup(params.keyID, origin)
	if err != nil {
		return verifiedSignature{}, err
	}
	signingString := buildSigningString(request, params.headers)
	hashFunction, newHash := crypto.SHA256, sha256.New
	if params.algorithm == "rsa-sha512" {
		hashFunction, newHash = crypto.SHA512, sha512.New
	}
	if err := rsa.VerifyPKCS1v15(publicKey, hashFunction, digestOf(newHash, signingString), params.signature); err != nil {
		return verifiedSignature{}, errInvalidSignature
	}
	return verifiedSignature{keyID: params.keyID, origin: origin}, nil
}

func buildSigningString(request *http.Request, headers []string) string {
	lines := make([]string, 0, len(headers))
	for _, name := range headers {
		switch name {
		case requestTargetHeader:
			lines = append(lines, name+": "+strings.ToLower(request.Method)+" "+request.URL.RequestURI())
		case "host":
			lines = append(lines, name+": "+request.Host)
		default:
			lines = append(lines, name+": "+request.Header.Get(name))
		}
	}
	return strings.Join(lines, "\n")
}

func checkDate(raw string, now time.Time) error {
	date, err := http.ParseTime(raw)
	if err != nil {
		return errInvalidSignature
	}
	if age := now.Sub(date); age > signatureMaxAge || age < -signatureMaxAge {
		return errInvalidSignature
	}
	return nil
}

func digestMatches(header string, body []byte) bool {
	algorithm, value, found := strings.Cut(header, "=")
	if !found {
		return false
	}
	var expected []byte
	switch algorithm {
	case "SHA-256":
		sum := sha256.Sum256(body)
		expected = sum[:]
	case "SHA-512":
		sum := sha512.Sum512(body)
		expected = sum[:]
	default:
		return false
	}
	return subtle.ConstantTimeCompare([]byte(value), []byte(base64.StdEncoding.EncodeToString(expected))) == 1
}

func digestOf(newHash func() hash.Hash, value string) []byte {
	h := newHash()
	h.Write([]byte(value))
	return h.Sum(nil)
}

func contains(values []string, wanted string) bool {
	for _, value := range values {
		if value == wanted {
			return true
		}
	}
	return false
}
