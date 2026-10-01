# Kubernetes and Helm

The chart deploys API, Agent, and Web as separate workloads. Each component can
be enabled, upgraded, scaled, or disabled independently. Version `1.0.11` uses
the on-demand control plane and has no Elasticsearch dependency.

```bash
helm pull oci://ghcr.io/mqdeck/charts/mqdeck --version 1.0.11
helm upgrade --install mqdeck oci://ghcr.io/mqdeck/charts/mqdeck \
  --version 1.0.11 --namespace mqdeck --create-namespace
```

Provide:

- an inventory ConfigMap or Secret mounted into API;
- `MQDECK_AGENT_TOKEN` from a Secret;
- WebSocket-capable Ingress routing;
- Agent egress to API and assigned brokers.
