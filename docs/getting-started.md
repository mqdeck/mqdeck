# Getting started

MQDeck requires an existing Elasticsearch deployment and at least one IBM MQ
or RabbitMQ endpoint. Follow the complete
[sequential installation](installation-sequence.md): Elasticsearch, API, Web,
broker access, and finally the Agent.

For a single-machine demo or proof of concept without Elasticsearch, follow
[Local file mode](local-mode.md). Production and distributed installations
should keep the Elasticsearch architecture.

## Choose an installation model

| Model | Recommended for |
| --- | --- |
| Linux binaries and `systemd` | Dedicated servers and simple virtual machines |
| Windows executable and service | Agent installation beside a Windows-hosted broker |
| Containers with Helm | Kubernetes, AKS, EKS, and OpenShift |

Download every artifact from the
[1.0.7 release](https://github.com/mqdeck/mqdeck/releases/tag/v1.0.7) and verify
it against `SHA256SUMS` before installation.

## Minimum production topology

1. Prepare Elasticsearch and separate API and Agent identities.
2. Install API and configure its read-only Elasticsearch identity.
3. Install Web and set `MQDECK_API_URL` to the API's internal URL.
4. Prepare inspection-only broker credentials. IBM MQ client observation needs
   `runmqsc` and a reachable `SVRCONN` channel.
5. Give the Agent an Elasticsearch identity restricted to writes on
   `mqdeck-hosts` and `mqdeck-data`.
6. Install the Agent last, validate its YAML, and then enable its service.
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

- [Follow the sequential installation](installation-sequence.md)
- [Run a single-machine local file demo](local-mode.md)
- [Configure the Agent, API, and Web](configuration.md)
- [Install the Agent on Linux](install-agent-linux.md)
- [Install the Agent on Windows](install-agent-windows.md)
- [Install API](install-api.md)
- [Install Web](install-web.md)
- [Install with Helm](install-helm.md)
- [Upgrade or roll back](upgrade.md)
- [Remove MQDeck](uninstall.md)
