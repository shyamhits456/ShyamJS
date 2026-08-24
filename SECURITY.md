# Security Policy

## Responsible use

ShyamJS is intended **exclusively for authorized security testing**. Only scan
assets you own or are explicitly permitted, in writing, to assess (for example
under a penetration-test engagement, a bug-bounty program's stated scope, or on
your own infrastructure).

Unauthorized scanning may violate computer-misuse laws (e.g. the CFAA, the UK
Computer Misuse Act, and equivalents) as well as the target's terms of service.
You are solely responsible for how you use this tool.

## What ShyamJS does and does not do

By design, ShyamJS performs **passive, read-only reconnaissance and static
analysis**. It:

- issues `GET`/`HEAD` requests only for discovery;
- never executes downloaded JavaScript;
- never uses, replays, or validates discovered credentials;
- never brute-forces, exploits endpoints, bypasses authentication, or performs
  destructive/state-changing requests;
- redacts detected secrets in console output and reports by default.

A regex or entropy match is reported as a **candidate** with a confidence
score. It is not proof that a value is a live, valid secret.

## Handling of discovered secrets

If ShyamJS surfaces a real secret in an asset you are authorized to test, treat
it as sensitive: report it through the appropriate disclosure channel and do not
store it in plaintext or commit it anywhere. Use `--no-redact` only in a secure,
isolated environment when strictly necessary.

## Reporting a vulnerability in ShyamJS itself

Please open a private security advisory on the repository, or email the
maintainer, rather than filing a public issue. Include reproduction steps and
affected versions.
