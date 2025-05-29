#!/bin/bash

# Load env vars
ENV_FILE=".env"
if [ ! -f "$ENV_FILE" ]; then
  echo "❌ .env file not found!"
  exit 1
fi
source "$ENV_FILE"

# ====== Configuration (centralized) ======
POSTGRES_USER="$PG_USER"
POSTGRES_DB="$PG_DB"
POSTGRES_PASSWORD="$PG_PASSWORD"
DB_CONTAINER_NAME="db"
POLITBURO_CONTAINER_NAME="politburo"
BOT_CONTAINER_NAME="comrade-bot"
DOCKER_COMPOSE_FILE="docker-compose.prod.yml"
API_KEY_GEN_PATH="../politburo/cmd/api_key_gen/main.go"
MIGRATION_SCRIPT_PATH="../politburo/internal/db/migrations"
SQL_FILE="$2"
# ==========================================

# ====== Usage Help ======
function show_help {
  echo ""
  echo "Usage: ./manage.sh <command> [options]"
  echo ""
  echo "Commands:"
  echo "  gen-api-key                     Generate API key"
  echo "  reset-db <sql_path>            Drop & run migrations from given path"
  echo "  migration <sql_path>           Run migrations from given path"
  echo "  deploy-commands                Deploy Discord bot commands"
  echo "  down <service|all>             Stop container(s)"
  echo "  up                             Start containers and show logs"
  echo ""
}
# ========================

# ====== Commands ======

function gen_api_key {
  echo "🔑 Generating API Key..."
  docker compose -f "$DOCKER_COMPOSE_FILE" exec "$POLITBURO_CONTAINER_NAME" go run "$API_KEY_GEN_PATH"
}

function reset_db {
  if [ -z "$SQL_FILE" ]; then
    echo "❌ Please provide path to SQL/migration scripts"
    exit 1
  fi

  echo "💣 Dropping and migrating DB..."
  docker compose -f "$DOCKER_COMPOSE_FILE" exec -T "$DB_CONTAINER_NAME" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
  docker compose -f "$DOCKER_COMPOSE_FILE" exec -T "$DB_CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "/migrations/$"
}

function migrate {
  local sql_path="$1"
  if [ -z "$sql_path" ]; then
    echo "❌ Please provide path to SQL/migration scripts"
    exit 1
  fi

  echo "Running migration..."
  docker compose -f "$DOCKER_COMPOSE_FILE" exec -T "$DB_CONTAINER_NAME" \
    psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f "/migrations/$SQL_FILE"
}

function deploy_commands {
  echo "🚀 Deploying Discord bot commands..."
  docker compose -f "$DOCKER_COMPOSE_FILE" exec "$BOT_CONTAINER_NAME" npm run deploy-commands
}

function down {
  local target="$1"
  if [ -z "$target" ]; then
    echo "❌ Specify a service name or 'all'"
    exit 1
  fi

  if [ "$target" == "all" ]; then
    docker compose -f "$DOCKER_COMPOSE_FILE" down
    docker rm -f caddy 2>/dev/null || true
    echo "🛑 All containers stopped (including caddy if running)"
  else
    docker compose -f "$DOCKER_COMPOSE_FILE" stop "$target"
    echo "🛑 Stopped container: $target"
  fi
}

function up {
  echo "📦 Bringing up the stack..."
  docker compose -f "$DOCKER_COMPOSE_FILE" up -d --build

  echo "📄 Following logs until containers are healthy..."
  docker compose -f "$DOCKER_COMPOSE_FILE" logs -f --tail=20
}

# ====== Main Entrypoint ======

case "$1" in
  gen-api-key)
    gen_api_key
    ;;
  reset-db)
    reset_db "$2"
    ;;
  deploy-commands)
    deploy_commands
    ;;
  down)
    down "$2"
    ;;
  up)
    up
    ;;
  migration)
    migrate "$2"
    ;;
  *)
    show_help
    ;;
esac
