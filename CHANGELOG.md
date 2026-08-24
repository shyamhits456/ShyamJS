# Changelog

All notable changes to ShyamJS are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/), and this project adheres to
semantic versioning.

## [1.0.0] - 2026-08-24

### Added
- Initial release.
- Safe, scoped, async crawler with depth/page/rate/timeout limits, robots.txt
  and sitemap support, and same-origin scope by default.
- JavaScript discovery from `<script src>`, inline scripts, and in-page string
  references; content-hash deduplication.
- Plugin-style detector architecture with detectors for secrets, API keys,
  JWTs, private keys, cloud credentials, DB connection strings, endpoints,
  URLs, third-party services, source-map references, interesting comments, and
  obfuscation/debug indicators.
- Entropy analysis with placeholder and word heuristics to reduce false
  positives; per-finding confidence scoring (0-100).
- Source-map (`.map`) fetching and `sourcesContent` analysis, with findings
  clearly labeled as source-map origin.
- Optional JS beautification for minified bundles (`--beautify`).
- Console, JSON, CSV, HTML, and TXT reporting. Secrets redacted by default.
- Configurable via `~/.config/shyamjs/config.yaml`; CLI flags override config.
- Meaningful exit codes (0 success, 1 error, 2 invalid target, 3 high/critical
  findings) with `--no-fail` override.
- Dockerfile, docker-compose, GitHub Actions CI, and test suite.
