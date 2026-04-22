# GreenStone 课程表系统设计文档

## 1. 项目概述

GreenStone 是一个面向学生用户的多端课程表系统，提供课程表导入、课程展示、来源管理、同步刷新与日历导出能力。系统采用前后端分离架构，前端基于 Flutter 实现 Web 与 Android 双端统一开发，后端提供数据接入、解析代理、业务接口与数据库持久化支持。

系统建设目标如下：

- 实现一个具备前端、后端、数据库的完整课程表信息系统
- 支持 Web 与 Android 双端访问
- 支持通过 URL 导入课程表数据
- 支持对课程表来源进行保存、刷新与管理
- 支持后续扩展更多学校与更多数据源

***

## 2. 建设范围

本项目当前建设范围包括：

- Flutter Web 前端
- Flutter Android 前端
- 后端服务
- 数据库系统
- URL 数据接入与课程表解析能力

本阶段聚焦课程表核心业务，不包含账号体系、支付、消息推送等外围系统。

***

## 3. 系统总体架构

系统采用典型的前后端分离架构，整体分为四层：

1. 表现层
2. 业务层
3. 数据接入层
4. 数据存储层

总体结构如下：

```text
Flutter Web / Android
        |
        v
     API Gateway
        |
        v
  Backend Application
   |        |        |
   |        |        +-- URL Fetch / Proxy
   |        +----------- Import / Parse Service
   +-------------------- Timetable Service
        |
        v
      Database
```

各层职责如下：

- 前端：负责页面展示、用户交互、状态管理与调用后端接口
- 后端：负责课程表导入、来源管理、解析编排、同步刷新与权限边界控制
- 数据接入层：负责读取远程 URL、识别来源类型、调用解析器、生成统一课程表模型
- 数据库存储层：负责课程表、课程、课次、来源、同步记录等数据持久化

***

## 4. 技术栈设计

## 4.1 前端技术栈

前端采用 Flutter 构建 Web 与 Android 双端应用，技术栈建议如下：

- Flutter
- Dart
- flutter\_riverpod
- go\_router
- dio
- freezed
- json\_serializable

采用该技术栈的原因如下：

- Flutter 可同时覆盖 Web 与 Android，减少多端重复开发成本
- Dart 类型系统适合领域建模和异步业务流程实现
- Riverpod 便于依赖注入、状态管理与模块解耦
- go\_router 适合 Web 路由与多页面结构管理
- dio 适合复杂网络请求、拦截器、超时、重试与代理切换
- freezed 与 json\_serializable 适合构建稳定的领域模型和接口数据模型

## 4.2 后端技术栈

后端建议采用 Node.js + NestJS 架构，技术栈如下：

- Node.js
- NestJS
- TypeScript
- Prisma
- PostgreSQL
- Redis

原因如下：

- NestJS 天然适合构建结构化后端系统，模块边界清晰
- TypeScript 与 Dart 都是强类型语言，前后端模型协作更顺畅
- Prisma 适合数据库模型管理、迁移和类型安全查询
- PostgreSQL 适合结构化业务数据存储
- Redis 适合缓存 URL 拉取结果、同步状态和频率控制

## 4.3 数据库技术栈

数据库选择如下：

- 主数据库：PostgreSQL
- 缓存数据库：Redis

PostgreSQL 用于持久化核心业务数据，Redis 用于：

- URL 拉取缓存
- 临时导入结果缓存
- 频率限制
- 同步任务状态缓存

***

## 5. 前端架构设计

前端采用分层 + 按功能组织的结构，推荐目录如下：

```text
lib/
  app/
    router/
    theme/
  core/
    network/
    constants/
    utils/
    widgets/
  features/
    auth/
    import/
      application/
      data/
      domain/
      presentation/
    timetable/
      application/
      data/
      domain/
      presentation/
    source/
      application/
      data/
      domain/
      presentation/
    settings/
      presentation/
```

职责划分如下：

- `app`：应用入口、路由、主题
- `core`：通用网络、常量、工具类与基础组件
- `features/import`：课程表导入流程
- `features/timetable`：课程表展示与课程数据处理
- `features/source`：来源管理与刷新逻辑
- `features/settings`：系统设置

前端的核心原则是：

- 页面只负责展示与交互
- 状态管理承接页面状态
- Repository 负责接口调用
- 领域模型独立于接口结构

***

## 6. 后端架构设计

后端采用模块化设计，推荐模块如下：

```text
src/
  modules/
    timetable/
    import/
    source/
    parser/
    sync/
    proxy/
    user/
  common/
    interceptors/
    filters/
    guards/
    utils/
  infra/
    prisma/
    redis/
    logger/
```

各模块职责如下：

- `timetable`：课程表业务逻辑，负责课表聚合、查询、更新
- `import`：处理导入流程，协调 URL 获取、来源识别、解析与保存
- `source`：管理来源地址、来源状态与来源元信息
- `parser`：各类导入器和解析器
- `sync`：处理刷新、同步记录和任务调度
- `proxy`：为 Web 端提供远程内容代理访问
- `user`：若作业需要用户概念，可管理用户与个人课表绑定

后端的核心职责不是直接“展示课表”，而是提供稳定的数据服务和来源管理能力。

***

## 7. 核心业务设计

系统核心业务围绕“课程表导入、课程表存储、课程表查询、来源刷新”展开。

## 7.1 课程表导入

课程表导入流程如下：

1. 用户在前端输入 URL
2. 前端调用后端导入接口
3. 后端对 URL 进行校验与规范化
4. 后端识别来源类型
5. 后端选择直接拉取或代理拉取
6. 后端将原始内容交给对应 Importer
7. Importer 输出统一中间结构
8. Mapper 将中间结构映射为课程表领域模型
9. 后端写入数据库
10. 返回导入结果给前端

## 7.2 课程表查询

用户可查询：

- 自己当前课程表
- 某学期课程表
- 某天课程
- 某周课程
- 某来源导入的课程表

后端负责聚合课程、课次、时间段等数据，前端负责将数据组织为周视图、日视图与列表视图。

## 7.3 来源管理

来源管理是本系统的重要组成部分，需支持：

- 查看来源 URL
- 查看来源类型
- 查看最后同步时间
- 查看同步状态
- 手动刷新来源
- 记录失败原因

## 7.4 同步刷新

同步刷新流程如下：

1. 用户触发刷新
2. 后端根据来源配置重新拉取数据
3. 若数据未变更，则更新同步时间
4. 若数据变更，则重新解析并覆盖原有课程表记录
5. 记录本次同步状态

***

## 8. 数据源接入设计

系统支持多类型 URL 数据源接入。为保证后续扩展性，需要将“内容获取”和“内容解析”拆分设计。

## 8.1 数据源类型

建议定义以下来源类型：

```text
SourceType
- ICS
- JSON
- HTML
- UNKNOWN
```

判定方式包括：

- URL 后缀判断
- Content-Type 判断
- 响应头探测
- 原始内容探测

## 8.2 内容获取策略

内容获取层定义统一抽象：

```text
FetchStrategy
- fetch(url, options)
```

具体实现为：

- DirectFetchStrategy
- ProxyFetchStrategy

### DirectFetchStrategy

适用于：

- Android 前端调用后端后，由后端直接请求目标 URL
- 目标地址访问规则简单的场景

### ProxyFetchStrategy

适用于：

- Web 端受 CORS 限制的场景
- 目标站需要特殊 Header(如果有Header返回交由人工验证）
- 需要集中缓存和频率控制的场景

代理层建议由后端统一实现，而不是让前端自行拼接代理 URL。

## 8.3 解析器体系

为适配不同来源，后端 parser 模块设计统一接口：

```text
TimetableImporter
- canHandle(sourceContext)
- parse(rawSource)
```

建议实现以下导入器：

- IcsImporter
- JsonApiImporter
- GenericHtmlImporter
- SchoolSpecificImporter

各导入器职责如下：

- `IcsImporter`：解析 `.ics` 数据
- `JsonApiImporter`：解析返回 JSON 的课表接口
- `GenericHtmlImporter`：解析结构较简单的 HTML 页面
- `SchoolSpecificImporter`：针对具体学校页面结构进行定制化解析

该设计能保证后续新增学校时不破坏现有系统结构。

***

## 9. 领域模型设计

领域模型是系统的数据核心，所有来源数据最终都必须转换为统一领域模型。

## 9.1 用户 User

若作业要求完整信息系统，建议保留用户实体。

核心字段：

- id
- username
- passwordHash
- nickname
- createdAt
- updatedAt

## 9.2 学期 Term

核心字段：

- id
- userId
- name
- startDate
- endDate
- totalWeeks
- timezone

## 9.3 课程 Course

核心字段：

- id
- timetableId
- title
- teacher
- locationText
- color
- remark

## 9.4 课次 CourseSession

该实体表示课程规则，而非某一次具体上课事件。

核心字段：

- id
- courseId
- weekday
- startSection
- endSection
- startWeek
- endWeek
- weekType
- note

## 9.5 节次 TimeSlot

核心字段：

- id
- termId
- sectionIndex
- startTime
- endTime

## 9.6 课程表 Timetable

核心字段：

- id
- userId
- termId
- sourceId
- title
- createdAt
- updatedAt

## 9.7 数据来源 TimetableSource

核心字段：

- id
- userId
- originalUrl
- finalUrl
- sourceType
- importerKey
- etag
- lastModified
- lastSyncedAt
- syncStatus
- errorMessage

## 9.8 同步记录 SyncRecord

核心字段：

- id
- sourceId
- status
- message
- startedAt
- finishedAt

***

## 10. 数据库设计

本系统数据库采用 PostgreSQL。数据库设计围绕用户、课程表、课程、课次、来源和同步记录展开。

## 10.1 数据表设计

建议包含以下主要数据表：

- `users`
- `terms`
- `timetables`
- `courses`
- `course_sessions`
- `time_slots`
- `timetable_sources`
- `sync_records`

## 10.2 表关系设计

主要关系如下：

- 一个用户可拥有多个学期
- 一个用户可拥有多个课程表
- 一个课程表绑定一个来源
- 一个课程表包含多门课程
- 一门课程包含多个课次
- 一个学期包含多条节次时间配置
- 一个来源对应多条同步记录

关系结构可表示为：

```text
User 1 --- n Term
User 1 --- n Timetable
Timetable 1 --- n Course
Course 1 --- n CourseSession
Term 1 --- n TimeSlot
Timetable 1 --- 1 TimetableSource
TimetableSource 1 --- n SyncRecord
```

## 10.3 数据库存储特点

数据库主要承担以下职责：

- 保存课程表结构化数据
- 保存来源与同步元信息
- 支持按学期、星期、课程、来源进行查询
- 为后端刷新逻辑提供基础支撑

***

## 11. 接口设计

后端对前端提供 RESTful API，建议分为以下几组。

## 11.1 导入接口

### `POST /api/import`

功能：

- 提交 URL 导入课程表

请求示例：

```json
{
  "url": "https://example.com/timetable.ics"
}
```

返回内容：

- 导入结果
- 课程表基础信息
- 课程数量
- 解析状态

### `POST /api/import/preview`

功能：

- 执行预解析但暂不正式保存

适用于：

- 前端导入预览页

## 11.2 课程表接口

### `GET /api/timetables`

获取课程表列表。

### `GET /api/timetables/:id`

获取某一课程表详情。

### `GET /api/timetables/:id/week`

获取指定课程表的周视图数据。

### `GET /api/timetables/:id/day`

获取指定课程表的日视图数据。

## 11.3 来源接口

### `GET /api/sources`

获取来源列表。

### `GET /api/sources/:id`

获取来源详情。

### `POST /api/sources/:id/refresh`

刷新某一来源。

## 11.4 导出接口

### `GET /api/timetables/:id/export/ics`

导出指定课程表为 `.ics` 文件。

***

## 12. 前端页面设计

前端建议包含以下核心页面：

- 登录页
- 导入页
- 导入预览页
- 课程表首页
- 日视图页
- 周视图页
- 来源管理页
- 设置页

## 12.1 登录页

若作业要求完整信息系统，建议保留基本登录功能。

## 12.2 导入页

功能：

- 输入 URL
- 发起导入
- 显示加载状态
- 显示错误信息

## 12.3 导入预览页

功能：

- 展示解析后的课程结构
- 确认导入结果
- 选择保存或取消

## 12.4 课程表首页

功能：

- 展示当前学期课程表
- 提供跳转到日视图、周视图和来源管理

## 12.5 来源管理页

功能：

- 查看来源信息
- 手动刷新
- 查看同步状态与错误信息

***

## 13. 前后端交互设计

前后端交互遵循以下原则：

- 前端不直接处理复杂解析逻辑
- 前端不直接连接数据库
- 后端负责统一数据结构输出
- 前端仅消费标准化接口数据

标准交互流程为：

1. 前端发起请求
2. 后端执行业务逻辑
3. 后端返回结构化 JSON
4. 前端将 JSON 转换为 ViewModel 或领域对象
5. 页面渲染

这种设计可避免前端承担过多业务复杂度，也更符合课程设计中前后端分离系统的要求。

***

## 14. 缓存与性能设计

为提升系统稳定性和性能，建议采用以下策略：

## 14.1 Redis 缓存

缓存内容包括：

- URL 探测结果
- 远程内容短时缓存
- 导入预览缓存
- 刷新状态缓存

## 14.2 数据库索引

建议对以下字段建立索引：

- `userId`
- `termId`
- `sourceId`
- `weekday`
- `lastSyncedAt`
- `syncStatus`

## 14.3 异步任务

对于耗时较长的导入和刷新任务，可设计为异步任务执行，避免接口长时间阻塞。

***

## 15. 安全设计

## 15.1 URL 安全

由于系统支持通过 URL 获取远程内容，必须防止 SSRF 风险。后端需限制：

- 只允许 `http` 和 `https`
- 禁止访问本地地址和内网地址
- 禁止访问 `localhost`
- 限制请求超时
- 限制响应大小

## 15.2 接口安全

若系统包含用户登录，需加入：

- JWT 鉴权
- 密码加密存储
- 基本访问控制

## 15.3 输入校验

前后端都应对 URL、参数、字段长度进行校验，避免脏数据进入系统。

***

## 16. 可扩展性设计

系统后续可从以下几个方向扩展：

- 新增学校专用 Importer
- 增加更多导入源类型
- 增加课程提醒功能
- 增加导出和订阅能力
- 增加用户之间的课表共享功能
- 天气提醒（联网搜索当前天气为用户提供穿衣提醒）
- 更新课表功能对与一些课表更新提供一键更新功能

当前设计通过统一的 Importer 接口、统一领域模型和模块化后端结构，为上述扩展保留了足够空间。

***

## 17. 实施建议

从实现顺序看，建议按照以下技术路径推进：

1. 建立前端基础框架与页面路由
2. 建立后端基础模块与数据库模型
3. 完成导入接口、来源接口、课程表接口
4. 完成 `.ics` 导入器
5. 完成前端导入页、预览页、课程表页
6. 完成来源管理与刷新能力
7. 追加 JSON / HTML 导入器
8. 追加 `.ics` 导出能力

这样可以先满足作业对“前后端数据库、多端 Web 项目”的完整性要求，再逐步增强系统能力。

***

## 18. 结论

GreenStone 课程表系统采用 Flutter 前端、NestJS 后端、PostgreSQL 数据库的前后端分离架构，面向 Web 与 Android 双端提供统一课程表服务。系统以课程表统一领域模型为核心，以导入、解析、存储、查询、刷新为主线，具备完整的信息系统基本构成，符合课程设计中“前端 + 后端 + 数据库 + 多端 Web 项目”的建设要求。

***

## 参考项目

- [junyilou/python-ical-timetable](https://github.com/junyilou/python-ical-timetable)
- [diredocks/fdzc-ical-gen-cf-worker](https://github.com/diredocks/fdzc-ical-gen-cf-worker)

