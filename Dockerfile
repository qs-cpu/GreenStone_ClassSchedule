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

# 单容器运行 PostgreSQL、Redis、Bun/Elysia。
FROM postgres:14

ENV POSTGRES_DB=greenstone
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=password
ENV PGDATA=/data/postgres
ENV REDIS_HOST=127.0.0.1
ENV REDIS_PORT=6379
ENV PUBLIC_DIR=/app/public

RUN apt-get update \
  && apt-get install -y --no-install-recommends redis-server ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY --from=oven/bun:1 /usr/local/bin/bun /usr/local/bin/bun
COPY --from=api-builder /src/app /app
COPY --from=web-builder /src/build/web /app/public
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint-greenstone

RUN chmod +x /usr/local/bin/docker-entrypoint-greenstone

EXPOSE 3001

ENTRYPOINT ["docker-entrypoint-greenstone"]
