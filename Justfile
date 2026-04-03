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

# 构建 Web
@build-web:
  flutter build web

# 构建 APK
@build-apk:
  flutter build apk

# 构建 release APK
@build-apk-release:
  flutter build apk --release
