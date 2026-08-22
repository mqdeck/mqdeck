# Install the Web interface on Linux

The Web release is a prebuilt standalone Node.js application. No source tree,
compiler, or `npm install` step is required.

## Requirements

- `amd64` or `arm64` Linux
- Node.js 22 LTS
- Network access from the Web server to MQDeck API

## Download and install

```bash
VERSION=1.0.5
ARCH=amd64
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-web-${VERSION}-linux-${ARCH}.tar.gz"
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/SHA256SUMS"
grep "mqdeck-web-${VERSION}-linux-${ARCH}.tar.gz" SHA256SUMS | sha256sum -c -
tar -xzf "mqdeck-web-${VERSION}-linux-${ARCH}.tar.gz"
cd "mqdeck-web-${VERSION}-linux-${ARCH}"
sudo ./install.sh
sudo editor /etc/mqdeck/web.env
sudo systemctl enable --now mqdeck-web
curl --fail http://127.0.0.1:3000/
```

Example `/etc/mqdeck/web.env`:

```dotenv
MQDECK_API_URL=http://127.0.0.1:8080
MQDECK_TEST_RUNNER_URL=http://agent.example.com:8090
MQDECK_TEST_RUNNER_TOKEN=replace-with-a-secret
MQDECK_AUTH_USERNAME=admin
MQDECK_AUTH_PASSWORD=replace-with-a-strong-password
MQDECK_AUTH_DISPLAY_NAME=MQDeck Operator
MQDECK_AUTH_SESSION_SECRET=replace-with-a-long-random-secret
```

MQDeck Web requires the configured static account before it exposes the
observation workspace or its same-origin API proxies. The session is signed,
stored in an HTTP-only cookie, and expires after eight hours. Generate a unique
session secret for every installation; do not use the development defaults in
production.

Place a TLS reverse proxy or load balancer in front of port 3000. The browser
uses same-origin routes; the Web server makes requests to the configured API.

The JavaScript and CSS delivered to browsers are necessarily visible to users.
They remain covered by the MQDeck Community Binary License.
