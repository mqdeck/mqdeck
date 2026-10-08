#!/usr/bin/env sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer as root." >&2
  exit 1
fi

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
service_name=mqdeck-worker
was_active=false
if systemctl is-active --quiet "$service_name" 2>/dev/null; then
  was_active=true
  systemctl stop "$service_name"
fi

if ! id mqdeck >/dev/null 2>&1; then
  useradd --system --home-dir /nonexistent --shell /usr/sbin/nologin mqdeck
fi
install -d -o root -g root -m 0755 /opt/mqdeck/worker /etc/mqdeck
install -d -o mqdeck -g mqdeck -m 0750 /var/lib/mqdeck
install -o root -g root -m 0755 "$source_dir/mqdeck-worker" /opt/mqdeck/worker/mqdeck-worker
if [ ! -f /etc/mqdeck/worker.properties ]; then
  install -o root -g mqdeck -m 0640 "$source_dir/worker.properties.example" /etc/mqdeck/worker.properties
fi
install -o root -g root -m 0644 "$source_dir/mqdeck-worker.service" /etc/systemd/system/mqdeck-worker.service
systemctl daemon-reload
if [ "$was_active" = true ]; then
  systemctl start "$service_name"
fi
echo "Installed MQDeck Worker. Review /etc/mqdeck/worker.properties, validate, then enable the service."
