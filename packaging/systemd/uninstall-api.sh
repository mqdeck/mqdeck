#!/usr/bin/env sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this uninstaller as root." >&2
  exit 1
fi

purge=false
if [ "${1:-}" = "--purge" ]; then
  purge=true
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--purge]" >&2
  exit 1
fi

systemctl disable --now mqdeck-api 2>/dev/null || true
rm -f /etc/systemd/system/mqdeck-api.service
rm -rf /opt/mqdeck/api
if [ "$purge" = true ]; then
  rm -f /etc/mqdeck/api.env
fi
systemctl daemon-reload
echo "Removed MQDeck API. Configuration was $([ "$purge" = true ] && echo removed || echo retained)."
