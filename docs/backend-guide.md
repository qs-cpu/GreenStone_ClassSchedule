# Bun + Elysia + Drizzle 后端开发指南

## 一、开发环境准备

### 1.1 依赖安装

确保本地已安装以下工具：

- Bun (>= 1.x)
- PostgreSQL (>= 14.x)
- Redis (>= 6.x)

### 1.2 初始化项目

```bash
# 创建 Elysia 项目
bun create elysia app

# 进入项目目录
cd app

# 安装核心依赖
bun add elysia @elysiajs/cors @elysiajs/static @elysiajs/html

# 安装 Drizzle ORM
bun add drizzle-orm pg
bun add -d drizzle-kit

# 安装 pg 类型定义（解决 TypeScript 报错）
bun add -d @types/pg

# 安装其他常用依赖
bun add axios
```

## 二、项目结构

### 2.1 目录规划

根据 design.md 第 183-202 行设计：

```
src/
├── index.ts                 # 入口文件
├── app.ts                  # Elysia 应用配置
├── db/
│   ├── index.ts           # 数据库连接
│   ├── schema.ts          # 数据模型
│   └── migrations/       # 迁移文件
├── routes/
│   ├── timetable.ts     # 课程表路由
│   ├── import.ts      # 导入路由
│   └── source.ts     # 来源路由
├── services/
│   ├── timetable.service.ts
│   ├── import.service.ts
│   ├── source.service.ts
│   ├── parser.service.ts
│   └── sync.service.ts
├── parsers/
│   ├── strategies/
│   │   ├── fetcher.strategy.ts
│   │   ├── direct.fetcher.ts
│   │   └── proxy.fetcher.ts
│   └── importers/
│       ├── importer.interface.ts
│       ├── ics.importer.ts
│       ├── json.importer.ts
│       └── html.importer.ts
├── dto/
│   ├── import.dto.ts
│   └── common.dto.ts
├── lib/
│   └── redis.ts          # Redis 客户端
└── config/
    └── index.ts         # 配置
```

### 2.2 创建项目命令

```bash
# 初始化项目
mkdir app && cd app
bun init -y

# 安装依赖
bun add elysia @elysiajs/cors @elysiajs/static axios
bun add drizzle-orm pg
bun add -d drizzle-kit
```

## 三、数据库建模

### 3.1 Drizzle Schema 设计

创建 `src/db/schema.ts`：

```typescript
import { pgTable, text, timestamp, integer, varchar, uuid, pgEnum } from 'drizzle-orm/pg-core'
import { relations } from 'drizzle-orm'

export const weekTypeEnum = pgEnum('week_type', ['all', 'odd', 'even'])

// 用户
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  username: varchar('username', { length: 50 }).notNull().unique(),
  passwordHash: text('password_hash'),
  nickname: varchar('nickname', { length: 100 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 学期
export const terms = pgTable('terms', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id).notNull(),
  name: varchar('name', { length: 100 }).notNull(),
  startDate: timestamp('start_date', { withTimezone: true }).notNull(),
  endDate: timestamp('end_date', { withTimezone: true }).notNull(),
  totalWeeks: integer('total_weeks').default(20).notNull(),
  timezone: varchar('timezone', { length: 50 }).default('Asia/Shanghai').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 节次时间
export const timeSlots = pgTable('time_slots', {
  id: uuid('id').defaultRandom().primaryKey(),
  termId: uuid('term_id').references(() => terms.id).notNull(),
  sectionIndex: integer('section_index').notNull(),
  startTime: varchar('start_time', { length: 10 }).notNull(),
  endTime: varchar('end_time', { length: 10 }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 课程表
export const timetables = pgTable('timetables', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id).notNull(),
  termId: uuid('term_id').references(() => terms.id).notNull(),
  sourceId: uuid('source_id').unique(),
  title: varchar('title', { length: 100 }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 课程
export const courses = pgTable('courses', {
  id: uuid('id').defaultRandom().primaryKey(),
  timetableId: uuid('timetable_id').references(() => timetables.id).notNull(),
  title: varchar('title', { length: 100 }).notNull(),
  teacher: varchar('teacher', { length: 50 }),
  color: varchar('color', { length: 20 }),
  remark: text('remark'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 课次
export const courseSessions = pgTable('course_sessions', {
  id: uuid('id').defaultRandom().primaryKey(),
  courseId: uuid('course_id').references(() => courses.id).notNull(),
  weekday: integer('weekday').notNull(),         // 1-7
  startSection: integer('start_section').notNull(),
  endSection: integer('end_section').notNull(),
  startWeek: integer('start_week').default(1).notNull(),
  endWeek: integer('end_week').default(20).notNull(),
  weekType: weekTypeEnum('week_type').default('all').notNull(),
  note: text('note'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 上课地点
export const locations = pgTable('locations', {
  id: uuid('id').defaultRandom().primaryKey(),
  sessionId: uuid('session_id').references(() => courseSessions.id).notNull(),
  locationText: varchar('location_text', { length: 100 }).notNull(),
  building: varchar('building', { length: 50 }),
  room: varchar('room', { length: 30 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 数据来源
export const timetableSources = pgTable('timetable_sources', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').references(() => users.id).notNull(),
  originalUrl: text('original_url').notNull(),
  finalUrl: text('final_url'),
  sourceType: varchar('source_type', { length: 20 }).default('UNKNOWN').notNull(),
  importerKey: varchar('importer_key', { length: 50 }),
  etag: text('etag'),
  lastModified: text('last_modified'),
  lastSyncedAt: timestamp('last_synced_at', { withTimezone: true }),
  syncStatus: varchar('sync_status', { length: 20 }).default('idle').notNull(),
  errorMessage: text('error_message'),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 同步记录
export const syncRecords = pgTable('sync_records', {
  id: uuid('id').defaultRandom().primaryKey(),
  sourceId: uuid('source_id').references(() => timetableSources.id).notNull(),
  status: varchar('status', { length: 20 }).notNull(),
  message: text('message'),
  startedAt: timestamp('started_at', { withTimezone: true }).defaultNow().notNull(),
  finishedAt: timestamp('finished_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
})

// 关系定义
export const usersRelations = relations(users, ({ many }) => ({
  terms: many(terms),
  timetables: many(timetables),
  sources: many(timetableSources),
}))

export const termsRelations = relations(terms, ({ one, many }) => ({
  user: one(users, { fields: [terms.userId], references: [users.id] }),
  timetables: many(timetables),
  timeSlots: many(timeSlots),
}))

export const timetablesRelations = relations(timetables, ({ one, many }) => ({
  user: one(users, { fields: [timetables.userId], references: [users.id] }),
  term: one(terms, { fields: [timetables.termId], references: [terms.id] }),
  source: one(timetableSources, { fields: [timetables.sourceId], references: [timetableSources.id] }),
  courses: many(courses),
}))

export const coursesRelations = relations(courses, ({ one, many }) => ({
  timetable: one(timetables, { fields: [courses.timetableId], references: [timetables.id] }),
  sessions: many(courseSessions),
}))

export const courseSessionsRelations = relations(courseSessions, ({ one }) => ({
  course: one(courses, { fields: [courseSessions.courseId], references: [courses.id] }),
}))

export const locationsRelations = relations(locations, ({ one }) => ({
  session: one(courseSessions, { fields: [locations.sessionId], references: [courseSessions.id] }),
}))

export const timetableSourcesRelations = relations(timetableSources, ({ one, many }) => ({
  user: one(users, { fields: [timetableSources.userId], references: [users.id] }),
  syncRecords: many(syncRecords),
}))

export const syncRecordsRelations = relations(syncRecords, ({ one }) => ({
  source: one(timetableSources, { fields: [syncRecords.sourceId], references: [timetableSources.id] }),
}))

// 类型导出
export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert
export type Term = typeof terms.$inferSelect
export type Timetable = typeof timetables.$inferSelect
export type Course = typeof courses.$inferSelect
export type CourseSession = typeof courseSessions.$inferSelect
export type Location = typeof locations.$inferSelect
export type TimetableSource = typeof timetableSources.$inferSelect
export type SyncRecord = typeof syncRecords.$inferSelect
```

### 3.2 数据库连接

创建 `src/db/index.ts`：

```typescript
import { drizzle } from 'drizzle-orm/node-postgres'
import { Pool } from 'pg'
import * as schema from './schema'

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

export const db = drizzle(pool, { schema })

export { schema }
```

### 3.3 数据库迁移

```bash
# 创建迁移配置 drizzle.config.ts（放在 app/ 根目录）
import { defineConfig } from "drizzle-kit"
export default defineConfig({
schema: "./src/db/schema.ts",
out: "./src/db/migrations",
dialect: "postgresql",
dbCredentials: { url: process.env.DATABASE_URL! }
})

# 执行迁移
docker run -d --name greenstone-db -e POSTGRES_PASSWORD=password -e POSTGRES_DB=greenstone -p 5432:5432 -v $(pwd)/data:/var/lib/postgresql/data postgres:14
export DATABASE_URL="postgresql://postgres:password@localhost:5432/greenstone" && bunx drizzle-kit push
docker exec -it greenstone-db psql -U postgres -d greenstone
```

## 四、Elysia 应用配置

### 4.1 入口文件

```typescript
// src/index.ts
import { Elysia } from 'elysia'
import { cors } from '@elysiajs/cors'
import { timetableRoutes } from './routes/timetable'
import { importRoutes } from './routes/import'
import { sourceRoutes } from './routes/source'

const app = new Elysia()
  .use(cors())
  .use(timetableRoutes)
  .use(importRoutes)
  .use(sourceRoutes)
  .get('/', () => 'GreenStone API')
  .listen(3000)

console.log(`Server running at ${app.server?.url}`)

export type App = typeof app
```

### 4.2 路由定义

```typescript
// src/routes/import.ts
import { Elysia, t } from 'elysia'
import { ImportService } from '../services/import.service'
import { validateUrl } from '../utils/url.validator'

export const importRoutes = new Elysia()
  .group('/api/import', (app) =>
    app.post(
      '/',
      async ({ body, set }) => {
        const { url } = body as { url: string }
        
        validateUrl(url)
        
        const result = await new ImportService().import(url)
        
        set.status = 201
        return result
      },
      {
        body: t.Object({
          url: t.String({ format: 'uri' }),
        }),
      }
    )
  )
```

## 五、核心服务实现

### 5.1 导入服务

```typescript
// src/services/import.service.ts
import axios from 'axios'
import { db, schema } = require('../db')
import { detectSourceType } from '../parsers/strategies/detector'
import { IcsImporter } from '../parsers/importers/ics.importer'
import { JsonImporter } from '../parsers/importers/json.importer'

export class ImportService {
  private importers = [new IcsImporter(), new JsonImporter()]

  async import(url: string, termId?: string) {
    // 1. 校验 URL
    const validatedUrl = this.validateUrl(url)

    // 2. 获取内容
    const response = await axios.get(validatedUrl, {
      timeout: 10000,
      maxContentLength: 5 * 1024 * 1024,
    })

    // 3. 识别来源类型
    const sourceType = detectSourceType(validatedUrl, response.data)

    // 4. 选择解析器
    const importer = this.importers.find((i) => i.canHandle(sourceType, response.data))
    if (!importer) {
      throw new Error(`Unsupported source type: ${sourceType}`)
    }

    // 5. 解析
    const parsed = await importer.parse(response.data)

    // 6. 保存到数据库
    const [timetable] = await db.insert(schema.timetables)
      .values({
        userId: 'default-user',
        termId: termId || 'default-term',
        title: parsed.title,
      })
      .returning()

    // 创建课程
    for (const c of parsed.courses) {
      const [course] = await db.insert(schema.courses)
        .values({
          timetableId: timetable.id,
          title: c.title,
          teacher: c.teacher,
          locationText: c.location,
        })
        .returning()

      // 创建课次
      for (const s of c.sessions) {
        await db.insert(schema.courseSessions)
          .values({
            courseId: course.id,
            weekday: s.weekday,
            startSection: s.startSection,
            endSection: s.endSection,
            startWeek: s.startWeek,
            endWeek: s.endWeek,
            weekType: s.weekType,
          })
          .execute()
      }
    }

    // 创建来源
    await db.insert(schema.timetableSources)
      .values({
        id: timetable.sourceId,
        userId: 'default-user',
        originalUrl: validatedUrl,
        sourceType,
        importerKey: importer.constructor.name,
        timetableId: timetable.id,
      })
      .execute()

    return timetable
  }

  private validateUrl(url: string): string {
    const parsed = new URL(url)
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      throw new Error('Only HTTP/HTTPS allowed')
    }
    return url
  }
}
```

### 5.2 课程表服务

```typescript
// src/services/timetable.service.ts
import { db, schema } = require('../db')
import { eq } from 'drizzle-orm'

export class TimetableService {
  async findAll() {
    return db.select().from(schema.timetables)
      .leftJoin(schema.courses, eq(schema.courses.timetableId, schema.timetables.id))
      .execute()
  }

  async findOne(id: string) {
    const timetable = await db.select().from(schema.timetables)
      .where(eq(schema.timetables.id, id))
      .execute()

    const courses = await db.select().from(schema.courses)
      .where(eq(schema.courses.timetableId, id))
      .execute()

    const coursesWithSessions = await Promise.all(
      courses.map(async (course) => {
        const sessions = await db.select().from(schema.courseSessions)
          .where(eq(schema.courseSessions.courseId, course.id))
        return { ...course, sessions }
      })
    )

    return { ...timetable[0], courses: coursesWithSessions }
  }

  async getWeekView(id: string, weekNo: number) {
    const timetable = await this.findOne(id)
    if (!timetable) return null

    const courses = timetable.courses.filter((c) =>
      c.sessions.some((s) => s.startWeek <= weekNo && s.endWeek >= weekNo)
    )

    const weekData: Record<number, typeof courses> = {}
    for (const course of courses) {
      for (const session of course.sessions) {
        if (session.weekType && session.weekType !== 'all') {
          if (session.weekType === 'odd' && weekNo % 2 === 0) continue
          if (session.weekType === 'even' && weekNo % 2 === 1) continue
        }
        const weekday = session.weekday
        if (!weekData[weekday]) weekData[weekday] = []
        weekData[weekday].push(course)
      }
    }

    return weekData
  }

  async getDayView(id: string, date: Date) {
    const timetable = await this.findOne(id)
    if (!timetable) return null

    const weekday = date.getDay() || 7
    const weekNo = this.getWeekNumber(date)

    const courses = timetable.courses.filter((c) =>
      c.sessions.some(
        (s) => s.weekday === weekday && s.startWeek <= weekNo && s.endWeek >= weekNo
      )
    )

    return courses
  }

  private getWeekNumber(date: Date): number {
    const start = new Date('2024-01-01')
    const diff = date.getTime() - start.getTime()
    return Math.floor(diff / (7 * 24 * 60 * 60 * 1000)) + 1
  }
}
```

### 5.3 来源服务

```typescript
// src/services/source.service.ts
import { db, schema } = require('../db')
import { desc } from 'drizzle-orm'

export class SourceService {
  async findAll() {
    return db.select().from(schema.timetableSources).execute()
  }

  async findOne(id: string) {
    const [source] = await db.select().from(schema.timetableSources)
      .where(eq(schema.timetableSources.id, id))
      .execute()

    const records = await db.select().from(schema.syncRecords)
      .where(eq(schema.syncRecords.sourceId, id))
      .orderBy(desc(schema.syncRecords.startedAt))
      .limit(10)
      .execute()

    return { ...source, syncRecords: records }
  }
}
```

### 5.4 同步服务

```typescript
// src/services/sync.service.ts
import { db, schema } = require('../db')
import { eq } from 'drizzle-orm'
import axios from 'axios'

export class SyncService {
  async syncSource(sourceId: string) {
    const [source] = await db.select().from(schema.timetableSources)
      .where(eq(schema.timetableSources.id, sourceId))
      .execute()

    if (!source) {
      throw new Error('Source not found')
    }

    // 更新状态为 syncing
    await db.update(schema.timetableSources)
      .set({ syncStatus: 'syncing', updatedAt: new Date() })
      .where(eq(schema.timetableSources.id, sourceId))
      .execute()

    // 记录开始
    const [record] = await db.insert(schema.syncRecords)
      .values({
        sourceId,
        status: 'running',
        startedAt: new Date(),
      })
      .returning()

    try {
      // 重新拉取
      const response = await axios.get(source.originalUrl, {
        timeout: 10000,
      })

      // 更新来源
      await db.update(schema.timetableSources)
        .set({
          syncStatus: 'success',
          lastSyncedAt: new Date(),
          etag: response.headers.etag,
          lastModified: response.headers['last-modified'],
          updatedAt: new Date(),
        })
        .where(eq(schema.timetableSources.id, sourceId))
        .execute()

      // 更新记录
      await db.update(schema.syncRecords)
        .set({
          status: 'success',
          finishedAt: new Date(),
        })
        .where(eq(schema.syncRecords.id, record.id))
        .execute()

      return record
    } catch (error) {
      // 记录失败
      await db.update(schema.syncRecords)
        .set({
          status: 'failed',
          message: error.message,
          finishedAt: new Date(),
        })
        .where(eq(schema.syncRecords.id, record.id))
        .execute()

      await db.update(schema.timetableSources)
        .set({
          syncStatus: 'failed',
          errorMessage: error.message,
          updatedAt: new Date(),
        })
        .where(eq(schema.timetableSources.id, sourceId))
        .execute()

      throw error
    }
  }
}
```

## 六、解析器实现

### 6.1 来源类型识别

```typescript
// src/parsers/strategies/detector.ts
export type SourceType = 'ICS' | 'JSON' | 'HTML' | 'UNKNOWN'

export function detectSourceType(url: string, content: string): SourceType {
  // 按 URL 后缀判断
  if (url.endsWith('.ics') || url.endsWith('.ical')) {
    return 'ICS'
  }
  if (url.endsWith('.json')) {
    return 'JSON'
  }

  // 按内容判断
  if (content.includes('BEGIN:VCALENDAR')) {
    return 'ICS'
  }
  if (content.trim().startsWith('{') || content.trim().startsWith('[')) {
    return 'JSON'
  }

  return 'UNKNOWN'
}
```

### 6.2 内容获取策略

```typescript
// src/parsers/strategies/direct.fetcher.ts
import axios from 'axios'

export interface FetchResult {
  content: string
  contentType?: string
  etag?: string
  lastModified?: string
}

export class DirectFetcher {
  async fetch(url: string): Promise<FetchResult> {
    const response = await axios.get(url, {
      timeout: 10000,
      maxContentLength: 5 * 1024 * 1024,
    })

    return {
      content: response.data,
      contentType: response.headers['content-type'],
      etag: response.headers.etag,
      lastModified: response.headers['last-modified'],
    }
  }
}
```

```typescript
// src/parsers/strategies/proxy.fetcher.ts
import { redis } from '../../lib/redis'
import { DirectFetcher, FetchResult } from './direct.fetcher'

export class ProxyFetcher {
  private direct = new DirectFetcher()

  async fetch(url: string): Promise<FetchResult> {
    const cached = await redis.get(`proxy:${url}`)
    if (cached) {
      return JSON.parse(cached)
    }

    const result = await this.direct.fetch(url)

    await redis.set(`proxy:${url}`, JSON.stringify(result), {
      EX: 300,
    })

    return result
  }
}
```

### 6.3 解析器接口

```typescript
// src/parsers/importers/importer.interface.ts
import { SourceType } from '../strategies/detector'

export interface ParsedCourse {
  title: string
  teacher?: string
  location?: string
  sessions: {
    weekday: number
    startSection: number
    endSection: number
    startWeek: number
    endWeek: number
    weekType?: string
  }[]
}

export interface ParsedTimetable {
  title: string
  courses: ParsedCourse[]
}

export interface ITimetableImporter {
  canHandle(sourceType: SourceType, content: string): boolean
  parse(content: string): Promise<ParsedTimetable>
}
```

### 6.4 ICS 解析器

```typescript
// src/parsers/importers/ics.importer.ts
import { ITimetableImporter, ParsedTimetable } from './importer.interface'
import { SourceType } from '../strategies/detector'

export class IcsImporter implements ITimetableImporter {
  canHandle(sourceType: SourceType, content: string): boolean {
    return sourceType === 'ICS' || content.includes('BEGIN:VCALENDAR')
  }

  async parse(content: string): Promise<ParsedTimetable> {
    const events = this.parseIcs(content)
    const courses: ParsedTimetable['courses'] = []

    for (const event of events) {
      const course = courses.find((c) => c.title === event.summary)
      if (course) {
        course.sessions.push(this.mapToSession(event))
      } else {
        courses.push({
          title: event.summary,
          teacher: event.organizer,
          location: event.location,
          sessions: [this.mapToSession(event)],
        })
      }
    }

    return { title: 'Imported Timetable', courses }
  }

  private parseIcs(content: string) {
    const events: any[] = []
    const lines = content.split('\n')
    let current: any = null

    for (const line of lines) {
      if (line.startsWith('BEGIN:VEVENT')) {
        current = {}
      } else if (line.startsWith('END:VEVENT')) {
        if (current) events.push(current)
        current = null
      } else if (current) {
        const [key, ...valueParts] = line.split(':')
        const value = valueParts.join(':')
        if (key === 'SUMMARY') current.summary = value
        if (key === 'LOCATION') current.location = value
        if (key === 'ORGANIZER') current.organizer = value
        if (key.startsWith('DTSTART')) {
          current.start = this.parseDate(value)
        }
        if (key.startsWith('DTEND')) {
          current.end = this.parseDate(value)
        }
      }
    }

    return events
  }

  private parseDate(value: string): Date {
    const year = parseInt(value.slice(0, 4))
    const month = parseInt(value.slice(4, 6)) - 1
    const day = parseInt(value.slice(6, 8))
    return new Date(year, month, day)
  }

  private mapToSession(event: any) {
    const date = event.start
    const weekday = date.getDay() || 7

    return {
      weekday,
      startSection: 1,
      endSection: 2,
      startWeek: 1,
      endWeek: 20,
    }
  }
}
```

## 七、安全防护

### 7.1 URL 校验

```typescript
// src/utils/url.validator.ts
const FORBIDDEN_HOSTS = ['localhost', '127.0.0.1', '0.0.0.0', '::1']
const FORBIDDEN_PROTOCOLS = ['http:', 'https:']

export function validateUrl(url: string): void {
  const parsed = new URL(url)

  if (!FORBIDDEN_PROTOCOLS.includes(parsed.protocol)) {
    throw new Error('Only HTTP/HTTPS allowed')
  }

  if (FORBIDDEN_HOSTS.includes(parsed.hostname)) {
    throw new Error('Internal addresses not allowed')
  }
}
```

## 八、配置与环境

### 8.1 环境变量

创建 `.env` 文件：

```bash
# 数据库
DATABASE_URL="postgresql://user:password@localhost:5432/greenstone"

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# 应用
PORT=3000
NODE_ENV=development
```

### 8.2 类型安全配置

```typescript
// src/config/index.ts
export const config = {
  database: {
    url: process.env.DATABASE_URL!,
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT) || 6379,
  },
  app: {
    port: parseInt(process.env.PORT) || 3000,
  },
}
```

## 九、Redis 连接

```typescript
// src/lib/redis.ts
import Redis from 'ioredis'

export const redis = new Redis({
  host: process.env.REDIS_HOST || 'localhost',
  port: parseInt(process.env.REDIS_PORT) || 6379,
  lazyConnect: true,
})
```

## 十、测试

### 10.1 运行测试

```bash
# 运行测试
bun test

# 运行并监听
bun test --watch
```

### 10.2 API 测试示例

```typescript
import { describe, it, expect, beforeAll } from 'bun:test'
import { Elysia } from 'elysia'
import { importRoutes } from '../routes/import'

describe('Import API', () => {
  const app = new Elysia().use(importRoutes)

  it('should import timetable', async () => {
    const response = await app.handle(
      new Request('http://localhost/api/import', {
        method: 'POST',
        body: JSON.stringify({ url: 'https://example.com/timetable.ics' }),
        headers: { 'Content-Type': 'application/json' },
      })
    )

    expect(response.status).toBe(201)
  })
})
```

## 十一、部署

### 11.1 直接运行

```bash
# 开发模式
bun run src/index.ts

# 生产模式
bun run --production src/index.ts
```

### 11.2 Dockerfile

创建 `Dockerfile`：

```dockerfile
FROM oven/bun:1-alpine

WORKDIR /app

COPY package*.json ./
RUN bun install --frozen-lock

COPY . .

EXPOSE 3000

CMD ["bun", "run", "src/index.ts"]
```

### 11.3 Docker Compose

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/greenstone
      - REDIS_HOST=redis
    depends_on:
      - db
      - redis

  db:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: greenstone
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:6
    volumes:
      - redisdata:/data

volumes:
  pgdata:
  redisdata:
```

## 十二、开发步骤总结

| 步骤 | 任务 | 预计工作量 |
|------|------|----------|
| 1 | 初始化 Bun + Elysia 项目 | 30 分��� |
| 2 | 配置 Drizzle ORM 和数据库 | 1 小时 |
| 3 | 创建数据库 Schema 并迁移 | 2 小时 |
| 4 | 实现解析器（获取/解析器） | 3 小时 |
| 5 | 实现 import 接口 | 2 小时 |
| 6 | 实现 timetable 接口 | 1 小时 |
| 7 | 实现 source 接口 | 1 小时 |
| 8 | 实现 sync 刷新服务 | 2 小时 |
| 9 | 添加安全校验 | 1 小时 |
| 10 | 部署与调试 | 2 小时 |

## 十三、Prisma vs Drizzle 对比

| 特性 | Prisma | Drizzle |
|------|--------|--------|
| Bun 支持 | 需 Node.js >= 20.19 | ✅ 原生支持 |
| 体积 | ~60MB | ~5MB |
| 迁移 | 需额外工具 | 纯 SQL |
| 语法 | DSL | 类 SQL |
| 零运行时 | ❌ | ✅ |

---

如需更详细的某个模块实现，请告知。