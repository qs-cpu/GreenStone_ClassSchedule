# ── 环境 ──────────────────────────────────────
@init:
  flutter clean
  flutter pub get
  cd app && bun install

@clean:
  flutter clean

@get:
  flutter pub get

# ── 开发 ──────────────────────────────────────
# 一键启动前后端（并发）
@start:
  #!/usr/bin/env bash
  set -m
  cd app && bun run dev &
  flutter run -d web-server &
  fg %1

# 仅前端
@web:
  flutter run -d web-server

# 仅后端
@api:
  cd app && bun run dev

# 首次部署（迁移 + 种子管理员 + 启动）
@deploy: db-setup
  #!/usr/bin/env bash
  set -m
  cd app && bun run dev &
  flutter run -d web-server &
  fg %1

# ── 构建 ──────────────────────────────────────
@build-web:
  flutter build web

@build-apk-debug:
  flutter build apk --debug

@build-apk:
  flutter build apk --release

@build-apk-url api_url:
  flutter build apk --release --dart-define=API_URL="{{api_url}}"

# ── 数据库 ────────────────────────────────────
@db-migrate:
  cd app && bun run drizzle-kit push --config drizzle.config.ts

@db-seed-admin:
  cd app && bun run src/seed-admin.ts

@db-setup: db-migrate db-seed-admin
  echo "数据库迁移和管理员创建完成"

# ── 工具 ──────────────────────────────────────
@analyze:
  flutter analyze

@fmt:
  dart format .

@outdated:
  flutter pub outdated

@devices:
  flutter devices

# ── Android 真机 ──────────────────────────────
@android:
  flutter run -d android

@android-url api_url:
  flutter run -d android --dart-define=API_URL="{{api_url}}"
