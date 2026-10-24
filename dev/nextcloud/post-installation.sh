#!/bin/sh
set -eu

root_ca=/ca/root.crt
until [ -f "$root_ca" ]; do sleep 1; done

php /var/www/html/occ config:system:set allow_local_remote_servers --value=true --type=boolean
php /var/www/html/occ security:certificates:import "$root_ca"
php /var/www/html/occ app:disable sharebymail
