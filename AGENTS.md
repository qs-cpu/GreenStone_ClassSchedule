# AGENTS.md

## 项目概述

GreenStone 课程表系统是一个面向学生用户的多端课程表应用，支持课程表导入、课程展示、来源管理与同步刷新。前后端分离架构。

**当前状态**：Flutter 前端骨架阶段（Web + Android），后端未实现。

## 技术栈（当前）

- **前端框架**: Flutter (^3.11.3)
- **语言**: Dart
- **包名**: schedule
- **目标平台**: Web, Android
- **Linter**: flutter_lints

## 项目结构

```
GreenStone_ClassSchedule/
├── .envrc              # direnv 环境变量（Android SDK、Flutter PATH）
├── Justfile            # 任务脚本
├── pubspec.yaml        # Flutter 依赖
├── analysis_options.yaml  # Dart linter 配置
├── lib/
│   └── main.dart      # 应用入口（Flutter 默认模板，需重写）
├── test/
├── android/           # Android 构建配置
├── web/               # Web 构建配置
└── app/               # 后端项目（未实现，权限受限）
```

## 开发者命令

```bash
just init         # flutter clean && flutter pub get
just analyze      # flutter analyze（检查代码问题）
just fmt          # dart format .
just run-web      # flutter run -d web-server
just run-android  # flutter run -d android
just build-apk    # flutter build apk
just build-web    # flutter build web
just devices      # flutter devices
just outdated     # flutter pub outdated
```

## 开发环境要求

- **Android SDK**: 36 / build-tools: 36.0.0
- **Flutter SDK**: ^3.11.3
- **环境管理**: direnv（必须执行 `direnv allow` 加载 .envrc）

## Setup

1. `direnv allow`（进入目录时自动加载环境变量）
2. `just init`（初始化项目）
3. `just analyze`（验证代码无警告/错误）

## 注意事项

- 当前 `lib/main.dart` 是 Flutter 默认模板，存在语法错误（`ColorScheme.fromSeed` 写成 `.fromSeed`），需重写
- 计划中的技术栈（flutter_riverpod、go_router、dio、freezed）尚未添加
- `just run` 命令在 Justfile 中未定义，直接使用 `flutter run` 或指定 `-d web-server`/`-d android`
