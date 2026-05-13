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