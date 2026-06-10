#!/usr/bin/env bash
set -euo pipefail

export DATABASE_PATH="${DATABASE_PATH:-/data/greenstone.db}"
export PUBLIC_DIR="${PUBLIC_DIR:-/app/public}"

mkdir -p /data

cd /app
bun run drizzle-kit push --config drizzle.config.ts
bun run src/seed-admin.ts

exec bun run src/index.ts
