# Install the Agent on Linux

The Agent is a statically linked executable. It can observe local brokers or
remote broker endpoints from a network observation point.

## Requirements

- A supported `amd64` or `arm64` Linux host
- Network access to Elasticsearch and configured broker endpoints
- A least-privilege Elasticsearch identity with write access only to the
  MQDeck host and evidence indices
- Read-only IBM MQ or RabbitMQ credentials

## Download and verify

```bash
VERSION=1.0.0
ARCH=amd64
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-agent-${VERSION}-linux-${ARCH}.tar.gz"
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/SHA256SUMS"
grep "mqdeck-agent-${VERSION}-linux-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -
tar -xzf "mqdeck-agent-${VERSION}-linux-${ARCH}.tar.gz"
cd "mqdeck-agent-${VERSION}-linux-${ARCH}"
```

## Install

```bash
sudo ./install.sh
sudo editor /etc/mqdeck/agent.yaml
sudo editor /etc/mqdeck/agent.env
sudo chmod 600 /etc/mqdeck/agent.env
```

Validate the configuration before starting the service:

```bash
sudo -u mqdeck /opt/mqdeck/agent/mqdeck-agent \
  -config /etc/mqdeck/agent.yaml -validate
```

Enable and start it only after validation succeeds:

```bash
sudo systemctl enable --now mqdeck-agent
sudo systemctl status mqdeck-agent
sudo journalctl -u mqdeck-agent -f
```

The installation script does not start the service automatically. Existing
configuration files are preserved during upgrades.

## Local broker commands

For local transport, set the adapter executable to an absolute path available
to the `mqdeck` service account. IBM MQ local checks accept only `DISPLAY`
MQSC commands. RabbitMQ local checks accept only diagnostic allowlisted
subcommands. Grant the service account only the operating-system permissions
needed to run those read-only tools.

## Uninstall

```bash
sudo systemctl disable --now mqdeck-agent
sudo rm /etc/systemd/system/mqdeck-agent.service
sudo rm -rf /opt/mqdeck/agent
sudo systemctl daemon-reload
```

Configuration under `/etc/mqdeck` is intentionally retained.
