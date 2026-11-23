#!/bin/sh
set -eu

cd "$(dirname "$0")"

mkdir -p certs
if [ ! -f certs/cert.pem ]; then
	openssl req -x509 -newkey rsa:2048 -nodes -days 3650 -subj "/CN=127.0.0.1" \
		-addext "subjectAltName=IP:127.0.0.1,DNS:localhost" \
		-keyout certs/key.pem -out certs/cert.pem 2>/dev/null
fi

docker compose up -d "$@"
(cd ../.. && go run ./dev/sso/bootstrap)

if ! security verify-cert -c certs/cert.pem >/dev/null 2>&1; then
	echo "Authelia uses a self-signed certificate. For Polder on this Mac to reach it, run once:"
	echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(pwd)/certs/cert.pem"
fi
