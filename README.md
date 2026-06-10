# GreenStone ClassSchedule

全栈课程表管理应用 — Flutter 前端 + Bun/Elysia 后端 + SQLite 数据库，支持 Web 和 Android。

## 快速开始

```bash
# 初始化
just init

# 启动后端
just api        # → http://localhost:3001

# 启动前端（新终端）
just web        # → http://localhost:PORT

# 或两个终端分别跑上面的命令
```

首次使用：浏览器打开前端地址 → 注册 → 登录 → 导入课表。

## 文档

- [架构总览](docs/structure.md) — 系统架构、目录结构、数据库设计、设计决策
- [API 参考](docs/api.md) — 所有 REST 端点、请求/响应格式
- [开发指南](docs/dev-guide.md) — 环境搭建、Justfile 命令、Docker 部署
- [用户指南](docs/usage.md) — 登录注册、课程表操作、导入方式
- [测试指南](docs/testing.md) — 运行测试、覆盖率目标

## 常用命令

```bash
just start       # 一键启动前后端
just api         # 仅后端
just web         # 仅前端
just db-setup    # 数据库迁移 + 创建管理员
just build-apk   # 构建 Release APK
just build-web   # 构建 Flutter Web
flutter test     # 运行前端测试
cd app && bun test  # 运行后端测试
```

## 技术栈

| 层 | 技术 |
|---|---|
| 前端 | Flutter · Riverpod · GoRouter · Dio · Freezed |
| 后端 | Bun · Elysia · TypeScript |
| 数据库 | SQLite (bun:sqlite + Drizzle ORM) |
| 认证 | JWT (jose) + bcryptjs |
| 部署 | Docker (oven/bun:1-slim) |

## Docker 部署

```bash
docker compose up -d --build
# → http://localhost:8080
```

单容器运行，自动初始化数据库，无需配置环境变量。
