# Contributing to MQDeck

Thank you for helping improve MQDeck. The platform is split into focused
repositories so changes can be reviewed and released independently.

## Choose the repository

- Platform documentation: `mqdeck`
- Collection scheduling and storage: `mqdeck-agent`
- Query endpoints and report normalization: `mqdeck-api`
- User interface: `mqdeck-web`
- Local infrastructure and simulation: `mqdeck-local`
- Broker-specific collection: the corresponding adapter repository

Open an issue in the repository that owns the behavior. For security concerns,
follow [SECURITY.md](SECURITY.md) instead of opening a public issue.

## Development workflow

1. Fork the relevant repository and create a focused branch.
2. Keep user-facing text, documentation, commit messages, and pull-request
   descriptions in English.
3. Preserve the read-only safety model. New broker operations must have narrow
   validation and tests that prove mutating inputs are rejected.
4. Add or update tests and documentation with the implementation.
5. Open a pull request that explains the change, its operational impact, and
   the validation performed.

## Validation

Run the checks for the repository you changed:

| Repository | Commands |
| --- | --- |
| `mqdeck-agent` | `make validate` |
| `mqdeck-api` | `make test` |
| `mqdeck-web` | Run `build`, `test`, `lint`, and `typecheck` with npm |
| `mqdeck-local` | `make verify` with the environment running |
| Go adapters | `go test ./...` |

For cross-component changes, use the sibling checkout described in
[Getting started](docs/getting-started.md) and run the local end-to-end
verification.

## Documentation style

- Write concise, task-oriented English.
- Use sentence case for headings.
- Put commands in fenced code blocks and identify destructive commands.
- Link to the owning repository instead of duplicating implementation details
  that are likely to change.
