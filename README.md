# GreenStone ClassSchedule

全栈课程表管理应用 — Flutter + Bun/Elysia + SQLite，支持 Web 和 Android。零配置启动。

## 快速开始

```bash
just init      # 安装依赖（仅首次）
just start     # 一键启动前后端 → http://localhost:45441
```

首次使用：浏览器打开 → 注册 → 登录 → 导入课表。

## 常用命令

```bash
just start       # 一键启动前后端（固定端口 :45441）
just api         # 仅后端 → http://localhost:3001
just web         # 仅前端 → http://localhost:45441
just admin       # 创建管理员账号
just test        # 运行前后端测试
just build-apk   # 构建 Release APK
just build-web   # 构建 Flutter Web
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

单容器运行，自动初始化一切，无需配置环境变量。

## 文档

- [架构总览](docs/structure.md) — 系统架构、目录结构、数据库设计、设计决策
- [API 参考](docs/api.md) — 所有 REST 端点
- [开发指南](docs/dev-guide.md) — 环境搭建、命令速查、Docker 部署
- [用户指南](docs/usage.md) — 登录注册、课程表操作、导入方式
- [测试指南](docs/testing.md) — 17 项测试、覆盖率目标
