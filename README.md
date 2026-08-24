```
 _____ _                             ___ _____ 
/  ___| |                           |_  /  ___|
\ `--.| |__  _   _  __ _ _ __ ___     | \ `--. 
 `--. \ '_ \| | | |/ _` | '_ ` _ \    | |`--. \
/\__/ / | | | |_| | (_| | | | | | /\__/ /\__/ /
\____/|_| |_|\__, |\__,_|_| |_| |_\____/\____/ 
              __/ |                            
             |___/                             
```

<div align="center">

# ShyamJS

**JavaScript Security Analyzer — reconnaissance & static analysis for authorized web security testing.**

[![Python](https://img.shields.io/badge/python-3.9%2B-blue)](https://www.python.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-43%20passing-brightgreen)](tests/)
[![Status](https://img.shields.io/badge/status-beta-orange)](#)

</div>

---

> ⚠️ **Authorized use only.** ShyamJS is for security testing of assets you own or are explicitly permitted to assess. It performs **passive, read-only** reconnaissance and static analysis — it never executes JavaScript, never uses discovered credentials, and never exploits or attacks a target. See [SECURITY.md](SECURITY.md).

## Table of contents

- [What it does](#what-it-does)
- [Installation](#installation)
- [Usage](#usage)
- [CLI options](#cli-options)
- [Reports](#reports)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Docker](#docker)
- [Development](#development)
- [Exit codes](#exit-codes)
- [Limitations](#limitations)
- [Responsible use](#responsible-use)
- [License](#license)

## What it does

ShyamJS crawls a target within scope, discovers and downloads its JavaScript, and statically analyzes both JS and HTML to surface things developers often leak into the front-end:

- **Secrets** — API keys, access/bearer tokens, JWTs, OAuth tokens, client secrets, private keys, cloud credentials, database connection strings, webhook secrets, and hardcoded passwords/usernames.
- **Endpoints** — API paths pulled from `fetch`, `axios`, `XMLHttpRequest`, and bare path literals, with HTTP method where identifiable and sensitivity flagging (`/admin`, `/internal`, `/auth`, …).
- **URLs** — absolute URLs classified as same-origin, subdomain, or third-party.
- **Third-party services** — Analytics, Sentry, Stripe, Auth0, AWS, Cloudflare and many more, via an extensible provider database.
- **Source maps** — fetches `.map` files and analyzes embedded `sourcesContent`, clearly labeling findings that originate from source maps.
- **Interesting comments & debug artifacts** — `TODO`/`FIXME`/`SECRET`, `eval`, `atob`, hex string arrays, and other static indicators.

Every finding carries a **type, severity, confidence score (0–100), source, line, and fingerprint**. Secrets are **redacted by default** everywhere — in console output *and* in reports, including when they appear in the context of a neighbouring finding.

## Installation

Requires **Python 3.9+**.

### Kali Linux / pipx (recommended)

```bash
git clone https://github.com/shyamhits456/ShyamJS
cd ShyamJS
pipx install .
shyamjs --help
```

### Virtual environment

```bash
git clone https://github.com/shyamhits456/ShyamJS
cd ShyamJS
python3 -m venv .venv
source .venv/bin/activate
pip install .
shyamjs --help
```

### Run without installing

```bash
pip install -r requirements.txt
python3 -m shyamjs https://example.com
```

## Usage

```bash
# Basic scan
shyamjs https://example.com

# Control crawl depth
shyamjs -u https://example.com --depth 3

# Deeper, more thorough crawl
shyamjs -u https://example.com --deep

# Analyze external JS only
shyamjs -u https://example.com --js-only

# Write full reports to a folder
shyamjs -u https://example.com --output results/

# Machine-readable JSON to stdout
shyamjs -u https://example.com --json

# Analyze only the target page/JS, no crawling
shyamjs -u https://example.com --no-crawl

# Route through a proxy (e.g. Burp Suite)
shyamjs -u https://example.com --proxy http://127.0.0.1:8080

# Include subdomains in scope
shyamjs -u https://example.com --include-subdomains
```

### Example run

```
[+] Target: https://example.com

[1/5] Crawling target...
[2/5] Discovering JavaScript...
[+] 2 JavaScript files discovered
[3/5] Analyzing JavaScript...
[+] 6 endpoints discovered
[+] 4 URLs discovered
[+] 4 third-party domains discovered
[4/5] Detecting sensitive information...
[+] 23 potential findings

[5/5] Generating reports...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                     FINDINGS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[CRITICAL] Stripe Live Secret Key
File       : https://example.com/assets/main.js
Line       : 6
Confidence : 90%
Context    : stripeKey: "sk_l****************", ...

[HIGH] Generic API Key Assignment
File       : https://example.com/main.js.map :: src/config/environment.ts
Line       : 2
Confidence : 75%
Origin     : [SOURCE MAP]
Context    : apiKey: 'AIza****************', ...

[MEDIUM] Sensitive Endpoint
Endpoint   : /api/admin/users
Method     : POST
Source     : https://example.com/assets/app.js
Confidence : 85%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                   SCAN SUMMARY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pages              : 1
JavaScript Files   : 2
Endpoints          : 6
URLs               : 4
Third Parties      : 4

Critical           : 1
High               : 6
Medium             : 3
Low                : 8
Info               : 4
```

## CLI options

| Option | Description |
| --- | --- |
| `target` / `-u, --url` | Target URL to scan. |
| `--depth N` | Maximum crawl depth. |
| `--max-pages N` | Maximum pages to crawl. |
| `--rate-limit R` | Maximum requests per second. |
| `--timeout S` | Per-request timeout (seconds). |
| `--concurrency N` | Maximum concurrent requests. |
| `--include-subdomains` | Allow crawling subdomains of the target. |
| `--js-only` | Analyze external JS only (skip inline scripts). |
| `--deep` | More thorough crawl (raises depth). |
| `--no-crawl` | Analyze only the target page/JS, no crawling. |
| `--beautify` | Beautify minified JS before analysis. |
| `--no-source-maps` | Do not fetch/analyze source maps. |
| `--no-entropy` | Disable entropy-based detection. |
| `--min-confidence N` | Drop findings below this confidence. |
| `--proxy URL` | Route traffic through an HTTP proxy (e.g. Burp). |
| `--insecure` | Disable TLS certificate verification. |
| `-o, --output DIR` | Write HTML/JSON/CSV/TXT reports to a directory. |
| `--json` | Print a JSON report to stdout. |
| `--no-color` | Disable colored output (auto-disabled when piped). |
| `--no-redact` | Do **not** redact secrets (use only in a secure environment). |
| `--no-fail` | Always exit 0 regardless of findings. |
| `--config FILE` | Path to a YAML config file. |
| `-v/--verbose`, `--debug`, `-q/--quiet` | Logging verbosity. |
| `--version`, `-h/--help` | Version / help. |

## Reports

`-o results/` writes:

```
results/
├── report.html        # summary, stats, severity distribution, all sections
├── report.json        # machine-readable, schema below
├── endpoints.csv
├── secrets.csv
├── third-party.csv
└── crawl.txt
```

### JSON schema (excerpt)

```json
{
  "target": "https://example.com",
  "scan_time": "2026-08-24T00:00:00Z",
  "statistics": {
    "pages": 42, "javascript_files": 27, "endpoints": 83,
    "third_party_domains": 18, "findings": 7
  },
  "findings": [
    {
      "type": "potential_api_key",
      "severity": "HIGH",
      "confidence": 94,
      "source": "/assets/main.js",
      "line": 842,
      "value": "sk_l****************",
      "fingerprint": "a97130109f93e301"
    }
  ]
}
```

## Configuration

ShyamJS reads `~/.config/shyamjs/config.yaml` if present. CLI flags always override config-file values. See [`examples/config.yaml`](examples/config.yaml).

```yaml
crawler:
  max_depth: 3
  max_pages: 500
  concurrency: 10
  timeout: 10
  rate_limit: 5
scanner:
  entropy_detection: true
  source_maps: true
  beautify: false
output:
  redact_secrets: true
```

## Architecture

```
shyamjs/
├── cli.py             # argument parsing, phases, exit codes
├── banner.py          # ASCII banner
├── config.py          # defaults + YAML config
├── engine.py          # orchestrates crawl → download → analyze → report
├── crawler/           # crawler, robots.txt, sitemap, link extraction
├── js/                # downloader, HTML/JS parser, beautifier, source maps
├── secrets/           # patterns, entropy, secret detector
├── endpoints/         # endpoint + URL extraction and normalization
├── thirdparty/        # provider database + detector
├── detectors/         # plugin base + comment/debug/sourcemap detectors
├── models/            # Finding / ScanResult data models + redaction
├── reporting/         # console, JSON, CSV, HTML, TXT
└── utils/             # URLs, HTTP client, hashing, logging
```

Detectors are plugins: subclass `Detector`, implement `analyze`, decorate with `@register`. See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Docker

```bash
docker build -t shyamjs .
docker run --rm -v "$PWD/results:/data" shyamjs -u https://example.com -o /data
```

## Development

```bash
pip install -e ".[dev]"
pytest -q
```

## Exit codes

| Code | Meaning |
| --- | --- |
| `0` | Scan completed successfully (no high/critical findings). |
| `1` | Runtime / configuration error. |
| `2` | Invalid target. |
| `3` | Scan completed **with high/critical findings**. |

Use `--no-fail` to always return `0` (useful when you don't want findings to fail a CI job).

## Limitations

- Detection is heuristic. A match is a **candidate**, not proof of a live secret; always verify manually.
- Static analysis only — dynamic/runtime-constructed URLs and secrets injected at runtime may be missed.
- It does not (and will not) validate, use, or exploit anything it finds.

## Responsible use

Only scan systems you are authorized to test. Unauthorized scanning may be illegal. You are responsible for your use of this tool. See [SECURITY.md](SECURITY.md).

## License

MIT © 2026 Shyam. See [LICENSE](LICENSE).
