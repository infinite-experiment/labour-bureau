## Services Overview

| Service      | Description                                    | Ports  |
|--------------|------------------------------------------------|--------|
| politburo    | Go backend REST API (core business logic)      | 8080   |
| comrade-bot  | Discord bot for user interactions              | N/A    |
| vizburo      | UI/frontend dashboard and admin tools          | 3000   |
| db           | PostgreSQL database                            | 5432   |
| pgadmin      | Web-based Postgres admin tool                  | 5050   |

## Expected Folder Structure

```
infinite-experiment/
  labour-bureau/      # this repo
  politburo/
  comrade-bot/
  vizburo/
```
All repositories should be cloned side-by-side for relative paths to work.

## Bring Up All Services

```
cd labour-bureau
docker compose -f docker-compose.dev.yml up --build
```
This will build and start all services. Logs from all containers will stream to your terminal. Use CTRL+C to stop.

## Bring Up a Single Service

```
docker compose -f docker-compose.dev.yml up --build politburo
docker compose -f docker-compose.dev.yml up --build comrade-bot
docker compose -f docker-compose.dev.yml up --build vizburo
```
You can run multiple terminal windows for different services if you want isolated logs.

## View Logs for a Specific Service

```
docker compose -f docker-compose.dev.yml logs -f politburo
docker compose -f docker-compose.dev.yml logs -f comrade-bot
docker compose -f docker-compose.dev.yml logs -f vizburo
docker compose -f docker-compose.dev.yml logs -f db
```
You can add --tail=100 for the last 100 lines.

## Bring Down All Services and Clean Up

```
docker compose -f docker-compose.dev.yml down
```

Add -v to remove named volumes (including the Postgres DB data):
```
docker compose -f docker-compose.dev.yml down -v
```