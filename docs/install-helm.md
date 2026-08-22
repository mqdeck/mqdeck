# Install with Helm

The `mqdeck` chart supports Kubernetes, AKS, EKS, and OpenShift. It can install
API and Web together, or enable each MQDeck component independently. Broker and
Elasticsearch operators are intentionally not bundled.

## Requirements

- Kubernetes 1.25 or newer, or a compatible OpenShift release
- Helm 3.13 or newer
- An existing Elasticsearch service
- Access to `ghcr.io/mqdeck` images

## Install API and Web

```bash
VERSION=1.0.6
wget "https://github.com/mqdeck/mqdeck/releases/download/v${VERSION}/mqdeck-${VERSION}.tgz"
helm upgrade --install mqdeck "./mqdeck-${VERSION}.tgz" \
  --namespace mqdeck --create-namespace \
  --set global.elasticsearch.url=https://elasticsearch.example.com:9200 \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=mqdeck.example.com
```

Create Elasticsearch credentials before installation and reference the secret:

```bash
kubectl -n mqdeck create secret generic mqdeck-elasticsearch \
  --from-literal=MQDECK_ELASTICSEARCH_API_KEY='replace-me'

helm upgrade --install mqdeck ./mqdeck-1.0.6.tgz \
  --namespace mqdeck --create-namespace \
  --set global.elasticsearch.url=https://elasticsearch.example.com:9200 \
  --set global.elasticsearch.existingSecret=mqdeck-elasticsearch
```

Create the Web static-login secret as well. Keep the password and signing key
out of command history and public values files:

```bash
kubectl -n mqdeck create secret generic mqdeck-web-auth \
  --from-literal=MQDECK_AUTH_PASSWORD='replace-with-a-strong-password' \
  --from-literal=MQDECK_AUTH_SESSION_SECRET='replace-with-a-long-random-secret'

helm upgrade --install mqdeck ./mqdeck-1.0.6.tgz \
  --namespace mqdeck \
  --set web.existingSecret=mqdeck-web-auth \
  --set web.auth.username=admin \
  --set-string web.auth.displayName='MQDeck Operator'
```

## Enable the Agent

The Agent is disabled by default because every deployment needs explicit
broker endpoints and read-only credentials. Create its secret and configuration
without putting credentials in Helm values:

```bash
kubectl -n mqdeck create secret generic mqdeck-agent-secrets \
  --from-literal=MQDECK_ELASTICSEARCH_API_KEY='replace-me' \
  --from-literal=RABBITMQ_USERNAME='mqdeck-readonly' \
  --from-literal=RABBITMQ_PASSWORD='replace-me'

kubectl -n mqdeck create configmap mqdeck-agent-config \
  --from-file=mqdeck.yaml=./agent.yaml

helm upgrade --install mqdeck ./mqdeck-1.0.6.tgz \
  --namespace mqdeck \
  --set agent.enabled=true \
  --set agent.existingConfigMap=mqdeck-agent-config \
  --set agent.existingSecret=mqdeck-agent-secrets
```

Agent deployments use `Recreate` strategy to prevent duplicated schedules. Do
not increase `agent.replicaCount` unless agents have separate configurations
and identities.

The public MQDeck Agent image does not redistribute IBM MQ Client files. For
IBM MQ `client` transport in Kubernetes, provide an organization-approved
Agent image that includes IBM MQ Client 9.4 and `runmqsc`, then override
`agent.image.repository` and `agent.image.tag`. RabbitMQ HTTP and legacy IBM MQ
REST collection work with the public image as shipped. IBM MQ client licensing,
CCDTs, certificates, and patching remain under the deploying organization's
control.

## Install one component

API only:

```bash
helm upgrade --install mqdeck-api ./mqdeck-1.0.6.tgz \
  --namespace mqdeck --create-namespace \
  --set agent.enabled=false --set api.enabled=true --set web.enabled=false
```

Web only, pointing to an external API:

```bash
helm upgrade --install mqdeck-web ./mqdeck-1.0.6.tgz \
  --namespace mqdeck --create-namespace \
  --set agent.enabled=false --set api.enabled=false --set web.enabled=true \
  --set web.apiURL=https://api.mqdeck.example.com \
  --set web.existingSecret=mqdeck-web-auth
```

Agent only:

```bash
helm upgrade --install mqdeck-agent ./mqdeck-1.0.6.tgz \
  --namespace mqdeck --create-namespace \
  --set agent.enabled=true --set api.enabled=false --set web.enabled=false \
  --set agent.existingConfigMap=mqdeck-agent-config \
  --set agent.existingSecret=mqdeck-agent-secrets
```

## OpenShift

The images and chart do not require a fixed UID, privileged mode, host paths,
or service-account tokens. Enable an OpenShift Route:

```bash
helm upgrade --install mqdeck ./mqdeck-1.0.6.tgz \
  --namespace mqdeck --create-namespace \
  --set openshiftRoute.enabled=true \
  --set openshiftRoute.host=mqdeck.apps.example.com
```

The default security contexts drop all capabilities, prevent privilege
escalation, use a read-only root filesystem, and request the RuntimeDefault
seccomp profile. Platform policy can assign the runtime UID.

## AKS and EKS

Use the cluster's normal ingress controller and secret integration. Workload
identity is not required by MQDeck itself. If a private registry mirror is
used, set `global.imageRegistry` and `global.imagePullSecrets`.

## Validate before applying

```bash
helm lint ./mqdeck-1.0.6.tgz
helm template mqdeck ./mqdeck-1.0.6.tgz --namespace mqdeck > rendered.yaml
kubectl apply --dry-run=server -f rendered.yaml
```
