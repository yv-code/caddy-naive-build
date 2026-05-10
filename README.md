# Caddy Forwardproxy Docker Images

Multi-arch Caddy Docker images published to GitHub Container Registry, in two forwardproxy variants: upstream [`caddyserver/forwardproxy`](https://github.com/caddyserver/forwardproxy) and the [NaiveProxy fork](https://github.com/klzgrad/forwardproxy).

[![Build Caddy Docker images](https://github.com/yv-code/caddy-naive-build/actions/workflows/build.yml/badge.svg)](https://github.com/yv-code/caddy-naive-build/actions/workflows/build.yml)

## Image variants

Both variants are built from the same [Dockerfile](Dockerfile) in a single workflow run.

| Variant | Tags                                          | Contents                                                       |
|---------|-----------------------------------------------|----------------------------------------------------------------|
| plain   | `latest`, `<caddy_version>` (e.g. `v2.10.0`)  | Caddy + upstream `github.com/caddyserver/forwardproxy`         |
| naive   | `latest-naive`, `<caddy_version>-naive`       | Caddy + `github.com/caddyserver/forwardproxy` (NaiveProxy fork)|

```bash
# Caddy with upstream forwardproxy
docker pull ghcr.io/yv-code/caddy-naive-build:latest

# Caddy with NaiveProxy forwardproxy
docker pull ghcr.io/yv-code/caddy-naive-build:latest-naive

# Pin to a specific Caddy version
docker pull ghcr.io/yv-code/caddy-naive-build:v2.10.0
docker pull ghcr.io/yv-code/caddy-naive-build:v2.10.0-naive

# Verify the forwardproxy plugin is included
docker run --rm ghcr.io/yv-code/caddy-naive-build:latest \
    caddy list-modules | grep forward_proxy
docker run --rm ghcr.io/yv-code/caddy-naive-build:latest-naive \
    caddy list-modules | grep forward_proxy
```

### Supported platforms

- `linux/amd64`
- `linux/arm64`

## Running

The image follows the same volume layout as the official `caddy` image:

| Path           | Purpose                                |
|----------------|----------------------------------------|
| `/etc/caddy`   | Caddyfile / JSON config                |
| `/srv`         | Default site root (`WORKDIR`)          |
| `/data`        | Auto-managed TLS certificates & state  |
| `/config`      | Caddy admin / autosaved JSON           |

### Run with your own Caddyfile

```bash
docker run -d \
    --name caddy \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v $PWD/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v $PWD/site:/srv:ro \
    -v caddy_data:/data \
    -v caddy_config:/config \
    ghcr.io/yv-code/caddy-naive-build:latest
```

### docker-compose

```yaml
services:
  caddy:
    image: ghcr.io/yv-code/caddy-naive-build:latest-naive
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - ./site:/srv:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

## Example Caddyfile (naive variant)

```caddyfile
{
    order forward_proxy before file_server
}

:443, example.com {
    tls me@example.com

    forward_proxy {
        basic_auth user pass
        hide_ip
        hide_via
        probe_resistance
    }

    file_server {
        root /srv
    }
}
```

## Triggering a Build

Builds are **manual only** — open the [Actions tab](../../actions/workflows/build.yml) and click **Run workflow**. Both `plain` and `naive` variants are produced in a single dispatch.

The workflow exposes the following inputs (all optional):

| Input                  | Default                                | Purpose                                                                        |
|------------------------|----------------------------------------|--------------------------------------------------------------------------------|
| `caddy_version`        | *empty → latest GitHub release*        | Caddy version to build, e.g. `v2.10.0`                                         |
| `forwardproxy_repo`    | `github.com/klzgrad/forwardproxy`      | Naive variant replacement repo for `github.com/caddyserver/forwardproxy`       |
| `forwardproxy_version` | `naive`                                | Branch / tag / commit of the naive variant replacement                         |

The `plain` variant always uses upstream `github.com/caddyserver/forwardproxy`.

## Building locally

```bash
# Upstream forwardproxy
docker build -t caddy-local .

# NaiveProxy forwardproxy fork
docker build -t caddy-local:naive \
    --build-arg FORWARDPROXY_REPLACEMENT=github.com/klzgrad/forwardproxy \
    --build-arg FORWARDPROXY_VERSION=naive \
    .

# Pin Caddy version
docker build -t caddy-local:v2.10.0 \
    --build-arg CADDY_VERSION=v2.10.0 \
    .
```

## Related Projects

- [Caddy](https://github.com/caddyserver/caddy) - Fast and extensible multi-platform HTTP/1-2-3 web server
- [NaiveProxy](https://github.com/klzgrad/naiveproxy) - Make a fortune quietly
- [forwardproxy (naive fork)](https://github.com/klzgrad/forwardproxy) - Forward proxy plugin for Caddy

## License

This project follows the same license as Caddy (Apache 2.0).

## Disclaimer

This is an unofficial build. For official Caddy builds, see [caddyserver.com](https://caddyserver.com/) or the official [`caddy`](https://hub.docker.com/_/caddy) image on Docker Hub.
