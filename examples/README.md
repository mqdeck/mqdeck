# Public examples

These files are starting points with explicit example values. Replace every
example endpoint and credential before use; inventory values are not expanded
from environment variables.

| File | Purpose |
| --- | --- |
| `inventory.yaml` | API-side IBM MQ and RabbitMQ inventory with preferred Agent routing |
| `agent.yaml` | Outbound Agent control-plane connection |
| `ibmmq-svrconn.md` | Least-privilege IBM MQ client connection without `mqweb` |
| `ibmmq-standalone-applications.md` | Local publisher and consumer sessions for diagnosis testing |

Broker checks are executed only when a detail report is requested. The
examples contain no schedules, storage configuration, or synthetic messaging.
