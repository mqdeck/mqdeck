# Contributing to MQDeck

MQDeck implementation repositories are private. This public repository accepts
issues and pull requests for installation documentation, Helm values examples,
and packaging guidance only.

## Report an issue

Open a public issue with:

- the affected MQDeck version and component;
- operating system or Kubernetes distribution;
- installation method;
- expected and observed behavior;
- sanitized logs and configuration excerpts.

Never include credentials, broker payloads, Elasticsearch data, or production
host names. Report suspected vulnerabilities privately through
[SECURITY.md](SECURITY.md).

## Documentation changes

1. Create a focused branch.
2. Write documentation, commit messages, and pull-request descriptions in
   English.
3. Test every command you change where practical.
4. Run `helm lint charts/mqdeck` and render relevant chart combinations when
   changing Helm files.
5. Open a pull request explaining the operator impact and validation performed.

External source-code contributions cannot currently be accepted because the
implementation repositories are not publicly distributed.
