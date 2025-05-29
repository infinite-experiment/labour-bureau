#!/bin/bash
set -e

echo "Bringing up application stack..."
docker compose -f docker-compose.prod.yml up -d --build --remove-orphans

echo "Waiting for containers to become healthy..."

# Optional: Wait loop if your containers have health checks
for i in {1..10}; do
  echo "Checking container statuses..."
  unhealthy=$(docker ps --filter "health=unhealthy" --format '{{.Names}}')
  if [[ -z "$unhealthy" ]]; then
    break
  fi
  echo "Unhealthy containers detected: $unhealthy"
  sleep 5
done

echo "Showing logs (press Ctrl+C to detach)..."
docker compose -f docker-compose.prod.yml logs -f
