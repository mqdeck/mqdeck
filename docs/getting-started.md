# Getting started

MQDeck is distributed as three independent components. Install only the
components required on each machine:

1. `mqdeck-api`: inventory and Agent control plane.
2. `mqdeck-agent`: outbound executor placed in each broker network zone.
3. `mqdeck-web`: operator interface and authenticated API proxy.

There is no public monolithic package. Each component has its own release,
checksum, configuration, operating-system service, and upgrade lifecycle.

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
settings.
