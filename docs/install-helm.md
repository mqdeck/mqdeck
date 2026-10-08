# Kubernetes and Helm

The chart deploys API, Agent, and Web as separate workloads. The chart version
and the three image versions are independent. Set only the image tags that the
deployment intends to change; there is no Elasticsearch dependency.

```bash
CHART_VERSION=X.Y.Z
API_VERSION=1.0.25 # MQDECK_API_VERSION
AGENT_VERSION=1.0.26 # MQDECK_AGENT_VERSION
WEB_VERSION=1.0.28 # MQDECK_WEB_VERSION
helm upgrade --install mqdeck oci://ghcr.io/mqdeck/charts/mqdeck \
  --version "${CHART_VERSION}" --namespace mqdeck --create-namespace \
  --set api.image.tag="${API_VERSION}" \
  --set agent.image.tag="${AGENT_VERSION}" \
  --set web.image.tag="${WEB_VERSION}"
```

Provide:

- an inventory ConfigMap or Secret mounted into API;
- `MQDECK_AGENT_TOKEN` from a Secret;
- WebSocket-capable Ingress routing;
- Agent egress to API and assigned brokers.
