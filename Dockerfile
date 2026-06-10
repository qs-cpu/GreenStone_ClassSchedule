# 构建 Flutter Web，API 使用同源相对路径 /api。
FROM ghcr.io/cirruslabs/flutter:stable AS web-builder
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN flutter build web --release --dart-define=SAME_ORIGIN_API=true \
  && rm -rf build/web/canvaskit/chromium \
  && rm -rf build/web/canvaskit/skwasm_heavy.* \
  && find build/web -name '*.map' -delete

# 安装 Bun 后端依赖，然后删掉 devDeps。
FROM oven/bun:1 AS api-builder
WORKDIR /src/app
COPY app/package.json ./
RUN bun install --no-save \
  && rm -rf node_modules/drizzle-kit node_modules/bun-types \
  && rm -rf /root/.bun/install/cache
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
