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
official Node.js Alpine image. Agent and API containers use the Distroless
Debian static non-root image.

IBM, IBM MQ, RabbitMQ, Kubernetes, Azure, AWS, OpenShift, Elasticsearch, and
other names are trademarks of their respective owners. MQDeck is not endorsed
by those owners.
