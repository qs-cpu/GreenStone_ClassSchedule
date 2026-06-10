# 开发指南

## 环境要求

- **Flutter SDK** 3.11+ （`~/flutter/bin/flutter`）
- **Dart SDK** 3.11+ （随 Flutter 附带）
- **Bun** 1.x （`curl -fsSL https://bun.sh/install | bash`）
- **Java** 17 （Android 构建必需，`sudo apt install openjdk-17-jdk`）
- **Android SDK** （commandlinetools + platform 36 + build-tools 36）
- **Docker** （PostgreSQL + Redis）
- **direnv** （自动加载环境变量）
- **just** （命令运行器，`cargo install just` 或 `apt install just`）

## 环境初始化

### 1. direnv 配置

```bash
# 安装
sudo apt install direnv

# zsh
echo 'eval "$(direnv hook zsh)"' >> ~/.zshenv && source ~/.zshenv

# bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && source ~/.bashrc

# 允许项目 .envrc
cd GreenStone_ClassSchedule && direnv allow
```

`.envrc` 内容：

```bash
# Java
if [ -d "/usr/lib/jvm/java-1.17.0-openjdk-amd64" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-1.17.0-openjdk-amd64"
elif [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
fi

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Flutter
export PATH="$HOME/flutter/bin:$PATH"
```

### 2. Android SDK 安装

```bash
mkdir -p ~/Android/Sdk && cd ~/Android/Sdk
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip -d tmp
mkdir -p cmdline-tools/latest
mv tmp/cmdline-tools/* cmdline-tools/latest/ && rm -rf tmp

sdkmanager \
  "cmdline-tools;latest" \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0"

sdkmanager --licenses
```

### 3. Flutter 安装

```bash
git clone https://github.com/flutter/flutter.git ~/flutter
flutter config --android-sdk $HOME/Android/Sdk
flutter doctor
flutter doctor --android-licenses
flutter precache --android
```

### 4. 项目初始化

```bash
just init          # flutter clean + flutter pub get
```

### 5. 数据库和缓存

```bash
just db-start      # 启动 PostgreSQL (Docker)
just redis-start   # 启动 Redis (Docker)
just db-setup      # 迁移 + 创建管理员
```

或者一键启动后端（含数据库）：

```bash
just start         # 启动 DB + Redis + Bun 后端
```

---

## 日常开发

```bash
# Flutter Web
just run-web                       # → http://localhost:PORT

# Flutter Android (模拟器)
just run-android                   # 默认连接 10.0.2.2:3001

# Flutter Android (真机，指定后端)
just run-android-url http://192.168.1.10:3001

# 仅启动后端
cd app && bun run dev              # → http://localhost:3001

# 代码检查
just analyze                       # flutter analyze

# 代码格式化
just fmt                           # dart format .
```

启动后：

- **Web 前端**：`http://localhost:PORT`（Flutter 输出提示）
- **后端 API**：`http://localhost:3001`
- **API 测试**：浏览器直接 GET `/api/health` 或使用 `curl`

---

## Justfile 命令速查

### Flutter

| 命令 | 说明 |
|------|------|
| `just init` | flutter clean + pub get |
| `just clean` | flutter clean |
| `just get` | flutter pub get |
| `just analyze` | flutter analyze |
| `just fmt` | dart format . |
| `just outdated` | flutter pub outdated |
| `just rebuild` | clean + get + run |
| `just devices` | flutter devices |

### 运行

| 命令 | 说明 |
|------|------|
| `just run-web` | flutter run -d web-server |
| `just run-android` | flutter run -d android |
| `just run-android-url <url>` | 指定后端地址运行 Android |

### 构建

| 命令 | 说明 |
|------|------|
| `just build-web` | flutter build web |
| `just build-apk-debug` | 构建 Debug APK |
| `just build-apk` | 构建默认 APK |
| `just build-apk-release` | 构建 Release APK |
| `just build-apk-release-url <url>` | 指定后端地址构建 Release APK |

### 数据库

| 命令 | 说明 |
|------|------|
| `just db-start` | 启动 PostgreSQL (Docker, 端口 5432) |
| `just db-stop` | 停止并删除 PostgreSQL 容器 |
| `just db-migrate` | Drizzle Kit 数据库迁移 |
| `just db-seed-admin` | 创建管理员账号（已存在则跳过） |
| `just db-setup` | 迁移 + 创建管理员 |
| `just db-shell` | 进入 PostgreSQL shell |
| `just redis-start` | 启动 Redis (Docker, 端口 6379) |
| `just redis-stop` | 停止并删除 Redis 容器 |

### 后端

| 命令 | 说明 |
|------|------|
| `just start` | 启动 DB + Redis + Bun 后端 |
| `just deploy` | 完整部署（启动 DB/Redis → 迁移 → 创建管理员 → 启动后端） |

---

## 构建 Release APK

### 生成签名密钥

```bash
cd android
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias greenstone
```

### 配置签名

复制 `android/key.properties.example` 为 `android/key.properties`：

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=greenstone
storeFile=../release-key.jks
```

### 构建

```bash
# 不指定后端地址（使用默认 localhost）
just build-apk-release

# 指定生产环境后端地址
just build-apk-release-url https://api.example.com
```

---

## Docker 部署

### 构建与启动

项目根目录配置 `.env`：

```env
DATABASE_URL=postgresql://postgres:password@127.0.0.1:5432/greenstone
JWT_SECRET=your-secret-key
```

构建并启动：

```bash
docker compose up -d --build
# → http://localhost:3001 （前后端一体化）
```

### Dockerfile 结构

```
Stage 1: cirruslabs/flutter:stable   → flutter build web (--release)
Stage 2: oven/bun:1                  → bun install 后端依赖
Stage 3: postgres:14                 → Pg + Redis + Bun + Flutter Web 静态文件
                                       docker-entrypoint.sh 启动一切
```

单容器运行：PostgreSQL → Redis → Bun/Elysia。Flutter Web 文件复制到 `/app/public`，由 `Bun.file()` 服务。

### 更新部署

```bash
git pull && docker compose up -d --build
```

### 重置数据库

```bash
docker compose down -v
docker compose up -d --build
```

---

## 环境变量

| 变量 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `DATABASE_URL` | 是 | — | PostgreSQL 连接串，格式 `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | 否 | `greenstone-secret-key` | JWT 签名密钥，**生产务必修改** |
| `REDIS_HOST` | 否 | `localhost` | Redis 地址 |
| `REDIS_PORT` | 否 | `6379` | Redis 端口 |
| `PORT` | 否 | `3000` | 后端端口（入口文件写死 3001，未使用此变量） |
| `PUBLIC_DIR` | 否 | `./public` | Flutter Web 静态文件目录 |
| `API_URL` | 否 | Web 自动 `localhost:3001` / Android 自动 `10.0.2.2:3001` | Dart 编译时 `--dart-define=API_URL=...` 注入 |
| `ALLOW_INSECURE_API` | 否 | debug 模式 `true`，release 模式 `false` | 允许 HTTP 明文 API（Release 默认要求 HTTPS） |

---

## 添加新学校

1. 在 `app/src/parsers/schools/` 创建 `xxx.fetcher.ts`，实现登录 + 抓取逻辑
2. 在 `app/src/parsers/schools/xxx.parser.ts` 中实现 HTML → `ParsedCourse[]` 解析
3. 在 `app/src/parsers/schools/index.ts` 的 `schools` 注册表添加新学校
4. 在 `app/src/routes/import-jwc.ts` 的 `createSchoolFetcher()` 中添加分支

## 添加新的导入格式

1. 在 `app/src/parsers/importers/` 创建新 importer，实现 `ITimetableImporter` 接口
2. 在 `app/src/services/import.service.ts` 的 `this.importers` 数组中注册
3. 在 `app/src/parsers/strategies/detector.ts` 中添加类型检测逻辑

---

## 常见问题

### VM / WSL 中 `adb` 连不上真机

使用 Windows 端口转发：

```powershell
# 管理员 PowerShell
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=3001 connectaddress=172.20.81.39 connectport=3001
```

或使用 `adb reverse`：

```bash
adb reverse tcp:3001 tcp:3001
flutter run -d <device_id> --dart-define=API_URL=http://127.0.0.1:3001
```

### Flutter Web 访问后端报 CORS

后端已配置 `@elysiajs/cors`，默认允许所有来源。如果遇到问题，检查 `app/src/index.ts` 中 `.use(cors())` 是否存在。

### 后端启动报 `password authentication failed`

检查 `DATABASE_URL` 中用户名和密码是否匹配 Docker 容器默认值（`postgres:password`），或执行 `just db-start` 重建容器。

### Drizzle 迁移报错

确保 PostgreSQL 容器正在运行：`docker ps | grep greenstone-db`。然后重新执行 `just db-migrate`。

### Android 构建报 SDK 找不到

检查 `ANDROID_HOME` 环境变量：`echo $ANDROID_HOME`。`direnv allow` 后重新进入目录。

### Web 构建时 `API_URL` 为空导致请求 `/api/...` 走同源

这是正常行为——Docker 部署时 Flutter Web 与后端同容器，API 同源。本地开发时 Web 自动使用 `localhost:3001`。

### 前端报 `UnimplementedError: sharedPreferencesProvider must be overridden`

检查 `main.dart` 中 `ProviderScope(overrides: [...])` 是否正确覆盖了 `sharedPreferencesProvider`。如果测试时遇到，需在测试中 mock。
