# Install the API

The MQDeck API is a statically linked, read-only Elasticsearch query service.
It never receives Agent telemetry.

## Linux

```bash
VERSION=1.0.5
ARCH=amd64
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-api-${VERSION}-linux-${ARCH}.tar.gz"
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/SHA256SUMS"
grep "mqdeck-api-${VERSION}-linux-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -
tar -xzf "mqdeck-api-${VERSION}-linux-${ARCH}.tar.gz"
cd "mqdeck-api-${VERSION}-linux-${ARCH}"
sudo ./install.sh
sudo editor /etc/mqdeck/api.env
sudo chmod 600 /etc/mqdeck/api.env
sudo systemctl enable --now mqdeck-api
curl --fail http://127.0.0.1:8080/healthz
```

Use an Elasticsearch identity that can only read `mqdeck-hosts` and
`mqdeck-data`.

## Windows

Download and verify `mqdeck-api-1.0.5-windows-amd64.zip`, expand it, set the
required machine-level `MQDECK_*` environment variables, and run the included
script from an elevated PowerShell prompt:

```powershell
.\install-api-service.ps1
Restart-Service MQDeckAPI
Invoke-RestMethod http://127.0.0.1:8080/healthz
```

## Environment

| Variable | Default |
| --- | --- |
| `MQDECK_API_ADDRESS` | `:8080` |
| `MQDECK_ELASTICSEARCH_URL` | `http://localhost:9200` |
| `MQDECK_HOSTS_INDEX` | `mqdeck-hosts` |
| `MQDECK_DATA_INDEX` | `mqdeck-data` |
| `MQDECK_ELASTICSEARCH_TIMEOUT` | `10s` |
| `MQDECK_CORS_ORIGINS` | `http://localhost:3000` |
| `MQDECK_ELASTICSEARCH_USERNAME` | empty |
| `MQDECK_ELASTICSEARCH_PASSWORD` | empty |
| `MQDECK_ELASTICSEARCH_API_KEY` | empty |
