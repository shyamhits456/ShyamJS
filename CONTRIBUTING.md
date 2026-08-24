# Contributing to ShyamJS

Thanks for your interest in improving ShyamJS.

## Getting set up

```bash
git clone https://github.com/shyam/ShyamJS
cd ShyamJS
python3 -m venv .venv && . .venv/bin/activate
pip install -e ".[dev]"
pytest -q
```

## Adding a detector

Detectors are plugins. To add one:

1. Create a class that subclasses `shyamjs.detectors.base.Detector`.
2. Implement `analyze(self, content, context) -> Iterable[Finding]`.
3. Decorate the class with `@register`.
4. Make sure the module is imported in `shyamjs/js/extractor.py` so it registers.

```python
from shyamjs.detectors.base import Detector, register, AnalysisContext, line_col
from shyamjs.models.findings import Finding, Severity

@register
class MyDetector(Detector):
    name = "my_detector"

    def analyze(self, content, context):
        for m in MY_REGEX.finditer(content):
            line, col = line_col(content, m.start())
            yield Finding(
                type="my_type", severity=Severity.MEDIUM, confidence=70,
                source=context.source, title="My Finding",
                value=m.group(0), raw_value=m.group(0), line=line, column=col,
            )
```

## Adding secret patterns or providers

- New secret regexes go in `shyamjs/secrets/patterns.py` as `SecretPattern`
  entries. Keep them conservative and give provider-prefixed patterns higher
  base confidence.
- New third-party services go in `PROVIDER_DB` in
  `shyamjs/thirdparty/detector.py`.

## Guidelines

- Every new detector or pattern should come with a test and, ideally, a fixture.
- Never commit real credentials. Fixtures must use clearly fake values
  (e.g. `TEST_*_NOT_REAL`).
- Keep the tool passive: no code execution, no exploitation, no credential use.
- Run `pytest -q` before opening a PR.

## Pull requests

Keep PRs focused. Describe the motivation, the change, and how you tested it.
