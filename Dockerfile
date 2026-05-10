ARG GO_VERSION=1.25
ARG ALPINE_VERSION=3.20

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine AS builder

ARG TARGETOS
ARG TARGETARCH
ARG CADDY_VERSION
ARG FORWARDPROXY_REPO=github.com/klzgrad/forwardproxy
ARG FORWARDPROXY_VERSION=naive

RUN apk add --no-cache git ca-certificates \
    && go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

WORKDIR /build

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} CGO_ENABLED=0 \
    xcaddy build ${CADDY_VERSION} \
        --with github.com/caddyserver/forwardproxy=${FORWARDPROXY_REPO}@${FORWARDPROXY_VERSION} \
        --output /build/caddy

FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache ca-certificates tzdata mailcap libcap \
    && mkdir -p /config/caddy /data/caddy /etc/caddy /srv

COPY --from=builder /build/caddy /usr/bin/caddy

RUN setcap cap_net_bind_service=+ep /usr/bin/caddy \
    && /usr/bin/caddy version \
    && /usr/bin/caddy list-modules | grep forward_proxy

COPY Caddyfile /etc/caddy/Caddyfile

ENV XDG_CONFIG_HOME=/config \
    XDG_DATA_HOME=/data

EXPOSE 80 443 443/udp 2019

WORKDIR /srv

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
