#!/usr/bin/env sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer as root." >&2
  exit 1
fi

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
service_name=mqdeck-api
was_active=false
if systemctl is-active --quiet "$service_name" 2>/dev/null; then
  was_active=true
  systemctl stop "$service_name"
fi

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
if [ "$was_active" = true ]; then
  systemctl start "$service_name"
fi
echo "Installed or upgraded MQDeck API. Existing configuration was preserved."
