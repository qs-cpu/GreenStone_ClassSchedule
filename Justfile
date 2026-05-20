# 一键初始化
@init:
  flutter clean
  flutter pub get

# 清理
@clean:
  flutter clean

# 获取依赖
@get:
  flutter pub get

# 分析代码
@analyze:
  flutter analyze

# 格式化
@fmt:
  dart format .

# 升级依赖检查
@outdated:
  flutter pub outdated

# 彻底重建
@rebuild:
  flutter clean
  flutter pub get
  just run

# 查看设备
@devices:
  flutter devices

# Web运行
@run-web:
  flutter run -d web-server

# Android运行
@run-android:
  flutter run -d android

# Android运行（指定后端地址，适合真机或非默认环境）
@run-android-url api_url:
  flutter run -d android --dart-define=API_URL="{{api_url}}"

# 构建 Web
@build-web:
  flutter build web

# 构建 Debug APK
@build-apk-debug:
  flutter build apk --debug

# 构建 APK（保持 Flutter 默认行为，兼容旧流程）
@build-apk:
  flutter build apk

# 构建 Release APK（显式命令）
@build-apk-release:
  flutter build apk --release

# 构建 Release APK（指定后端地址，适合真机或生产环境）
@build-apk-release-url api_url:
  flutter build apk --release --dart-define=API_URL="{{api_url}}"

# 构建默认 APK（兼容旧命令）
@build-apk-default:
  flutter build apk

# 启动数据库
db-start:
  docker start greenstone-db 2>/dev/null || docker run -d --name greenstone-db \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_DB=greenstone \
    -p 5432:5432 \
    -v greenstone-postgres-data:/var/lib/postgresql/data \
    postgres:14

# 停止数据库
db-stop:
  docker stop greenstone-db && docker rm greenstone-db

# 数据库迁移
db-migrate:
  cd app && DATABASE_URL="postgresql://postgres:password@127.0.0.1:5432/greenstone" bun run drizzle-kit push --config drizzle.config.ts

# 数据库 Shell
db-shell:
  docker exec -it greenstone-db psql -U postgres -d greenstone

# 启动 Redis
redis-start:
  docker start greenstone-redis 2>/dev/null || docker run -d --name greenstone-redis \
    -p 6379:6379 \
    -v $(pwd)/app/data/redis:/data \
    redis:6

# 停止 Redis
redis-stop:
  docker stop greenstone-redis && docker rm greenstone-redis

# 一键启动后端
start:
  just db-start
  just redis-start
  cd app && bun run dev
