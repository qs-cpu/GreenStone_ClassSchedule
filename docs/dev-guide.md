# 开发指南

## 环境要求

- **Flutter SDK** 3.11+ （`~/flutter/bin/flutter`）
- **Dart SDK** 3.11+ （随 Flutter 附带）
- **Bun** 1.x （`curl -fsSL https://bun.sh/install | bash`）
- **Java** 17 （Android 构建必需，`sudo apt install openjdk-17-jdk`）
- **Android SDK** （commandlinetools + platform 36 + build-tools 36）
- **direnv** （自动加载环境变量，可选）
- **just** （命令运行器，`cargo install just` 或 `apt install just`）

Docker 仅用于生产部署，本地开发不需要。

## 环境初始化

### 1. direnv 配置（可选）

```bash
sudo apt install direnv

# zsh
echo 'eval "$(direnv hook zsh)"' >> ~/.zshenv && source ~/.zshenv
# bash
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc && source ~/.bashrc

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
just init          # flutter clean + pub get + bun install
```

### 5. 数据库

SQLite 零配置——首次 `just api` 或 `just start` 会自动创建 `app/data/greenstone.db`。
如需种子管理员：`just db-setup`。

---

## 日常开发

```bash
just start         # 并发启动前后端（推荐）
just web           # 仅 Flutter Web
just api           # 仅 Bun 后端 → http://localhost:3001
just android       # Android 模拟器
just android-url http://192.168.1.10:3001  # Android 真机

# 代码检查
just analyze       # flutter analyze
just fmt           # dart format .
```

启动后：

- **前端**：`http://localhost:PORT`（`just start` 输出提示）
- **后端**：`http://localhost:3001`
- **API 测试**：`curl http://localhost:3001/api/health`

---

## Justfile 命令速查

### 环境

| 命令 | 说明 |
|------|------|
| `just init` | flutter clean + pub get + bun install |
| `just clean` | flutter clean |
| `just get` | flutter pub get |
| `just analyze` | flutter analyze |
| `just fmt` | dart format . |
| `just outdated` | flutter pub outdated |
| `just devices` | flutter devices |

### 运行

| 命令 | 说明 |
|------|------|
| `just start` | 并发启动前端 (web-server) + 后端 (bun dev) |
| `just web` | 仅 Flutter Web |
| `just api` | 仅 Bun 后端 (:3001) |
| `just android` | flutter run -d android |
| `just android-url <url>` | 指定后端地址运行 Android |

### 构建

| 命令 | 说明 |
|------|------|
| `just build-web` | flutter build web |
| `just build-apk-debug` | 构建 Debug APK |
| `just build-apk` | 构建 Release APK |
| `just build-apk-url <url>` | 指定后端地址构建 Release APK |

### 数据库

| 命令 | 说明 |
|------|------|
| `just db-migrate` | Drizzle Kit push schema |
| `just db-seed-admin` | 创建管理员账号 |
| `just db-setup` | 迁移 + 创建管理员 |

### 部署

| 命令 | 说明 |
|------|------|
| `just deploy` | db-setup + 启动前后端 |

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
just build-apk                        # 默认后端地址
just build-apk-url https://api.example.com  # 指定生产环境后端
```

---

## Docker 部署

### 构建与启动

```bash
docker compose up -d --build
# → http://localhost:8080
```

不需要 `.env` —— JWT_SECRET 自动生成到 `/data/jwt_secret`，数据库自动创建到 `/data/greenstone.db`。

### Dockerfile 结构

```
Stage 1: cirruslabs/flutter:stable   → flutter build web
Stage 2: oven/bun:1                  → bun install 后端依赖
Stage 3: oven/bun:1-slim             → Bun + SQLite + Flutter Web 静态文件
                                       docker-entrypoint.sh 启动一切
```

单容器运行，一个进程，一个 `.db` 文件。Flutter Web 复制到 `/app/public`，由 `Bun.file()` 服务。

### 更新部署

```bash
git pull && docker compose up -d --build
```

### 重置数据库

```bash
docker compose down -v && docker compose up -d --build
```

---

## 环境变量

| 变量 | 必填 | 默认值 | 说明 |
|------|------|--------|------|
| `DATABASE_PATH` | 否 | `data/greenstone.db` | SQLite 文件路径 |
| `JWT_SECRET` | 否 | 自动生成存到 `data/jwt_secret` | JWT 签名密钥 |
| `PORT` | 否 | `3001` | 后端端口 |
| `PUBLIC_DIR` | 否 | `./public` | Flutter Web 静态文件目录 |
| `API_URL` | 否 | Web: `localhost:3001` / Android: `10.0.2.2:3001` | Dart 编译时 `--dart-define=API_URL=...` |
| `ALLOW_INSECURE_API` | 否 | debug: `true` / release: `false` | 允许 HTTP 明文 API |

---

## 添加新学校

1. 在 `app/src/parsers/schools/` 创建 `xxx.fetcher.ts`，实现登录 + 抓取
2. 在 `app/src/parsers/schools/xxx.parser.ts` 中实现 HTML → `ParsedCourse[]`
3. 在 `app/src/routes/import-jwc.ts` 的 `createSchoolFetcher()` 中添加分支

## 添加新导入格式

1. 在 `app/src/parsers/importers/` 创建新 importer，实现 `ITimetableImporter`
2. 在 `app/src/services/import.service.ts` 的 `this.importers` 中注册
3. 在 `app/src/parsers/strategies/detector.ts` 中添加类型检测逻辑

## 运行测试

```bash
# 前端
flutter test

# 后端
cd app && bun test
cd app && bun test --coverage
```

详见 [docs/testing.md](testing.md)。

---

## 常见问题

### VM / WSL 中 `adb` 连不上真机

```powershell
# 管理员 PowerShell
netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=3001 connectaddress=172.20.81.39 connectport=3001
```

或：

```bash
adb reverse tcp:3001 tcp:3001
flutter run -d <device_id> --dart-define=API_URL=http://127.0.0.1:3001
```

### Flutter Web 访问后端报 CORS

后端已配置 `@elysiajs/cors`。检查 `app/src/index.ts` 中 `.use(cors())` 存在。

### 后端启动报 `JWT_SECRET` 相关错误

`config/index.ts` 首次运行自动生成密钥到 `data/jwt_secret`。如果手动设过 `JWT_SECRET=greenstone-secret-key`（已拒绝），改为不设置让自动生成。

### Android 构建报 SDK 找不到

`echo $ANDROID_HOME`，检查 `direnv allow` 是否生效。

### Web 构建时 `API_URL` 为空导致请求同源

正常行为——Docker 部署时前后端同容器。本地开发自动使用 `localhost:3001`。

### 前端报 `UnimplementedError: sharedPreferencesProvider must be overridden`

测试中需要 mock `SharedPreferences` 和 `FlutterSecureStorage`。参考 `test/app/app_router_test.dart`。
