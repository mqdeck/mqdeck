# Component releases

MQDeck does not use a single product version. API, Agent, Web, the IBM MQ
adapter, and the Helm chart are versioned according to the component that
changed. For example, an installation may run API 1.0.19, Agent 1.0.20, and
Web 1.0.21.

## Where packages are published

| Component | Release repository | Release trigger |
| --- | --- | --- |
| API | [mqdeck-api releases](https://github.com/mqdeck/mqdeck-api/releases) | `vX.Y.Z` tag in `mqdeck-api` |
| Agent | [mqdeck-agent releases](https://github.com/mqdeck/mqdeck-agent/releases) | `vX.Y.Z` tag in `mqdeck-agent` |
| Web | [mqdeck-web releases](https://github.com/mqdeck/mqdeck-web/releases) | `vX.Y.Z` tag in `mqdeck-web` |
| Helm chart | [mqdeck releases](https://github.com/mqdeck/mqdeck/releases) | `chart-vX.Y.Z` tag in `mqdeck` |

Each component release contains its own archives and checksum file. A release
must be created only in a repository whose component changed.

## Optional bundles

The `mqdeck` repository can publish a convenience bundle from already
published component releases. Run the **Publish component bundle** workflow,
choose a bundle tag, and fill only the versions that belong in that delivery.
Blank components are intentionally omitted.

Every bundle includes `COMPONENTS.md`, which records the exact component
versions, and `BUNDLE_SHA256SUMS`. A bundle tag is a delivery identifier, not a
shared software version, and does not require unchanged services to be
upgraded.

## Publishing a component

1. Update the version in that component where applicable.
2. Run its tests and build locally.
3. Commit and push the component changes.
4. Create and push `vX.Y.Z` in that component repository.
5. Confirm the component release workflow and its checksum assets completed.
6. Publish an optional bundle only when operators need a single download set.

The component workflows may also be started manually for an existing version
tag. They always build the tagged source, never an arbitrary branch head.

For installation commands, see the component-specific guides. For replacing
one or more installed components, see [Upgrade and rollback](upgrade.md).
