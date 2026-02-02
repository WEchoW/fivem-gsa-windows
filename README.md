# FiveM GSA Windows Docker Container

Docker container for running FiveM server with txAdmin on Windows Server Core.

## Features

- Based on Windows Server Core LTSC 2022
- Automatic FiveM artifact download and extraction
- txAdmin web interface support
- Automated builds via GitHub Actions
- Published to GitHub Container Registry

## Quick Start

### Using Docker Compose

```bash
docker-compose up -d
```

### Using Docker CLI

```bash
docker run -d \
  --name fivem \
  -p 30120:30120/tcp \
  -p 30120:30120/udp \
  -p 40120:40120/tcp \
  -e HOME_ROOT="C:\gsa" \
  -e TXADMIN_PORT="40120" \
  -e ARTIFACT_URL="https://runtime.fivem.net/artifacts/fivem/build_server_windows/master/24769-315823736cfbc085104ca0d32779311cd2f1a5a8/server.7z" \
  -v "C:/GameServerApp/containers/nspgwypvh/serverfiles/artifacts:C:/gsa/serverfiles/artifacts" \
  ghcr.io/wechow/fivem-gsa-windows:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `HOME_ROOT` | `C:\gsa` | Root directory for FiveM server files |
| `TXADMIN_PORT` | `40120` | Port for txAdmin web interface |
| `FIVEM_PORT` | `30120` | Port for FiveM game server |
| `ARTIFACT_URL` | Required | URL to FiveM server artifact (7z file) |

## Ports

- `30120/tcp` and `30120/udp` - FiveM game server
- `40120/tcp` - txAdmin web interface

## Accessing txAdmin

After starting the container, access txAdmin at:
```
http://localhost:40120
```

Follow the setup wizard to configure your FiveM server.

## Building Locally

```bash
docker build -t fivem-gsa-windows .
```

## GitHub Actions

This repository uses GitHub Actions to automatically build and push Docker images to GitHub Container Registry on every push to the main branch.

The workflow:
- Builds on Windows Server 2022 runners
- Pushes to `ghcr.io/wechow/fivem-gsa-windows:latest`
- Tags with commit SHA and branch names

## License

This project is provided as-is for FiveM server hosting purposes.

## Credits

Forked from [LegitGammin/fivem-gsa-windows](https://github.com/LegitGammin/fivem-gsa-windows)
