# 架构

## 概览

GreenStone ClassSchedule 是一个全栈课程表管理应用，Flutter 前端 + Bun/Elysia 后端 + SQLite 数据库，支持 Web 和 Android 平台。零配置启动，Docker 单容器部署。

```
┌──────────────────────────────────────────────────────────┐
│                    浏览器 / Android 设备                   │
├──────────────────────────────────────────────────────────┤
│  Flutter Web SPA  │  REST API (Bearer JWT)               │
└──────────┬───────────────────────────────────────────────┘
           │ HTTP (自动跟随页面 host，端口 3001)
┌──────────▼───────────────────────────────────────────────┐
│                    Bun + Elysia (:3001)                   │
├──────────────────────────────────────────────────────────┤
│  Auth  │  Timetable  │  Import  │  Source  │  Admin       │
│  Import-JWC (教务系统直连)  │  静态文件 (Flutter Web)      │
│  /api/health  │  请求日志中间件 (method/path/status/dur)   │
├──────────────────────────────────────────────────────────┤
│  SQLite (bun:sqlite, WAL 模式, 首次启动自动建表)           │
└──────────────────────────────────────────────────────────┘
```

## 目录结构

```
GreenStone_ClassSchedule/
├── lib/                              # Flutter 前端 (Dart)
│   ├── main.dart                     # 入口：ProviderScope、Token 迁移
│   ├── core/network/
│   │   └── api_client.dart           # Dio 实例 + 认证拦截器 + 自动 host 检测
│   ├── app/
│   │   ├── router/app_router.dart    # GoRouter（认证守卫）
│   │   └── theme/app_theme.dart      # Material 3 糖果色主题
│   └── features/
│       ├── auth/                     # 认证模块
│       │   ├── data/auth_repository.dart
│       │   ├── application/auth_provider.dart  # Token/User/Auth StateNotifier
│       │   └── presentation/
│       │       ├── login_page.dart
│       │       └── register_page.dart
│       ├── timetable/                # 课程表查看
│       │   ├── domain/
│       │   │   ├── course.dart / .freezed.dart / .g.dart
│       │   │   ├── course_session.dart / ...
│       │   │   └── timetable.dart / ...
│       │   ├── data/
│       │   │   ├── timetable_repository.dart
│       │   │   └── timetable_cache_repository.dart  # 离线缓存
│       │   ├── application/timetable_provider.dart
│       │   └── presentation/
│       │       ├── timetable_home_page.dart   # 周/日视图 + 天气卡片
│       │       └── widgets/ink_dino_game.dart # 闲置区域小恐龙游戏
│       ├── import/                   # 课程导入
│       │   ├── data/import_repository.dart
│       │   ├── application/import_provider.dart
│       │   └── presentation/import_page.dart
│       ├── source/                   # 数据来源管理
│       │   ├── domain/
│       │   │   ├── timetable_source.dart / .freezed / .g
│       │   │   └── sync_record.dart / .freezed / .g
│       │   ├── data/source_repository.dart
│       │   ├── application/source_provider.dart
│       │   └── presentation/
│       │       ├── source_list_page.dart
│       │       └── source_detail_page.dart
│       └── admin/                    # 管理员面板
│           ├── data/admin_repository.dart
│           ├── application/admin_provider.dart
│           └── presentation/
│               ├── admin_home_page.dart
│               └── admin_user_list_page.dart
│
├── test/                             # Flutter 测试
│   ├── helpers/
│   │   └── secure_storage_mock.dart
│   ├── app/app_router_test.dart
│   ├── core/api_client_test.dart
│   └── features/auth/auth_provider_test.dart
│
├── app/                              # Bun/Elysia 后端 (TypeScript)
│   ├── package.json                  # 依赖声明
│   ├── drizzle.config.ts             # Drizzle Kit 配置 (dialect: sqlite)
│   └── src/
│       ├── index.ts                  # 入口：CORS、请求日志、API 路由、静态文件
│       ├── config/index.ts           # JWT 自动生成 + 持久化
│       ├── db/
│       │   ├── index.ts              # bun:sqlite 连接 + 首次启动自动建表
│       │   └── schema.ts             # 10 张表 (sqlite-core)
│       ├── routes/
│       │   ├── auth.ts               # /api/auth/register, /api/auth/login
│       │   ├── timetable.ts          # /api/timetables/*
│       │   ├── import.ts             # /api/import
│       │   ├── import-jwc.ts         # /api/import-jwc (教务系统)
│       │   ├── source.ts             # /api/sources/*
│       │   └── admin/users.ts        # /api/admin/users CRUD
│       ├── services/
│       │   ├── auth.service.ts       # JWT 签发/验证
│       │   ├── timetable.service.ts  # 课表查询/周视图/日视图 (批量查询)
│       │   ├── import.service.ts     # URL 导入管道
│       │   ├── sync.service.ts       # 来源增量同步
│       │   ├── source.service.ts     # 来源列表/详情
│       │   └── timetable-writer.ts   # 共享课程写入逻辑
│       ├── middleware/
│       │   ├── auth.ts               # Bearer token 解析 + 验证
│       │   └── admin.ts              # 管理员角色校验
│       ├── dto/
│       │   └── user.dto.ts           # 用户 DTO 转换
│       ├── parsers/
│       │   ├── importers/
│       │   │   ├── importer.interface.ts  # ParsedCourse 接口
│       │   │   ├── ics.importer.ts        # ICS 日历解析
│       │   │   └── json.importer.ts       # JSON 格式解析
│       │   ├── schools/
│       │   │   ├── fdzc.const.ts          # 福大至诚 教务系统常量
│       │   │   ├── fdzc.fetcher.ts        # 登录 + 抓取课表
│       │   │   └── fdzc.parser.ts         # HTML 表格 → ParsedCourse 解析
│       │   ├── strategies/
│       │   │   └── detector.ts            # 内容类型检测 (ICS/JSON)
│       │   └── utils/
│       │       └── http.client.ts         # Cookie 管理 + form-urlencoded
│       ├── utils/url.validator.ts   # URL 白名单校验 + SSRF 防护
│       ├── seed-admin.ts            # 管理员初始化
│       └── __tests__/               # 后端测试
│           ├── helpers/db.ts
│           ├── auth.test.ts
│           ├── importers.test.ts
│           └── url-validator.test.ts
│
├── android/                          # Android 原生项目
├── docs/                             # 项目文档
├── Dockerfile                        # 三阶段：Flutter Web → Bun 依赖 → Bun + SQLite
├── docker-entrypoint.sh              # 容器启动脚本 (JWT 自动生成、表创建、种子数据)
├── docker-compose.yml                # 单容器部署
├── Justfile                          # 命令运行器
├── pubspec.yaml                      # Flutter 依赖声明
└── analysis_options.yaml             # Dart 静态分析配置
```

## 前端路由

| 路由 | 页面 | 说明 |
|------|------|------|
| `/login` | `LoginPage` | 登录 |
| `/register` | `RegisterPage` | 注册 |
| `/` | `TimetableHomePage` | 课程表主页：周视图/日视图 |
| `/import` | `ImportPage` | 课程导入：教务系统 / URL |
| `/sources` | `SourceListPage` | 数据来源列表 |
| `/sources/:id` | `SourceDetailPage` | 来源详情 + 同步记录 |
| `/admin` | `AdminHomePage` | 管理员面板首页 |
| `/admin/users` | `AdminUserListPage` | 用户管理 |

认证守卫逻辑：
- 未登录 + 不在登录/注册页 → 重定向 `/login`
- 已登录 + 在登录/注册页 → 重定向 `/`
- 其他情况：放行

## 后端 API 结构

```
/api/health
  GET /            健康检查 → { "status": "ok" }

/api/auth
  POST /register    注册
  POST /login       登录

/api/timetables
  GET /                    课表列表
  GET /:id                 课表详情 (含课程/课次/地点)
  GET /:id/week/:weekNo    周视图 (按单双周过滤)
  GET /:id/day?date=...    日视图

/api/import
  POST /           URL 导入 (自动检测 ICS/JSON)

/api/import-jwc
  GET  /captcha    获取验证码图片 (query: school)
  POST /           教务系统登录 + 抓取课表

/api/sources
  GET /            来源列表
  GET /:id         来源详情 + 同步记录
  POST /:id/sync   触发来源同步

/api/admin/users
  GET    /              用户列表 (分页 + 搜索)
  GET    /:id           用户详情
  POST   /              创建用户
  PUT    /:id           更新用户
  DELETE /:id           删除用户 (级联合联删除)
  GET    /stats/overview 用户统计概览
```

## 设计决策

### 零配置启动

- **JWT_SECRET**：首次启动自动生成 64 位 hex 密钥，存到 `data/jwt_secret`
- **数据库**：首次启动自动建 10 张表，无需 `drizzle-kit push`
- **API 地址**：Web 端运行时读取 `Uri.base.host` 自动拼接 `:3001`，无需手动设 `API_URL`

### Riverpod 状态管理

选用 `flutter_riverpod` 而非 BLoC 或 Provider：
- `StateNotifierProvider` 管理 Token、UserInfo、AuthState
- `Provider` 管理 Dio 实例、GoRouter、Repository
- `FutureProvider` 自动处理 async/loading/error 三态

### 存储策略

| 存储 | 用途 | 回退 |
|------|------|------|
| `FlutterSecureStorage` | JWT Token (加密存储) | Web 非安全上下文自动回退 `SharedPreferences` |
| `SharedPreferences` | 用户信息、离线课表缓存 | — |

### Freezed 不可变模型

所有领域模型 (`Course`, `CourseSession`, `Timetable`, `TimetableSource`, `SyncRecord`) 使用 `freezed` + `json_serializable` 生成。`.g.dart` 的 JSON 键名统一为 snake_case 以匹配 Drizzle ORM 输出，同时兼容旧版 camelCase 缓存。

### Dio 认证拦截器

全局自动注入 Bearer token，401 自动清空本地 token（踢出登录），debug 模式自动日志。

### 请求日志

后端 Elysia `onAfterResponse` 中间件，dev 模式下每条请求输出 `✓ GET /api/timetables 200 3ms`。前端 Dio `LogInterceptor` 记录 method/URL/status。

### 教务系统爬虫

以 **福州大学至诚学院** (`fdzc`) 为例的教务系统直连流程：

```
1. GET default.asp                → 解析登录表单 action URL
2. GET ValidateCookie.asp         → 获取 BMP 验证码
3. 用户手动输入验证码
4. GET ajax/chkCode.asp?code=     → 验证码校验
5. POST loginURL                  → 教务系统登录 (muser + passwd + code)
6. POST kb/kb_xs.asp              → 抓取课程表 HTML
7. HTMLRewriter 解析 HTML 表格    → ParsedCourse[]
8. GET kb/zkb_xs.asp              → 获取学期起始日期
9. 写入数据库 (timetable → course → session → location)
```

新增学校：实现 `FdzcFetcher` 模式并在 `import-jwc.ts` 的 `createSchoolFetcher()` 中添加分支。

## 数据库表设计

所有字段类型为 SQLite TEXT / INTEGER。日期统一用 ISO 8601 字符串 (`new Date().toISOString()`)。

### `users`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | UUID |
| username | TEXT UNIQUE | |
| password_hash | TEXT | bcryptjs (10 轮) |
| nickname | TEXT | |
| role | TEXT | `user` / `admin` |
| created_at | TEXT | ISO 8601 |
| updated_at | TEXT | ISO 8601 |

### `terms`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | UUID |
| user_id | TEXT FK → users.id | |
| name | TEXT | e.g. "2025年上学期" |
| start_date | TEXT | ISO 8601 |
| end_date | TEXT | ISO 8601 |
| total_weeks | INTEGER | 默认 20 |
| timezone | TEXT | 默认 'Asia/Shanghai' |

### `time_slots`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| term_id | TEXT FK → terms.id | |
| section_index | INTEGER | 节次序号 1-12 |
| start_time | TEXT | e.g. "08:00" |
| end_time | TEXT | e.g. "08:45" |

### `timetables`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | UUID |
| user_id | TEXT FK → users.id | |
| term_id | TEXT FK → terms.id | |
| source_id | TEXT UNIQUE | FK → timetable_sources.id |
| title | TEXT | |

### `courses`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| timetable_id | TEXT FK → timetables.id | |
| title | TEXT | 课程名 |
| teacher | TEXT | 教师 |
| color | TEXT | HEX 颜色 |
| remark | TEXT | 备注 |

### `course_sessions`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| course_id | TEXT FK → courses.id | |
| weekday | INTEGER | 1-7 |
| start_section | INTEGER | |
| end_section | INTEGER | |
| start_week | INTEGER | 默认 1 |
| end_week | INTEGER | 默认 20 |
| week_type | TEXT | `all` / `odd` / `even` |
| note | TEXT | |

### `locations`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| session_id | TEXT FK → course_sessions.id | |
| location_text | TEXT | 完整地点 |
| building | TEXT | 楼栋 |
| room | TEXT | 教室 |

### `timetable_sources`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| user_id | TEXT FK → users.id | |
| original_url | TEXT | |
| source_type | TEXT | ICS / JSON / HTML |
| sync_status | TEXT | idle / syncing / success / failed |
| last_synced_at | TEXT | |

### `sync_records`

| 列 | 类型 | 说明 |
|---|---|---|
| id | TEXT PK | |
| source_id | TEXT FK → timetable_sources.id | |
| status | TEXT | syncing / success / failed |
| message | TEXT | |
| started_at | TEXT | |
| finished_at | TEXT | |

## 核心依赖

| 包 | 用途 |
|---|---|
| `flutter_riverpod` | 状态管理 |
| `go_router` | 声明式路由 + 认证守卫 |
| `dio` | HTTP 客户端 + 拦截器 |
| `freezed` + `json_serializable` | 不可变模型 + JSON 序列化 |
| `shared_preferences` | 用户偏好 + 离线缓存 |
| `flutter_secure_storage` | JWT 安全存储 (Web 回退) |
| `elysia` | Bun 原生 HTTP 框架 |
| `drizzle-orm` (bun-sqlite) | SQLite ORM + 迁移 |
| `jose` | JWT 签发/验证 |
| `bcryptjs` | 密码哈希 |
| `axios` | 服务端 HTTP 请求 |
| `htmlrewriter` | HTML 解析 |
