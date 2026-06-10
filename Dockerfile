# 构建 Flutter Web，API 使用同源相对路径 /api。
FROM ghcr.io/cirruslabs/flutter:stable AS web-builder
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --dart-define=API_URL=

# 安装 Bun 后端依赖。
FROM oven/bun:1 AS api-builder
WORKDIR /src/app
COPY app/package.json app/bun.lock ./
RUN bun install
COPY app ./

# 运行时 — 单容器 Bun + SQLite。
FROM oven/bun:1-slim

ENV PUBLIC_DIR=/app/public
ENV DATABASE_PATH=/data/greenstone.db

RUN mkdir -p /data

COPY --from=api-builder /src/app /app
COPY --from=web-builder /src/build/web /app/public
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint-greenstone

RUN chmod +x /usr/local/bin/docker-entrypoint-greenstone

EXPOSE 3001

ENTRYPOINT ["docker-entrypoint-greenstone"]
