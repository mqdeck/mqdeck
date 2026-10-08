# Kubernetes and Helm

Install MQDeck with the Linux or Windows packages in
[Getting started](getting-started.md). Those packages match the current
on-demand API: a static inventory file, an outbound Worker, and no
Elasticsearch.

The Helm chart in `charts/mqdeck` is not a supported install path for this
release. It still injects Elasticsearch environment variables, does not mount
`inventory.yaml`, and describes a Worker Service port the current Worker does
not listen on. Do not point a production cluster at that chart until it is
updated for the on-demand control plane.

When the chart is updated, image tags stay independent of the chart version.
Set only the component tags listed in the public release `COMPONENTS.md`.
