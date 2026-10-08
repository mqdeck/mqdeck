# Public examples

These files are starting points with explicit example values. Replace every
example endpoint and credential before use; inventory values are not expanded
from environment variables.

| File | Purpose |
| --- | --- |
| `inventory.yaml` | API-side IBM MQ and RabbitMQ inventory with preferred Worker routing |
| `ibmmq-svrconn.md` | Least-privilege IBM MQ client connection without `mqweb` |
| `ibmmq-standalone-applications.md` | Local publisher and consumer sessions for diagnosis testing |

Broker checks run only when an operator collects a host view. These examples
contain no schedules, retained storage, or Test Flight configuration.
