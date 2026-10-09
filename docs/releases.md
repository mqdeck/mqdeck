# Component releases

MQDeck publishes installable packages from the public
[`mqdeck/mqdeck`](https://github.com/mqdeck/mqdeck/releases) repository.
Each public release tag (`vX.Y.Z`) is a delivery of the latest API, Worker, and
Web packages available when that tag was cut. The delivery versions are listed
in that release's `COMPONENTS.md`.

API, Worker, Web, the adapter for IBM® MQ, and the Helm chart remain versioned by
the component that changed. For example, public release `v1.0.0` ships API
1.0.24, Worker 1.0.25, and Web 1.0.28.

## Where public users download packages

| What | Location |
| --- | --- |
| Install and upgrade archives | [mqdeck releases](https://github.com/mqdeck/mqdeck/releases) |
| Component versions in a delivery | `COMPONENTS.md` on that release |
| Checksums | `*_SHA256SUMS` and `BUNDLE_SHA256SUMS` on that release |
| Helm chart | Not a supported install path for the current on-demand API. See [Kubernetes and Helm](install-helm.md). |

Public install and upgrade commands always use:

```text
https://github.com/mqdeck/mqdeck/releases/download/v${MQDECK_VERSION}/<asset>
```

The release tag (`MQDECK_VERSION`) selects the public delivery. Asset file
names still embed the component version from `COMPONENTS.md` (for example
`mqdeck-api_1.0.24_linux_amd64.tar.gz`).

Component source repositories (`mqdeck-api`, `mqdeck-worker`, `mqdeck-web`) are
private. Their releases are an internal build feed only; operators and public
users must not be directed there for downloads.

## Publishing a public delivery

1. Publish or confirm the required private component releases (`vX.Y.Z` in each
   changed component repository).
2. Create and push `vX.Y.Z` in the public `mqdeck` repository.
3. The **Publish MQDeck release** workflow:
   - resolves the latest API, Worker, and Web private releases;
   - updates documentation version markers on `main`;
   - copies those package assets into the public `mqdeck` release;
   - writes `COMPONENTS.md` and `BUNDLE_SHA256SUMS`.

A public release tag is a delivery identifier. Unchanged services do not need
to be upgraded solely because a new public tag exists.

## Publishing a private component

1. Update the version in that component where applicable.
2. Run its tests and build locally.
3. Commit and push the component changes.
4. Create and push `vX.Y.Z` in that component repository.
5. Confirm the component release workflow and its checksum assets completed.
6. Publish a public `mqdeck` delivery so operators can download the packages.

The component workflows may also be started manually for an existing version
tag. They always build the tagged source, never an arbitrary branch head.

For installation commands, see the component-specific guides. For replacing
one or more installed components, see [Upgrade and rollback](upgrade.md).

IBM and IBM MQ are trademarks or registered trademarks of International
Business Machines Corporation. References describe compatibility only. See
[Trademarks and product independence](../TRADEMARKS.md).
