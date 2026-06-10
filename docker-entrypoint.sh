#!/usr/bin/env bash
set -euo pipefail

export DATABASE_PATH="${DATABASE_PATH:-/data/greenstone.db}"
export PUBLIC_DIR="${PUBLIC_DIR:-/app/public}"

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

mkdir -p /data

cd /app
bun run drizzle-kit push --config drizzle.config.ts
bun run src/seed-admin.ts

exec bun run src/index.ts
