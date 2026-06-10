# API 参考

Base URL: `http://localhost:3001/api`

所有接口使用 `Content-Type: application/json`。需认证的端点通过
`Authorization: Bearer <token>` 头传递，401 时前端自动清除 token 并踢出登录。

响应格式：

```json
// 成功
{ "...": "各端点格式不同" }

// 错误
HTTP 4xx/5xx + { "error": "中文错误描述" }
```

---

## 健康检查

```
GET /api/health

→ 200 { "status": "ok" }
```

无需认证。用于连通性检测和 Docker 健康探测。

---

## 认证

### 注册

```
POST /api/auth/register
{ "username": "string (3-50)", "password": "string (≥6)", "nickname?": "string" }

→ 201 {
    "user": {
      "id": "<uuid>",
      "username": "string",
      "nickname": "string",
      "createdAt": "ISO8601"
    }
  }
  409 { "error": "用户名已存在" }
  500 { "error": "注册失败" }
```

注册成功后需要调用 `/api/auth/login` 获取 token。

### 登录

```
POST /api/auth/login
{ "username": "string (3-50)", "password": "string (≥6)" }

→ 200 {
    "token": "<jwt>",
    "user": {
      "id": "<uuid>",
      "username": "string",
      "nickname": "string",
      "role": "user | admin",
      "createdAt": "ISO8601"
    }
  }
  401 { "error": "用户名或密码错误" }
  500 { "error": "登录失败" }
```

登录成功后，token 存入 `FlutterSecureStorage`，用户信息存入 `SharedPreferences`。前端自动将 token 附加到后续所有非 auth 请求。


---

## 课程表

> 需要 `Authorization: Bearer <token>`。

### 课表列表

```
GET /api/timetables

→ 200 [
    {
      "id": "<uuid>",
      "userId": "<uuid>",
      "termId": "<uuid>",
      "sourceId": "<uuid> | null",
      "title": "2025年上学期课程表",
      "createdAt": "ISO8601",
      "updatedAt": "ISO8601"
    }
  ]
  401 { "error": "未授权，请先登录" }
```

按创建时间倒序排列。

### 课表详情

```
GET /api/timetables/:id

→ 200 {
    "id": "<uuid>",
    "title": "...",
    "courses": [
      {
        "id": "<uuid>",
        "title": "高等数学",
        "teacher": "张三",
        "color": "#FFB3BA",
        "remark": null,
        "sessions": [
          {
            "id": "<uuid>",
            "weekday": 1,
            "startSection": 1,
            "endSection": 2,
            "startWeek": 1,
            "endWeek": 16,
            "weekType": "all",
            "note": null,
            "location": "教学楼A-301"
          }
        ]
      }
    ]
  }
  401 未授权
  404 { "error": "课程表不存在" }
```

### 周视图

```
GET /api/timetables/:id/week/:weekNo

→ 200 {
    "1": [  // 周一
      { "id": "...", "title": "高等数学", "sessions": [...] }
    ],
    "2": [  // 周二
      ...
    ]
    ...
  }
  401 未授权
  404 { "error": "课程表不存在" }
```

根据 `session.startWeek ≤ weekNo ≤ session.endWeek` 过滤课程，同时按 `weekType` 排除不合单双周的课次。

### 日视图

```
GET /api/timetables/:id/day?date=2025-03-17

→ 200 [
    { "id": "...", "title": "高等数学", "sessions": [...] }
  ]
  401 未授权
  404 { "error": "课程表不存在" }
```

按日期计算星期几和周次，返回当天有课的课程。

---

## 导入

### URL 导入

```
POST /api/import
Authorization: Bearer <token>
{ "url": "https://example.com/schedule.ics", "termId?": "<uuid>" }

→ 201 {
    "id": "<uuid>",
    "userId": "<uuid>",
    "termId": "<uuid>",
    "title": "导入的课表",
    "createdAt": "ISO8601",
    "updatedAt": "ISO8601"
  }
  400 URL 不合法
  401 未授权
  500 不支持的格式 / 解析失败
```

流程：URL 白名单校验 → 下载内容 → 检测类型（ICS/JSON）→ 选择解析器 → 解析 → 写入数据库（timetable → courses → sessions → locations → sources）。

### 教务系统导入

此端点实现教务系统直连抓取课表，目前仅支持福州大学至诚学院（`fdzc`）。

#### 获取验证码

```
GET /api/import-jwc/captcha?school=fdzc

→ 200 {
    "captchaId": "<uuid>",
    "captchaImage": "data:image/bmp;base64,..."
  }
  400 { "error": "Unsupported school: xxx" }
  500 { "error": "无法解析教务系统登录地址" }
```

无需认证。验证码有效期 5 分钟，存储在服务端内存 `Map` 中。

#### 导入课程表

```
POST /api/import-jwc
Authorization: Bearer <token>
{
  "school": "fdzc",
  "username": "学号",
  "password": "密码",
  "year": 2025,
  "semester": "上",         // "上" | "下" | "1" | "2"
  "captchaId?": "<uuid>",  // 提供则走手动验证码流程
  "captcha?": "1234"       // 4 位验证码
}

→ 201 {
    "timetable": { "id": "...", "title": "2025年上学期课程表", ... },
    "coursesCount": 12,
    "beginDate": [2025, 2, 24]
  }
  400 { "error": "Unsupported school" }
  400 { "error": "验证码已过期，请刷新验证码后重试" }
  401 未授权
  500 { "error": "教务系统登录失败，请检查账号、密码和验证码" }
```

流程：
1. 如果提供 `captchaId` + `captcha`：使用已有 session 登录
2. 否则：fetcher 自动获取验证码 → 自动识别（XOR 字模）或抛错
3. 教务系统登录 → 抓取课表 HTML → HTMLRewriter 解析
4. 获取学期开始日期 → 创建/复用 term → 写入课表

---

## 数据来源

> 需要 `Authorization: Bearer <token>`。

### 来源列表

```
GET /api/sources

→ 200 [
    {
      "id": "<uuid>",
      "userId": "<uuid>",
      "originalUrl": "https://...",
      "sourceType": "ICS",
      "syncStatus": "success",
      "lastSyncedAt": "ISO8601",
      ...
    }
  ]
  401 未授权
```

### 来源详情

```
GET /api/sources/:id

→ 200 {
    "id": "...",
    "originalUrl": "...",
    "syncRecords": [
      {
        "id": "...",
        "status": "success",
        "message": null,
        "startedAt": "ISO8601",
        "finishedAt": "ISO8601"
      }
    ]
  }
  401 未授权
```

最近 10 条同步记录，按开始时间倒序。

### 触发同步

```
POST /api/sources/:id/sync

→ 200 { ...syncRecord }
  401 未授权
  500 同步失败
```

重新拉取原始 URL 内容（带 ETag/Last-Modified），更新来源和同步记录状态。

---

## 管理员

> 需要 `Authorization: Bearer <token>` + `role == "admin"`。

### 用户列表

```
GET /api/admin/users?page=1&pageSize=20&search=<keyword>

→ 200 {
    "users": [
      {
        "id": "<uuid>",
        "username": "string",
        "nickname": "string",
        "role": "user | admin",
        "createdAt": "ISO8601"
      }
    ],
    "total": 42,
    "page": 1,
    "pageSize": 20
  }
  401 未授权
  403 非管理员
```

搜索为用户名模糊匹配。

### 用户详情

```
GET /api/admin/users/:id

→ 200 {
    "id": "...",
    "username": "...",
    "nickname": "...",
    "role": "...",
    "timetableCount": 3,
    "createdAt": "...",
    "updatedAt": "..."
  }
  404 { "error": "用户不存在" }
```

### 创建用户

```
POST /api/admin/users
{ "username": "string (3-50)", "password": "string (≥6)", "nickname?": "string", "role?": "user | admin" }

→ 201 { "user": { ... } }
  409 { "error": "用户名已存在" }
```

密码使用 `bcryptjs` 哈希（10 轮）。

### 更新用户

```
PUT /api/admin/users/:id
{ "nickname?": "...", "role?": "user | admin", "password?": "新密码" }

→ 200 { "user": { ... } }
  404 { "error": "用户不存在" }
  500 { "error": "更新用户失败" }
```

仅更新提供的字段。

### 删除用户

```
DELETE /api/admin/users/:id

→ 200 { "message": "用户已删除" }
  400 { "error": "不能删除最后一个管理员" }
  404 { "error": "用户不存在" }
  500 { "error": "删除用户失败" }
```

级联删除（事务内）：`locations → course_sessions → courses → timetables → time_slots → terms → sync_records → timetable_sources → users`。

### 统计概览

```
GET /api/admin/users/stats/overview

→ 200 {
    "totalUsers": 42,
    "adminUsers": 2,
    "totalTimetables": 128
  }
```

---

## Flutter 前端 API 封装

前端通过 `core/network/api_client.dart` 中的 `ApiEndpoints` 类统一管理端点：

| 常量/方法 | 完整路径 |
|-----------|---------|
| `register` | `POST /api/auth/register` |
| `login` | `POST /api/auth/login` |
| `importUrl` | `POST /api/import` |
| `importJwc` | `POST /api/import-jwc` |
| `jwcCaptcha(school)` | `GET /api/import-jwc/captcha?school=` |
| `timetables` | `GET /api/timetables` |
| `timetableDetail(id)` | `GET /api/timetables/:id` |
| `timetableWeek(id, weekNo)` | `GET /api/timetables/:id/week/:weekNo` |
| `timetableDay(id)` | `GET /api/timetables/:id/day` |
| `sources` | `GET /api/sources` |
| `sourceDetail(id)` | `GET /api/sources/:id` |
| `sourceSync(id)` | `POST /api/sources/:id/sync` |
| `adminUsers` | `GET /api/admin/users` |
| `adminUserDetail(id)` | `GET /api/admin/users/:id` |
| `adminUserStats` | `GET /api/admin/users/stats/overview` |
