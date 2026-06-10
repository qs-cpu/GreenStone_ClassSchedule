# 架构

## 概览

GreenStone ClassSchedule 是一个全栈课程表管理应用，Flutter 前端 + Bun/Elysia 后端，支持 Web、Android 平台，可 Docker 单容器部署。

```
┌──────────────────────────────────────────────────────────┐
│                    浏览器 / Android 设备                   │
├──────────────────────────────────────────────────────────┤
│  Flutter Web SPA  │  REST API (Bearer JWT)               │
└──────────┬───────────────────────────────────────────────┘
           │ HTTP
┌──────────▼───────────────────────────────────────────────┐
│                    Bun + Elysia (:3001)                   │
├──────────────────────────────────────────────────────────┤
│  Auth  │  Timetable  │  Import  │  Source  │  Admin       │
│  Import-JWC (教务系统直连)  │  静态文件 (Flutter Web)      │
├──────────────────────────────────────────────────────────┤
│  SQLite (bun:sqlite, WAL 模式)                            │
└──────────────────────────────────────────────────────────┘
```

## 目录结构

```
GreenStone_ClassSchedule/
├── lib/                              # Flutter 前端 (Dart)
│   ├── main.dart                     # 入口：ProviderScope、Token 迁移
│   ├── core/network/
│   │   └── api_client.dart           # Dio 实例 + 认证拦截器 + API 端点常量
│   ├── app/
│   │   ├── router/app_router.dart    # GoRouter 配置（认证守卫）
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
│       │   │   ├── course.dart / course.freezed.dart / course.g.dart
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
├── app/                              # Bun/Elysia 后端 (TypeScript)
│   ├── package.json                  # 依赖声明 (elysia, drizzle-orm, jose, bcryptjs...)
│   ├── drizzle.config.ts             # Drizzle Kit 配置
│   └── src/
│       ├── index.ts                  # 入口：Elysia 实例、静态文件、路由挂载
│       ├── config/index.ts           # 环境变量统一读取
│       ├── db/
│       │   ├── index.ts              # drizzle 连接 (pg Pool)
│       │   └── schema.ts             # 10 张表 + Drizzle relations
│       ├── routes/
│       │   ├── auth.ts               # /api/auth/register, /api/auth/login
│       │   ├── timetable.ts          # /api/timetables/*
│       │   ├── import.ts             # /api/import (URL + 文件)
│       │   ├── import-jwc.ts         # /api/import-jwc (教务系统)
│       │   ├── source.ts             # /api/sources/*
│       │   └── admin/users.ts        # /api/admin/users CRUD
│       ├── services/
│       │   ├── auth.service.ts       # JWT 签发/验证 + bcryptjs 密码
│       │   ├── timetable.service.ts  # 课表查询/周视图/日视图
│       │   ├── import.service.ts     # URL 导入管道
│       │   ├── sync.service.ts       # 来源增量同步
│       │   ├── source.service.ts     # 来源列表/详情
│       │   └── term.service.ts       # 学期创建/查询
│       ├── middleware/
│       │   ├── auth.ts               # Bearer token 解析 + 验证
│       │   └── admin.ts              # 管理员角色校验
│       ├── dto/
│       │   ├── user.dto.ts           # 用户 DTO 转换
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
│       │   │   ├── detector.ts            # 内容类型检测 (ICS/JSON)
│       │   └── utils/
│       │       └── http.client.ts         # Cookie 管理 + form-urlencoded
│       ├── utils/url.validator.ts   # URL 白名单校验
│       └── seed-admin.ts            # 管理员初始化
│
│   └── app/src/main/kotlin/.../MainActivity.kt
├── Dockerfile                        # 三阶段：Flutter Web → Bun 依赖 → Bun + SQLite
├── docker-entrypoint.sh              # 容器启动脚本
├── Justfile                          # 任务运行器 (init/run/build/db/start)
├── pubspec.yaml                      # Flutter 依赖声明
├── analysis_options.yaml             # Dart 静态分析配置
└── .envrc                            # direnv 环境变量 (JAVA_HOME, ANDROID_HOME)
```

## 前端路由

| 路由 | 页面 | 说明 |
|------|------|------|
| `/login` | `LoginPage` | 登录 |
| `/register` | `RegisterPage` | 注册 |
| `/` | `TimetableHomePage` | 课程表主页：周视图/日视图 |
| `/import` | `ImportPage` | 课程导入：URL / 文件 / 教务系统 |
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
/api/auth
  POST /register    注册
  POST /login       登录

/api/timetables
  GET /                    课表列表
  GET /:id                 课表详情 (含课程/课次/地点)
  GET /:id/week/:weekNo    周视图 (按单双周过滤)
  GET /:id/day?date=...    日视图 (按日期计算周次)

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

### Riverpod 状态管理

选用 `flutter_riverpod` 而非 BLoC 或 Provider：
- `StateNotifierProvider` 管理 Token、UserInfo、AuthState
- `Provider` 管理 Dio 实例、GoRouter、Repository
- `FutureProvider` 自动处理 async/loading/error 三态

### 存储策略

| 存储 | 用途 | 理由 |
|------|------|------|
| `FlutterSecureStorage` | JWT Token | Android 加密存储，防逆向窃取 |
| `SharedPreferences` | 用户信息、离线课表缓存 | 快速读写，无加密需求 |

启动时自动迁移：旧版 `SharedPreferences` 中的 token → `FlutterSecureStorage`。

### Freezed 不可变模型

所有领域模型 (`Course`, `CourseSession`, `Timetable`, `TimetableSource`, `SyncRecord`) 使用 `freezed` + `json_serializable` 生成：
- `copyWith` 不可变更新
- `fromJson` / `toJson` 自动序列化
- `==` / `hashCode` 值相等

### Dio 认证拦截器

全局自动注入 Bearer token，401 自动清空本地 token（踢出登录），debug 模式自动日志。

### Bun 专有 API 使用

| API | 位置 | 说明 |
|-----|------|------|
| `Bun.file()` | `index.ts` | 静态文件读取 |

### 教务系统爬虫

以 **福州大学至诚学院** (`fdzc`) 为例的教务系统直连流程：

```
1. GET default.asp                → 解析登录表单 action URL
2. GET ValidateCookie.asp         → 获取 BMP 验证码
3. 验证码识别 (XOR 字模匹配)      → 人工输入 fallback
4. GET ajax/chkCode.asp?code=     → 验证码校验
5. POST loginURL                  → 教务系统登录 (muser + passwd + code)
6. POST kb/kb_xs.asp              → 抓取课程表 HTML
7. HTMLRewriter 解析 HTML 表格    → ParsedCourse[]
8. GET kb/zkb_xs.asp              → 获取学期起始日期
9. 写入数据库 (timetable → course → session → location)
```

新增学校只需实现 `SchoolFetcher` 接口并在 `schools` 注册表中注册。

### SQLite 模拟 PostgreSQL

后端的 Drizzle schema 使用 PostgreSQL 特性 (UUID, enum, timestamp with timezone)，需要真实的 PostgreSQL。测试/演示环境通过 Docker 提供。

## 数据流

### HTTP 请求生命周期

```
HTTP 请求
  → Elysia route handler
  → [getUserFromRequest] ← Bearer token 解析 + jose JWT 验证
  → handler
    → Service 函数
    → Drizzle ORM 查询 (PostgreSQL)
    → JSON 响应
```

或对于无需认证的端点 (`/api/auth/*`)：跳过 token 验证。

### URL 导入管道

```
POST /api/import { url }
  → validateUrl() URL 白名单校验
  → axios GET 原始内容
  → detectSourceType() 类型检测 (ICS / JSON / HTML / UNKNOWN)
  → 选择 Importer (IcsImporter / JsonImporter)
  → importer.parse() → ParsedTimetable
  → db.insert(timetables) 创建课表
  → db.insert(courses) 创建课程
  → db.insert(courseSessions) 创建课次
  → db.insert(locations) 创建地点
  → db.insert(timetableSources) 记录来源
```

### 离线缓存

```
服务端获取课表详情
  → TimetableCacheRepository.cacheTimetableDetail()
  → SharedPreferences.setString(...jsonEncode...)
  → 下次打开：先从缓存读取，同时后台刷新
```

每个用户的缓存按 `offline_timetable:{userId}:` 前缀隔离，登出时清理。

## 数据库表设计

### `users`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | `defaultRandom()` |
| username | VARCHAR(50) UNIQUE | |
| password_hash | TEXT | bcryptjs 哈希 (10 轮) |
| nickname | VARCHAR(100) | |
| role | ENUM('user','admin') | 默认 'user' |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

### `terms`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → users.id | |
| name | VARCHAR(100) | e.g. "2025年上学期" |
| start_date | TIMESTAMPTZ | |
| end_date | TIMESTAMPTZ | |
| total_weeks | INTEGER | 默认 20 |
| timezone | VARCHAR(50) | 默认 'Asia/Shanghai' |

### `time_slots`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| term_id | UUID FK → terms.id | |
| section_index | INTEGER | 节次序号 1-12 |
| start_time | VARCHAR(10) | e.g. "08:00" |
| end_time | VARCHAR(10) | e.g. "08:45" |

### `timetables`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → users.id | |
| term_id | UUID FK → terms.id | |
| source_id | UUID UNIQUE FK → timetable_sources.id | 关联数据来源 |
| title | VARCHAR(100) | |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

### `courses`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| timetable_id | UUID FK → timetables.id | |
| title | VARCHAR(100) | 课程名 |
| teacher | VARCHAR(50) | 教师 |
| color | VARCHAR(20) | HEX 颜色 |
| remark | TEXT | 备注 |

### `course_sessions`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| course_id | UUID FK → courses.id | |
| weekday | INTEGER | 1-7 (周一至周日) |
| start_section | INTEGER | 起始节次 |
| end_section | INTEGER | 结束节次 |
| start_week | INTEGER | 起始周 (默认 1) |
| end_week | INTEGER | 结束周 (默认 20) |
| week_type | ENUM('all','odd','even') | 单双周 |
| note | TEXT | |

### `locations`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| session_id | UUID FK → course_sessions.id | |
| location_text | VARCHAR(100) | 完整地点 |
| building | VARCHAR(50) | 楼栋 |
| room | VARCHAR(30) | 教室 |

### `timetable_sources`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → users.id | |
| original_url | TEXT | 原始 URL |
| final_url | TEXT | 重定向后 URL |
| source_type | VARCHAR(20) | ICS / JSON / HTML |
| importer_key | VARCHAR(50) | 使用哪个导入器 |
| etag | TEXT | HTTP ETag |
| last_modified | TEXT | |
| last_synced_at | TIMESTAMPTZ | |
| sync_status | VARCHAR(20) | idle / syncing / success / failed |
| error_message | TEXT | |

### `sync_records`

| 列 | 类型 | 说明 |
|---|---|---|
| id | UUID PK | |
| source_id | UUID FK → timetable_sources.id | |
| status | VARCHAR(20) | running / success / failed |
| message | TEXT | 错误/成功信息 |
| started_at | TIMESTAMPTZ | |
| finished_at | TIMESTAMPTZ | |

## 核心依赖

| 包 | 用途 |
|---|---|
| `flutter_riverpod` | 状态管理 |
| `go_router` | 声明式路由 + 认证守卫 |
| `dio` | HTTP 客户端 + 拦截器 |
| `freezed` + `json_serializable` | 不可变模型 + JSON 序列化 |
| `shared_preferences` | 用户偏好 + 离线缓存 |
| `flutter_secure_storage` | JWT 安全存储 |
| `elysia` | Bun 原生 HTTP 框架 |
| `drizzle-orm` + `pg` | PostgreSQL ORM + 迁移 |
| `jose` | JWT 签发/验证 |
| `bcryptjs` | 密码哈希 |
| `axios` | 服务端 HTTP 请求 |
| `htmlrewriter` | HTML 解析 (Cloudflare WASM polyfill) |
| `fast-bmp` | BMP 验证码解码 |
