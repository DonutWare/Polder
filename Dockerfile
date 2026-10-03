# syntax=docker/dockerfile:1

# WEB selects what the server serves at its root:
#   none    only the API (default; skips the Flutter build)
#   client  the Flutter web app from client/
#   docker build --build-arg WEB=client .
ARG WEB=none
# The Flutter release the web app is built with; keep it in step with the client.
ARG FLUTTER_VERSION=3.47.5

FROM golang:1.27-alpine AS web-none
RUN mkdir /web

FROM debian:bookworm-slim AS flutter
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
# CanvasKit is served by Nomad itself, so the web client also works on a LAN without internet.
RUN flutter build web --release --no-web-resources-cdn --no-wasm-dry-run \
    && find build/web -name '*.symbols' -delete

FROM golang:1.27-alpine AS web-client
COPY --from=flutter /client/build/web /web

FROM web-${WEB} AS web

FROM golang:1.27-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=web /web/ ./internal/webui/dist/
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/nomad ./cmd/nomad \
    && mkdir -p /out/config /out/data

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /out/nomad /usr/local/bin/nomad
COPY --from=build --chown=65532:65532 /out/config /config
COPY --from=build --chown=65532:65532 /out/data /data
ENV NOMAD_CONFIG_DIR=/config \
    NOMAD_DATA_DIR=/data \
    NOMAD_LISTEN=:6060
VOLUME ["/config", "/data"]
EXPOSE 6060
USER nonroot
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD ["/usr/local/bin/nomad", "healthcheck"]
ENTRYPOINT ["/usr/local/bin/nomad"]
