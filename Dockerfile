FROM python:3.12-slim

LABEL org.opencontainers.image.title="ShyamJS" \
      org.opencontainers.image.description="JavaScript Security Analyzer for authorized testing" \
      org.opencontainers.image.licenses="MIT"

# lxml needs no system libs on slim wheels; keep image minimal.
WORKDIR /app

COPY pyproject.toml requirements.txt README.md ./
COPY shyamjs ./shyamjs

RUN pip install --no-cache-dir . && \
    adduser --disabled-password --gecos "" shyam
USER shyam

ENTRYPOINT ["shyamjs"]
CMD ["--help"]
