# Installation sequence

## 1. Install API

Place `inventory.yaml` on the API host and configure:

```dotenv
MQDECK_INVENTORY_PATH=/etc/mqdeck/inventory.yaml
MQDECK_AGENT_TOKEN=replace-with-a-long-random-secret
MQDECK_DIAGNOSTIC_TIMEOUT=45s
```

Validate before starting:

```bash
mqdeck-api -validate
mqdeck-api
curl --fail http://127.0.0.1:8080/healthz
```

## 2. Install Web

Set `MQDECK_API_URL`, static login credentials, and the session secret. Verify
that the login page and authenticated inventory proxy are reachable.

## 3. Prepare broker identities

Grant only the read authorities needed by the configured adapter checks. IBM MQ
client observation uses `SVRCONN` and `DISPLAY` commands. RabbitMQ uses HTTP
`GET` requests against the Management API.

## 4. Install Agents

Install each Agent at a network point that can reach its assigned brokers. The
Agent opens the connection to the API, so it needs no inbound listener.

```bash
mqdeck-agent -config /etc/mqdeck/agent.yaml -validate
mqdeck-agent -config /etc/mqdeck/agent.yaml
```

Confirm registration with `GET /api/v1/agents`, then open a broker detail page
to execute the first diagnosis.
