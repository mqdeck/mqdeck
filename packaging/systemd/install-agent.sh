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
install -d -o root -g root -m 0755 /opt/mqdeck/agent /etc/mqdeck
install -o root -g root -m 0755 "$source_dir/mqdeck-agent" /opt/mqdeck/agent/mqdeck-agent
if [ ! -f /etc/mqdeck/agent.yaml ]; then
  install -o root -g mqdeck -m 0640 "$source_dir/mqdeck.yaml.example" /etc/mqdeck/agent.yaml
fi
if [ ! -f /etc/mqdeck/agent.env ]; then
  install -o root -g mqdeck -m 0640 "$source_dir/agent.env.example" /etc/mqdeck/agent.env
fi
install -o root -g root -m 0644 "$source_dir/mqdeck-agent.service" /etc/systemd/system/mqdeck-agent.service
systemctl daemon-reload
echo "Installed MQDeck Agent. Edit /etc/mqdeck/agent.yaml and /etc/mqdeck/agent.env, validate the configuration, then enable the service."
