# 开发指南

## 环境要求

- **Flutter SDK** 3.11+ （`~/flutter/bin/flutter`）
- **Bun** 1.x （`curl -fsSL https://bun.sh/install | bash`）
- **Java** 17 （仅 Android 构建）
- **Android SDK** （仅 Android 构建：commandlinetools + platform 36 + build-tools 36）
- **just** （命令运行器）

本地开发不需要 Docker —— SQLite 内置在 Bun 中，零配置。

## 快速开始

```bash
git clone <repo> && cd GreenStone_ClassSchedule
just init         # 安装 Flutter + Bun 依赖
just start        # 一键启动前后端 → http://localhost:45441
```

首次使用：浏览器打开 → 注册 → 登录 → 导入课表。

---

## 日常开发

```bash
just start         # 一键启动前后端 → http://localhost:45441
just web           # 仅前端 → http://localhost:45441
just api           # 仅后端 → http://localhost:3001

just test          # 前后端测试 (17 项)
just analyze       # flutter analyze
just fmt           # dart format .
```

## Justfile 命令

| 命令 | 说明 |
|------|------|
| `just init` | flutter clean + pub get + bun install |
| `just start` | 启动前后端 (后端 :3001, 前端 :45441) |
| `just web` | 仅 Flutter Web (:45441) |
| `just api` | 仅 Bun 后端 (:3001) |
| `just admin` | 创建管理员账号 |
| `just test` | flutter test + bun test |
| `just build-web` | 构建 Flutter Web |
| `just build-apk` | 构建 Release APK |
| `just build-apk-url <url>` | 指定后端地址构建 APK |
| `just analyze` | flutter analyze |
| `just fmt` | dart format . |

---

## 构建 Release APK

```bash
cd android
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias greenstone
```

复制 `android/key.properties.example` → `android/key.properties`：

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=greenstone
storeFile=../release-key.jks
```

```bash
just build-apk                            # 默认后端地址
just build-apk-url https://api.example.com  # 指定生产环境后端
```

---

## Docker 部署

```bash
docker compose up -d --build
# → http://localhost:8080
```

不需要 `.env`。JWT_SECRET 自动生成，数据库自动创建。单容器，一个 .db 文件。

```
Stage 1: cirruslabs/flutter:stable   → flutter build web
Stage 2: oven/bun:1                  → bun install 后端依赖
Stage 3: oven/bun:1-slim             → Bun + SQLite + Flutter Web 静态文件
```

```bash
git pull && docker compose up -d --build   # 更新
docker compose down -v && docker compose up -d --build  # 重置
```

---

## 环境变量

| 变量 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `DATABASE_PATH` | 否 | `data/greenstone.db` | SQLite 文件路径 |
| `JWT_SECRET` | 否 | 自动生成存 `data/jwt_secret` | JWT 签名密钥 |
| `PORT` | 否 | `3001` | 后端端口 |
| `PUBLIC_DIR` | 否 | `./public` | Web 静态文件目录 (Docker) |
| `API_URL` | 否 | Web: 自动跟随页面 host | Dart `--dart-define` 编译时注入 |

---

## 扩展

### 添加新学校

1. 在 `app/src/parsers/schools/` 创建 `xxx.fetcher.ts`，实现登录 + 抓取
2. 在 `app/src/parsers/schools/xxx.parser.ts` 中实现 HTML → `ParsedCourse[]`
3. 在 `app/src/routes/import-jwc.ts` 的 `createSchoolFetcher()` 中添加分支

### 添加新导入格式

1. 在 `app/src/parsers/importers/` 创建新 importer，实现 `ITimetableImporter`
2. 在 `app/src/services/import.service.ts` 的 `this.importers` 中注册
3. 在 `app/src/parsers/strategies/detector.ts` 中添加检测逻辑

---

## 常见问题

### Web 端注册报 `crypto.subtle is undefined`

Web 非安全上下文（HTTP 非 localhost）无法使用 `FlutterSecureStorage`。已自动回退到 `SharedPreferences`，不影响使用。

### Flutter Web 访问后端报 CORS

后端已配置 `cors({ origin: true })`，允许所有来源。

### 后端启动后报 `no such table: users`

手动删除了 `data/greenstone.db` 但保留了 `data/jwt_secret`。删除 `data/` 目录后重启即可自动重建。

### 导入课程表后页面白屏

浏览器缓存了旧版 JSON 格式（camelCase）。F12 → Application → Storage → Clear site data，刷新。

### Web 构建时 `API_URL` 为空

正常——Docker 部署时前后端同容器，API 走同源。本地开发自动检测页面 host。
