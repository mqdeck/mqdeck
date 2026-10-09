# Third-party notices

MQDeck release artifacts include or link third-party software. The following
direct dependencies are included in the Go binaries:

- `github.com/robfig/cron/v3`, MIT License, copyright Rob Figueiredo and
  contributors.
- `gopkg.in/yaml.v3`, MIT and Apache License 2.0, copyright the Go YAML authors
  and the libyaml authors.
- `golang.org/x/sys`, BSD 3-Clause License, copyright the Go authors.

The Web standalone artifact contains its runtime Node.js packages, including
their package metadata and license files. The Web container is based on the
official Node.js Alpine image. Worker and API containers use the Distroless
Debian static non-root image.

## Trademarks and independence

IBM and IBM MQ are trademarks or registered trademarks of International
Business Machines Corporation in the United States, other countries, or both.

RabbitMQ is a trademark of Broadcom Inc. in the United States and other
countries.

Kubernetes, Microsoft, Microsoft Entra, Microsoft Azure, Windows, Amazon Web
Services (AWS), Red Hat OpenShift, Elasticsearch, and other product and service
names are trademarks of their respective owners.

References to third-party products are nominative and describe compatibility
only. MQDeck is an independent product and is not affiliated with, endorsed
by, sponsored by, or supported by IBM, Broadcom, or any other trademark owner.
No third-party logo is included in the MQDeck website or used as an MQDeck
brand element. See the complete [trademark and independence notice](TRADEMARKS.md).
