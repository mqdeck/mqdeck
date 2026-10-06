#!/usr/bin/env sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this installer as root." >&2
  exit 1
fi
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js 20.20 or newer is required." >&2
  exit 1
fi
if ! node -e 'const [major, minor] = process.versions.node.split(".").map(Number); process.exit(major > 20 || (major === 20 && minor >= 20) ? 0 : 1)'; then
  echo "Node.js 20.20 or newer is required." >&2
  exit 1
fi

source_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
service_name=mqdeck-web
was_active=false
if systemctl is-active --quiet "$service_name" 2>/dev/null; then
  was_active=true
  systemctl stop "$service_name"
fi

if ! id mqdeck >/dev/null 2>&1; then
  useradd --system --home-dir /nonexistent --shell /usr/sbin/nologin mqdeck
fi
install -d -o root -g root -m 0755 /opt/mqdeck /etc/mqdeck
rm -rf /opt/mqdeck/web.new
install -d -o root -g root -m 0755 /opt/mqdeck/web.new
cp -R "$source_dir/app/." /opt/mqdeck/web.new/
chown -R root:root /opt/mqdeck/web.new
if [ -d /opt/mqdeck/web ]; then
  rm -rf /opt/mqdeck/web.previous
  mv /opt/mqdeck/web /opt/mqdeck/web.previous
fi
mv /opt/mqdeck/web.new /opt/mqdeck/web
if [ ! -f /etc/mqdeck/web.env ]; then
  install -o root -g mqdeck -m 0640 "$source_dir/web.env.example" /etc/mqdeck/web.env
fi
install -o root -g root -m 0644 "$source_dir/mqdeck-web.service" /etc/systemd/system/mqdeck-web.service
systemctl daemon-reload
if [ "$was_active" = true ]; then
  systemctl start "$service_name"
fi
echo "Installed or upgraded MQDeck Web. Existing configuration was preserved and the previous application directory remains at /opt/mqdeck/web.previous."
