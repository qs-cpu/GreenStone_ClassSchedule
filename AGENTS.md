# AGENTS.md

## 项目概述

GreenStone 课程表系统是一个面向学生用户的多端课程表应用，支持课程表导入、课程展示、来源管理与同步刷新。前后端分离架构，当前仅实现 Flutter 前端（Web + Android）。

## 技术栈

- **前端框架**: Flutter (^3.11.3)
- **语言**: Dart
- **目标平台**: Web, Android
- **包名**: schedule

### 预计技术栈（设计文档）

- 状态管理: flutter_riverpod
- 路由: go_router
- 网络: dio
- 数据模型: freezed + json_serializable
- 后端(未实现): Bun + Elysia + Drizzle ORM + PostgreSQL + Redis

## 项目结构

```
GreenStone_ClassSchedule/
├── .envrc              # direnv 环境变量配置
├── Justfile            # just 任务脚本
├── pubspec.yaml        # Flutter 依赖配置
├── analysis_options.yaml  # Dart linter 配置
├── README.md           # 项目说明
├── design.md          # 系统设计文档
├── lib/
│   └── main.dart      # 应用入口（当前仅有此文件）
├── test/
├── android/           # Android 构建配置
├── web/              # Web 构建配置
└── app/              # 后端项目
    ├── src/
    │   ├── index.ts
    │   ├── routes/
    │   ├── services/
    │   ├── parsers/
    │   ├── db/
    │   └── utils/
    ├── drizzle.config.ts
    └── package.json
```

## 核心目录

| 目录 | 用途 |
|------|------|
| `lib/` | 源代码 |
| `lib/app/` | 路由、主题（规划） |
| `lib/core/` | 网络、常量、工具、基础组件（规划） |
| `lib/features/` | 功能模块：auth, import, timetable, source, settings（规划） |

## 命令

### 前端命令

| 任务 | 命令 |
|------|------|
| 初始化 | `just init` |
| 分析代码 | `just analyze` 或 `flutter analyze` |
| 格式化 | `just fmt` 或 `dart format .` |
| 运行 Web | `just run-web` |
| 运行 Android | `just run-android` |
| 构建 APK | `just build-apk` |
| 构建 Web | `just build-web` |

### 后端命令

| 任务 | 命令 |
|------|------|
| 初始化后端 | `cd app && bun install` |
| 运行后端 | `cd app && bun run src/index.ts` |
| 数据库迁移 | `cd app && bunx drizzle-kit push` |


## 开发环境

- **Android SDK**: 36 / build-tools: 36.0.0
- **Flutter SDK**: ^3.11.3
- **Lints**: flutter_lints
- **环境管理**: direnv

## Setup

1. **启用 direnv**: `direnv allow`（加载 .envrc 中的环境变量）
2. **初始化**: `just init`（执行 flutter clean && flutter pub get）