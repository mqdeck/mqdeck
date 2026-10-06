# Getting started

MQDeck is distributed as three independent components. Install only the
components required on each machine:

1. `mqdeck-api`: inventory and Agent control plane.
2. `mqdeck-agent`: outbound executor placed in each broker network zone.
3. `mqdeck-web`: operator interface and authenticated API proxy.

Public packages always come from
[MQDeck releases](https://github.com/mqdeck/mqdeck/releases). Use the public
release tag (`MQDECK_VERSION`) in the download URL and the component versions
from that release's `COMPONENTS.md` in the archive names. Private component
repositories are internal build feeds only.

Each component still has its own version, checksum, configuration,
operating-system service, and upgrade lifecycle. A public delivery may contain
one, two, or all three components without forcing unchanged services to upgrade.

For RHEL-family Linux distributions, download the component package with
`curl` or `wget`, run its installer as root, review the generated files under
`/etc/mqdeck`, validate, and enable it with `systemctl`. Windows packages carry
a PowerShell installer that creates the corresponding Windows service.

Install in this order:

1. [API](install-api.md)
2. [Web](install-web.md)
3. [Agent on Linux](install-agent-linux.md) or [Agent on Windows](install-agent-windows.md)

See the [installation sequence](installation-sequence.md) for the verification
path and the [configuration reference](configuration.md) for all supported
settings. Existing installations should follow the component-by-component
[upgrade and rollback guide](upgrade.md).

For package locations and the independent publishing workflow, see
[Component releases](releases.md).
