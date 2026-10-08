# Install Worker on Linux

Install a Worker at every network point that must reach brokers. IBM MQ targets
also require IBM MQ Client 9.4 with `runmqsc` available in `PATH`.

Download packages from the public
[MQDeck releases](https://github.com/mqdeck/mqdeck/releases) page. Set
`MQDECK_VERSION` to the release tag and `WORKER_VERSION` to the Worker version
listed in that release's `COMPONENTS.md`.

## RHEL, Rocky Linux, AlmaLinux, or Oracle Linux

```bash
MQDECK_VERSION=1.0.4 # MQDECK_VERSION
WORKER_VERSION=1.0.33 # MQDECK_WORKER_VERSION
curl -fLO "https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/mqdeck-worker_${WORKER_VERSION}_linux_amd64.tar.gz"
tar -xzf "mqdeck-worker_${WORKER_VERSION}_linux_amd64.tar.gz"
cd "mqdeck-worker_${WORKER_VERSION}_linux_amd64"
sudo ./install-worker.sh
```

Use `linux_arm64` for ARM64. `wget` can be used instead of `curl -fLO` with the
same URL.

The installed properties point to the local API at
`http://127.0.0.1:8080`. Change `mqdeck.api.url` in
`/etc/mqdeck/worker.properties` only when the API runs on another machine. Review the
Worker token and configuration, then run:

```bash
sudo -u mqdeck /opt/mqdeck/worker/mqdeck-worker -validate
sudo systemctl enable --now mqdeck-worker
sudo systemctl status mqdeck-worker --no-pager
sudo journalctl -u mqdeck-worker -n 100 --no-pager
```

When troubleshooting IBM MQ, test `runmqsc` as the same unprivileged account
used by the service. Testing only as `root` can hide a CHLAUTH, MCAUSER, or
command-security difference:

```bash
sudo -u mqdeck env MQSERVER='CHANNEL/TCP/mq.example.net(1414)' \
  /opt/mqm/bin/runmqsc -c QM1
```

The Worker opens an outbound HTTPS/WebSocket connection and listens on no
inbound port.

## View Worker logs

Follow the structured Worker log in real time with systemd:

```bash
sudo journalctl -u mqdeck-worker -f
```

Useful production queries include:

```bash
# Last 100 entries
sudo journalctl -u mqdeck-worker -n 100 --no-pager

# Entries from the last hour
sudo journalctl -u mqdeck-worker --since "1 hour ago" --no-pager

# Warnings and errors from the current boot
sudo journalctl -u mqdeck-worker -b -p warning --no-pager
```

Look for `connected to control plane`, `collection started`, and
`collection completed`. A repeated `control plane connection ended; retrying`
entry means that the Worker cannot maintain its outbound API connection. A
collection failure includes the broker ID and the read-only check that failed.

For an existing Worker, use the [upgrade and rollback guide](upgrade.md) so the
configuration is preserved and Workers are upgraded one network zone at a time.
