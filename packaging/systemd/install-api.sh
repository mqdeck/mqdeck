#!/usr/bin/env sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer as root." >&2
  exit 1
fi

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if ! id mqdeck >/dev/null 2>&1; then
  useradd --system --home-dir /nonexistent --shell /usr/sbin/nologin mqdeck
fi
install -d -o root -g root -m 0755 /opt/mqdeck/api /etc/mqdeck
install -o root -g root -m 0755 "$source_dir/mqdeck-api" /opt/mqdeck/api/mqdeck-api
if [ ! -f /etc/mqdeck/api.env ]; then
  install -o root -g mqdeck -m 0640 "$source_dir/api.env.example" /etc/mqdeck/api.env
fi
install -o root -g root -m 0644 "$source_dir/mqdeck-api.service" /etc/systemd/system/mqdeck-api.service
systemctl daemon-reload
echo "Installed MQDeck API. Edit /etc/mqdeck/api.env, then enable the service."
