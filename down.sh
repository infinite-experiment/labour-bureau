#!/bin/bash
set -e

# Usage: ./down.sh [--with-caddy]
WITH_CADDY=false

if [[ "$1" == "--with-caddy" ]]; then
  WITH_CADDY=true
fi

echo "Bringing down application stack..."
docker compose -f docker-compose.prod.yml down

if $WITH_CADDY; then
  echo "Bringing down Caddy..."
  docker stop caddy || echo "Caddy was not running"
  docker rm caddy || echo "Caddy container already removed"
else
  echo "Skipping Caddy shutdown. Pass '--with-caddy' to stop and remove Caddy."
fi

echo "Shutdown complete."
