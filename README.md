# Caddy with NaiveProxy

Caddy server compiled with [NaiveProxy forwardproxy plugin](https://github.com/klzgrad/forwardproxy).

[![Build Caddy with NaiveProxy](https://github.com/yv-code/caddy-naive-build/actions/workflows/build.yml/badge.svg)](https://github.com/yv-code/caddy-naive-build/actions/workflows/build.yml)

## Features

- ✅ Latest Caddy version by default when triggering a build
- ✅ NaiveProxy forwardproxy plugin
- ✅ Manual builds via GitHub Actions
- ✅ Multi-architecture support (x64, arm64)
- ✅ Distributed as both standalone binaries and OCI images on GHCR
- ✅ SHA256 checksums for verification

## Download

Two distribution channels are available:

- **Binary**: latest release on [Releases](https://github.com/yv-code/caddy-naive-build/releases/latest)
- **Docker image**: `ghcr.io/yv-code/caddy-naive-build:latest` (also tagged with the upstream Caddy version, e.g. `v2.10.0`)

### Supported Platforms

- Linux x64
- Linux arm64

## Docker

Multi-arch images are published to GitHub Container Registry on every successful build.

```bash
# Pull the latest image
docker pull ghcr.io/yv-code/caddy-naive-build:latest

# Or pin to a specific Caddy version
docker pull ghcr.io/yv-code/caddy-naive-build:v2.10.0

# Verify the forwardproxy plugin is included
docker run --rm ghcr.io/yv-code/caddy-naive-build:latest \
    caddy list-modules | grep forward_proxy
```

### Run with your own Caddyfile

```bash
docker run -d \
    --name caddy \
    -p 80:80 -p 443:443 -p 443:443/udp \
    -v $PWD/Caddyfile:/etc/caddy/Caddyfile:ro \
    -v caddy_data:/data \
    -v caddy_config:/config \
    ghcr.io/yv-code/caddy-naive-build:latest
```

The image follows the same volume layout as the official `caddy` image:

| Path           | Purpose                                |
|----------------|----------------------------------------|
| `/etc/caddy`   | Caddyfile / JSON config                |
| `/data`        | Auto-managed TLS certificates & state  |
| `/config`      | Caddy admin / autosaved JSON           |
| `/srv`         | Default site root (`WORKDIR`)          |

### docker-compose

```yaml
services:
  caddy:
    image: ghcr.io/yv-code/caddy-naive-build:latest
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile:ro
      - caddy_data:/data
      - caddy_config:/config

volumes:
  caddy_data:
  caddy_config:
```

## Quick Start

### Download and Install

```bash
# Download latest version (x64)
wget https://github.com/yv-code/caddy-naive-build/releases/latest/download/caddy-linux-amd64

# Rename and make executable
mv caddy-linux-amd64 caddy
chmod +x caddy

# Verify version
./caddy version

# Verify NaiveProxy module
./caddy list-modules | grep forward_proxy
```

### Basic Usage

```bash
# Run with Caddyfile
./caddy run --config Caddyfile

# Start as daemon
./caddy start --config Caddyfile

# Reload configuration
./caddy reload --config Caddyfile
```

## Example Caddyfile

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
        root /var/www/html
    }
}
```

## Build from Source

This repository uses a manually triggered GitHub Actions workflow to build Caddy with the NaiveProxy plugin.

### Manual Build

```bash
# Install xcaddy
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# Build Caddy with NaiveProxy
xcaddy build --with github.com/caddyserver/forwardproxy=github.com/klzgrad/forwardproxy@naive

# Verify build
./caddy version
./caddy list-modules | grep forward_proxy
```

## Triggering a Build

Builds are **manual only** — open the [Actions tab](../../actions/workflows/build.yml) and click **Run workflow**.

The workflow exposes the following inputs (all optional):

| Input | Default | Purpose |
|-------|---------|---------|
| `caddy_version` | *empty → latest GitHub release* | Caddy version to build, e.g. `v2.10.0` |
| `forwardproxy_repo` | `github.com/klzgrad/forwardproxy` | Go import path of the forwardproxy module replacement |
| `forwardproxy_version` | `naive` | Branch / tag / commit of that module |

The same inputs drive both the standalone binary release and the multi-arch GHCR image, so a single dispatch always produces a consistent pair.

## Verification

Each release includes SHA256 checksums. Verify your download:

```bash
# Download checksum file
wget https://github.com/yv-code/caddy-naive-build/releases/latest/download/checksums.txt

# Verify
sha256sum -c checksums.txt --ignore-missing
```

## Related Projects

- [Caddy](https://github.com/caddyserver/caddy) - Fast and extensible multi-platform HTTP/1-2-3 web server
- [NaiveProxy](https://github.com/klzgrad/naiveproxy) - Make a fortune quietly
- [forwardproxy (naive fork)](https://github.com/klzgrad/forwardproxy) - Forward proxy plugin for Caddy

## License

This project follows the same license as Caddy (Apache 2.0).

## Disclaimer

This is an unofficial build. For official Caddy builds, visit [caddyserver.com](https://caddyserver.com/).
