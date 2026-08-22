# Sequential installation

Install MQDeck in the order described here. The API and Web interface must be
ready before the first Agent begins sending broker observations.

## 1. Prepare Elasticsearch

Use an existing Elasticsearch cluster or a dedicated single-node deployment.
Enable authentication and TLS whenever Elasticsearch is reached over a network.

Prepare separate identities:

- an API identity with read access to `mqdeck-hosts`, `mqdeck-data`, and
  `mqdeck-agents`;
- an Agent identity with write access to those indices and the cluster
  privileges needed to manage the MQDeck ILM policy and index template.

Confirm connectivity before continuing:

```bash
curl --fail --user mqdeck-api https://elasticsearch.example.com:9200/
```

See [Configuration](configuration.md) for the exact MQDeck settings and
least-privilege guidance.

## 2. Install the API

Download the API package for the server architecture, verify its checksum, and
run the installer:

```bash
VERSION=1.0.6
ARCH=amd64
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-api-${VERSION}-linux-${ARCH}.tar.gz"
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/SHA256SUMS"
grep "mqdeck-api-${VERSION}-linux-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -
tar -xzf "mqdeck-api-${VERSION}-linux-${ARCH}.tar.gz"
cd "mqdeck-api-${VERSION}-linux-${ARCH}"
sudo ./install.sh
sudo editor /etc/mqdeck/api.env
sudo systemctl enable --now mqdeck-api
curl --fail http://127.0.0.1:8080/healthz
```

Do not continue until the health endpoint succeeds.

## 3. Install the Web interface

Install Node.js 20.20 or newer first. The Web package is already built and does
not require `npm install`.

```bash
node --version
VERSION=1.0.6
ARCH=amd64
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-web-${VERSION}-linux-${ARCH}.tar.gz"
grep "mqdeck-web-${VERSION}-linux-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -
tar -xzf "mqdeck-web-${VERSION}-linux-${ARCH}.tar.gz"
cd "mqdeck-web-${VERSION}-linux-${ARCH}"
sudo ./install.sh
sudo editor /etc/mqdeck/web.env
sudo systemctl enable --now mqdeck-web
curl --fail http://127.0.0.1:3000/
```

Set `MQDECK_API_URL` to the API URL that is reachable from the Web server. Put
the Web interface behind a TLS reverse proxy before exposing it to users.

## 4. Prepare broker access

Create inspection-only RabbitMQ or IBM MQ credentials. For IBM MQ client
transport, install IBM MQ Client 9.4 and provide a dedicated read-only
`SVRCONN` channel. Validate network access from the future Agent host to every
configured broker and to Elasticsearch.

## 5. Install the Agent last

The Agent writes directly to Elasticsearch, so install it only after storage,
API, Web, and broker credentials are ready.

```bash
VERSION=1.0.6
ARCH=amd64
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-agent-${VERSION}-linux-${ARCH}.tar.gz"
grep "mqdeck-agent-${VERSION}-linux-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -
tar -xzf "mqdeck-agent-${VERSION}-linux-${ARCH}.tar.gz"
cd "mqdeck-agent-${VERSION}-linux-${ARCH}"
sudo ./install.sh
sudo editor /etc/mqdeck/agent.yaml
sudo editor /etc/mqdeck/agent.env
sudo -u mqdeck /opt/mqdeck/agent/mqdeck-agent \
  -config /etc/mqdeck/agent.yaml -validate
sudo systemctl enable --now mqdeck-agent
```

## 6. Verify the complete platform

Check the Agent log and then open the Web interface:

```bash
sudo systemctl status mqdeck-api mqdeck-web mqdeck-agent
sudo journalctl -u mqdeck-agent -n 100 --no-pager
```

Confirm that the Agent appears as active, its hosts are listed in Overview,
and each host report contains a recent successful Probe result.

For maintenance, continue with [Upgrade and rollback](upgrade.md) and
[Remove MQDeck](uninstall.md).
