#!/usr/bin/env bash
set -euo pipefail

export POSTGRES_USER="${POSTGRES_USER:-postgres}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-password}"
export POSTGRES_DB="${POSTGRES_DB:-greenstone}"
export PGDATA="${PGDATA:-/data/postgres}"
export REDIS_HOST="${REDIS_HOST:-127.0.0.1}"
export REDIS_PORT="${REDIS_PORT:-6379}"
export PUBLIC_DIR="${PUBLIC_DIR:-/app/public}"
export DATABASE_URL="${DATABASE_URL:-postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@127.0.0.1:5432/${POSTGRES_DB}}"

if [ -z "${JWT_SECRET:-}" ]; then
  jwt_secret_file="/data/jwt_secret"
  if [ ! -s "$jwt_secret_file" ]; then
    od -An -N32 -tx1 /dev/urandom | tr -d ' \n' > "$jwt_secret_file"
    chmod 600 "$jwt_secret_file"
    echo "JWT_SECRET 未设置，已自动生成并保存到 /data/jwt_secret"
  else
    echo "JWT_SECRET 未设置，复用 /data/jwt_secret"
  fi
  export JWT_SECRET="$(cat "$jwt_secret_file")"
fi

mkdir -p "$PGDATA" /data/redis /run/postgresql
chown -R postgres:postgres "$PGDATA" /run/postgresql

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  password_file="$(mktemp)"
  printf '%s' "$POSTGRES_PASSWORD" > "$password_file"
  chown postgres:postgres "$password_file"
  su postgres -c "initdb -D '$PGDATA' --username='$POSTGRES_USER' --pwfile='$password_file'"
  rm -f "$password_file"
fi

su postgres -c "pg_ctl -D '$PGDATA' -o '-c listen_addresses=127.0.0.1' -w start"

if ! su postgres -c "psql -U '$POSTGRES_USER' -tAc \"SELECT 1 FROM pg_database WHERE datname='${POSTGRES_DB}'\"" | grep -q 1; then
  su postgres -c "createdb -U '$POSTGRES_USER' '$POSTGRES_DB'"
fi

redis-server --dir /data/redis --daemonize yes

cd /app
bun run drizzle-kit push --config drizzle.config.ts
bun run src/seed-admin.ts

exec bun run src/index.ts
