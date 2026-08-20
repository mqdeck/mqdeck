# Getting started

MQDeck requires an existing Elasticsearch deployment and at least one IBM MQ
or RabbitMQ endpoint. Start with API and Web, then add an Agent after preparing
read-only broker credentials.

## Choose an installation model

| Model | Recommended for |
| --- | --- |
| Linux binaries and `systemd` | Dedicated servers and simple virtual machines |
| Windows executable and service | Agent installation beside a Windows-hosted broker |
| Containers with Helm | Kubernetes, AKS, EKS, and OpenShift |

Download every artifact from the
[1.0.2 release](https://github.com/mqdeck/mqdeck/releases/tag/v1.0.2) and verify
it against `SHA256SUMS` before installation.

## Minimum production topology

1. Install API and configure a read-only Elasticsearch identity.
2. Install Web and set `MQDECK_API_URL` to the API's internal URL.
3. Install one Agent at a network point that can reach the brokers, or install
   an Agent beside each broker. IBM MQ client observation needs `runmqsc` from
   an IBM MQ client installation and a reachable `SVRCONN` channel.
4. Give the Agent an Elasticsearch identity restricted to writes on
   `mqdeck-hosts` and `mqdeck-evidence-*`.
5. Configure broker accounts with inspection permissions only.
6. Validate Agent YAML before enabling its service.
7. Place Web behind a TLS reverse proxy or ingress.

## Verify the deployment

API health:

```bash
curl --fail https://api.mqdeck.example.com/healthz
```

Agent version and configuration:

```bash
/opt/mqdeck/agent/mqdeck-agent -version
sudo -u mqdeck /opt/mqdeck/agent/mqdeck-agent \
  -config /etc/mqdeck/agent.yaml -validate
```

After the Agent's first successful collection, open Web and confirm the host
appears in Observe. Open its report and review collection health, queues,
channels, connections, consumers, and findings.

## Next steps

- [Configure the Agent, API, and Web](configuration.md)
- [Install the Agent on Linux](install-agent-linux.md)
- [Install the Agent on Windows](install-agent-windows.md)
- [Install API](install-api.md)
- [Install Web](install-web.md)
- [Install with Helm](install-helm.md)
