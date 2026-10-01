# Kubernetes and Helm

The simplified control-plane architecture requires updated chart templates for
inventory mounting, Agent WebSocket configuration, and removal of Elasticsearch
values. Do not use the legacy 1.0.x chart for this source revision.

Until the chart migration is released, deploy API, Web, and Agent from their
container images with:

- an inventory ConfigMap or Secret mounted into API;
- `MQDECK_AGENT_TOKEN` from a Secret;
- WebSocket-capable Ingress routing;
- no Elasticsearch dependency;
- Agent egress to API and assigned brokers.
