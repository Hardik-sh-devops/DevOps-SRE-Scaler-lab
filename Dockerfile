
# Stage 1: Build
FROM python:3.13-alpine AS builder

WORKDIR /build
COPY app/app.py .


# Stage 2: Runtime
FROM python:3.13-alpine AS runtime

RUN apk upgrade --no-cache \
    && python -m pip install --no-cache-dir --upgrade pip

WORKDIR /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder --chown=appuser:appgroup /build/app.py .

USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/', timeout=2)" || exit 1

CMD ["python", "app.py"]
