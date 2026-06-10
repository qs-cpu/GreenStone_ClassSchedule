import { sqliteTable, text, integer } from 'drizzle-orm/sqlite-core'
import { relations } from 'drizzle-orm'

// 用户
export const users = sqliteTable('users', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  username: text('username', { length: 50 }).notNull().unique(),
  passwordHash: text('password_hash'),
  nickname: text('nickname', { length: 100 }),
  role: text('role', { enum: ['user', 'admin'] }).default('user').notNull(),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 学期
export const terms = sqliteTable('terms', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: text('user_id').references(() => users.id).notNull(),
  name: text('name', { length: 100 }).notNull(),
  startDate: text('start_date').notNull(),
  endDate: text('end_date').notNull(),
  totalWeeks: integer('total_weeks').default(20).notNull(),
  timezone: text('timezone', { length: 50 }).default('Asia/Shanghai').notNull(),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 节次时间
export const timeSlots = sqliteTable('time_slots', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  termId: text('term_id').references(() => terms.id).notNull(),
  sectionIndex: integer('section_index').notNull(),
  startTime: text('start_time', { length: 10 }).notNull(),
  endTime: text('end_time', { length: 10 }).notNull(),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 课程表
export const timetables = sqliteTable('timetables', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: text('user_id').references(() => users.id).notNull(),
  termId: text('term_id').references(() => terms.id).notNull(),
  sourceId: text('source_id').unique(),
  title: text('title', { length: 100 }).notNull(),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 课程
export const courses = sqliteTable('courses', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  timetableId: text('timetable_id').references(() => timetables.id).notNull(),
  title: text('title', { length: 100 }).notNull(),
  teacher: text('teacher', { length: 50 }),
  color: text('color', { length: 20 }),
  remark: text('remark'),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 课次
export const courseSessions = sqliteTable('course_sessions', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  courseId: text('course_id').references(() => courses.id).notNull(),
  weekday: integer('weekday').notNull(),         // 1-7
  startSection: integer('start_section').notNull(),
  endSection: integer('end_section').notNull(),
  startWeek: integer('start_week').default(1).notNull(),
  endWeek: integer('end_week').default(20).notNull(),
  weekType: text('week_type', { enum: ['all', 'odd', 'even'] }).default('all').notNull(),
  note: text('note'),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 上课地点
export const locations = sqliteTable('locations', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  sessionId: text('session_id').references(() => courseSessions.id).notNull(),
  locationText: text('location_text', { length: 100 }).notNull(),
  building: text('building', { length: 50 }),
  room: text('room', { length: 30 }),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 数据来源
export const timetableSources = sqliteTable('timetable_sources', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  userId: text('user_id').references(() => users.id).notNull(),
  originalUrl: text('original_url').notNull(),
  finalUrl: text('final_url'),
  sourceType: text('source_type', { length: 20 }).default('UNKNOWN').notNull(),
  importerKey: text('importer_key', { length: 50 }),
  etag: text('etag'),
  lastModified: text('last_modified'),
  lastSyncedAt: text('last_synced_at'),
  syncStatus: text('sync_status', { length: 20 }).default('idle').notNull(),
  errorMessage: text('error_message'),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
})

// 同步记录
export const syncRecords = sqliteTable('sync_records', {
  id: text('id').primaryKey().$defaultFn(() => crypto.randomUUID()),
  sourceId: text('source_id').references(() => timetableSources.id).notNull(),
  status: text('status', { length: 20 }).notNull(),
  message: text('message'),
  startedAt: text('started_at').notNull().$defaultFn(() => new Date().toISOString()),
  finishedAt: text('finished_at'),
  createdAt: text('created_at').notNull().$defaultFn(() => new Date().toISOString()),
  updatedAt: text('updated_at').notNull().$defaultFn(() => new Date().toISOString()),
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
