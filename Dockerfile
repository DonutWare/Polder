# syntax=docker/dockerfile:1

# WEB selects what the server serves at its root:
#   none    only the API (default; skips the Flutter build)
#   client  the Flutter web app from client/
#   docker build --build-arg WEB=client .
ARG WEB=none
# The Flutter release the web app is built with; keep it in step with client/.fvmrc.
ARG FLUTTER_VERSION=3.47.5

FROM --platform=$BUILDPLATFORM golang:1.27-alpine AS web-none
RUN mkdir /web

FROM --platform=$BUILDPLATFORM debian:bookworm-slim AS flutter
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*
ARG FLUTTER_VERSION
RUN git clone --depth 1 --branch "${FLUTTER_VERSION}" https://github.com/flutter/flutter.git /flutter
ENV PATH=/flutter/bin:$PATH
RUN flutter config --no-analytics >/dev/null && flutter precache --web
WORKDIR /client
COPY client/pubspec.yaml client/pubspec.lock ./
RUN flutter pub get
COPY client/ .
# CanvasKit is served by Polder itself, so the web client also works on a LAN without internet.
RUN flutter build web --release --no-web-resources-cdn --no-wasm-dry-run \
    && find build/web -name '*.symbols' -delete

FROM --platform=$BUILDPLATFORM golang:1.27-alpine AS web-client
COPY --from=flutter /client/build/web /web

FROM web-${WEB} AS web

FROM --platform=$BUILDPLATFORM golang:1.27-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=web /web/ ./internal/webui/dist/
ARG TARGETOS TARGETARCH TARGETVARIANT
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH GOARM=${TARGETVARIANT#v} go build -trimpath -ldflags="-s -w" -o /out/polder ./cmd/polder \
    && mkdir -p /out/config /out/data

FROM alpine:3.24
RUN apk add --no-cache tesseract-ocr mailcap \
    && adduser -D -H -u 65532 nonroot
COPY --from=build /out/polder /usr/local/bin/polder
COPY --from=build --chown=65532:65532 /out/config /config
COPY --from=build --chown=65532:65532 /out/data /data
ENV POLDER_CONFIG_DIR=/config \
    POLDER_DATA_DIR=/data \
    POLDER_LISTEN=:6060
VOLUME ["/config", "/data"]
EXPOSE 6060
USER nonroot
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD ["/usr/local/bin/polder", "healthcheck"]
ENTRYPOINT ["/usr/local/bin/polder"]
