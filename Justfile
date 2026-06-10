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

# 数据库迁移
@db-migrate:
  cd app && DATABASE_PATH="data/greenstone.db" bun run drizzle-kit push --config drizzle.config.ts

# 创建管理员账号（如已存在则跳过）
@db-seed-admin:
  cd app && DATABASE_PATH="data/greenstone.db" bun run src/seed-admin.ts

# 数据库迁移并创建管理员
@db-setup: db-migrate db-seed-admin
  echo "数据库迁移和管理员创建完成"

# 一键启动后端
@start:
  cd app && bun run dev

# 完整部署（迁移 + 创建管理员 + 启动后端）
@deploy: db-setup
  cd app && bun run dev
