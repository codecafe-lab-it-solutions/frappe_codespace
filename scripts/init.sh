#!bin/bash

set -e

if [[ -f "/workspaces/frappe_codespace/frappe-bench/apps/frappe" ]]
then
    echo "Bench already exists, skipping init"
    exit 0
fi

rm -rf /workspaces/frappe_codespace/.git

cd /workspace

echo "Installing pre-commit..."
uv tool install pre-commit

bench init \
--version v16.23.0 \
--ignore-exist \
--skip-redis-config-generation \
--dev \
frappe-bench

cd frappe-bench

# Use containers instead of localhost
bench set-mariadb-host mariadb
bench set-redis-cache-host redis://redis-cache:6379
bench set-redis-queue-host redis://redis-queue:6379
bench set-redis-socketio-host redis://redis-socketio:6379

# Remove redis from Procfile
sed -i '/redis/d' ./Procfile
sed -i '/watch/d' ./Procfile


bench new-site dev.localhost \
--db-root-username root \
--mariadb-root-password 123 \
--admin-password admin \
--mariadb-user-host-login-scope '%'

bench --site dev.localhost set-config mute_emails 1
bench --site dev.localhost clear-cache
bench use dev.localhost