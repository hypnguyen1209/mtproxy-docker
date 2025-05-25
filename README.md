# MTProxy Docker Setup

This repository contains the Docker Compose configuration for running MTProxy for Telegram, based on the [GetPageSpeed/MTProxy](https://github.com/GetPageSpeed/MTProxy) repository. The Dockerfile is defined inline within the docker-compose.yml file.

## Getting Started

### Prerequisites

- Docker and Docker Compose installed on your system
- Port 443 available on your server
- Internet connection to build the image

### Installation

1. Clone this repository:
```bash
git clone https://github.com/hypnguyen1209/mtproxy-docker.git
cd mtproxy-docker
```

2. Create the config directory:
```bash
mkdir -p config
```

3. Start the MTProxy service:
```bash
docker-compose up -d
```

### Configuration

You can configure the MTProxy by setting environment variables:

- `SECRET`: Your proxy secret (will be generated automatically if not provided)
- `TAG`: Proxy tag for channel promotion (optional)
- `WORKERS`: Number of workers (default: 1)
- `SOCKS5_PROXY`: SOCKS5 proxy to route traffic through (format: `server:port` or `server:port:user:password`)

Examples:
```bash
# Set a promotion TAG
TAG=1234567890abcdef docker-compose up -d

# Run through a SOCKS5 proxy
SOCKS5_PROXY=192.168.1.1:1080 docker-compose up -d

# Run through a SOCKS5 proxy with authentication
SOCKS5_PROXY=192.168.1.1:1080:username:password docker-compose up -d
```

### View Proxy Secret

To view your proxy secret (needed to connect to the proxy from Telegram):

```bash
docker-compose exec mtproxy cat /data/secret
```

### View Proxy Stats

To view proxy statistics:

```bash
curl http://localhost:8888/stats
```

### Connecting to the Proxy

Once the proxy is running, you can create a connection link:

1. Get your server's public IP address
2. Get your proxy secret (see above)
3. Create a link in the format:
   ```
   tg://proxy?server=YOUR_IP&port=443&secret=YOUR_SECRET
   ```
   
   Or with dd prefix for random padding:
   ```
   tg://proxy?server=YOUR_IP&port=443&secret=dd${YOUR_SECRET}
   ```

## Updating

To update the proxy to the latest version:

```bash
docker-compose pull
docker-compose up -d
```

## Stopping the Proxy

```bash
docker-compose down
```
