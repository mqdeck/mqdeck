# Public examples

These examples are safe starting points for public MQDeck installations. They
contain placeholders instead of credentials and must be adapted to the broker
names, endpoints, queues, certificates, and secret-management system of each
environment.

## Available examples

| File | Purpose |
| --- | --- |
| `agent.yaml` | Observe a RabbitMQ node through the Management API. |
| `agent-ibmmq-standalone.yaml` | Observe one standalone IBM MQ queue manager and enable Test Flight. |
| `test-flight-ibmmq-standalone.yaml` | Put and get one correlated synthetic message on the same queue manager. |
| `test-flight-ibmmq-single-route.yaml` | Test delivery between two queue managers through a sender channel. |
| `test-flight-ibmmq-multi-route.yaml` | Execute two IBM MQ routes in one definition. |
| `test-flight-ibmmq-dedicated-agent.yaml` | Pin a Test Flight route to one exact Agent ID. |
| `ibmmq-standalone-applications.md` | Keep a publisher and consumer connected to the same standalone queue manager for dependency-map observation. |

Test Flight performs active synthetic messaging. It puts one message and gets
only that message by its unique correlation ID. Normal observation checks stay
read-only and never create, change, clear, or delete broker objects.

Queue names used by Test Flight must start with `MQDECK.` and must exist before
the test runs.
