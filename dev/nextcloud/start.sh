#!/bin/sh
set -eu

cd "$(dirname "$0")"

if ! grep -q "polder.test" /etc/hosts || ! grep -q "nextcloud.test" /etc/hosts; then
	echo "Add the test names to /etc/hosts first:"
	echo '  echo "127.0.0.1 polder.test nextcloud.test" | sudo tee -a /etc/hosts'
	exit 1
fi

docker compose up -d caddy nextcloud

until docker compose exec -T caddy test -f /ca/root.crt; do sleep 1; done
docker compose exec -T caddy cat /ca/root.crt > caddy-root.crt

if ! security verify-cert -c caddy-root.crt >/dev/null 2>&1; then
	echo "Polder on this Mac needs to trust Caddy's certificate authority. Run once:"
	echo "  sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(pwd)/caddy-root.crt"
	exit 1
fi

until curl -fksS -o /dev/null https://nextcloud.test/status.php; do
	echo "Waiting for Nextcloud to finish installing..."
	sleep 5
done
