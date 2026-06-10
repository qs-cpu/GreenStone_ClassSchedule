import { drizzle } from 'drizzle-orm/bun-sqlite'
import { Database } from 'bun:sqlite'
import * as schema from './schema'
import { config } from '../config'

const sqlite = new Database(config.database.path)
sqlite.exec('PRAGMA journal_mode=WAL')
sqlite.exec('PRAGMA foreign_keys=ON')

// 首次启动自动建表
const tableExists = sqlite
  .prepare("SELECT name FROM sqlite_master WHERE type='table' AND name='users'")
  .get()
if (!tableExists) {
  sqlite.exec(`
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL UNIQUE,
      password_hash TEXT,
      nickname TEXT,
      role TEXT NOT NULL DEFAULT 'user',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE terms (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      name TEXT NOT NULL,
      start_date TEXT NOT NULL,
      end_date TEXT NOT NULL,
      total_weeks INTEGER NOT NULL DEFAULT 20,
      timezone TEXT NOT NULL DEFAULT 'Asia/Shanghai',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE timetables (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      term_id TEXT NOT NULL REFERENCES terms(id),
      source_id TEXT UNIQUE,
      title TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE courses (
      id TEXT PRIMARY KEY,
      timetable_id TEXT NOT NULL REFERENCES timetables(id),
      title TEXT NOT NULL,
      teacher TEXT,
      color TEXT,
      remark TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE course_sessions (
      id TEXT PRIMARY KEY,
      course_id TEXT NOT NULL REFERENCES courses(id),
      weekday INTEGER NOT NULL,
      start_section INTEGER NOT NULL,
      end_section INTEGER NOT NULL,
      start_week INTEGER NOT NULL DEFAULT 1,
      end_week INTEGER NOT NULL DEFAULT 20,
      week_type TEXT NOT NULL DEFAULT 'all',
      note TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE locations (
      id TEXT PRIMARY KEY,
      session_id TEXT NOT NULL REFERENCES course_sessions(id),
      location_text TEXT NOT NULL,
      building TEXT,
      room TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE timetable_sources (
      id TEXT PRIMARY KEY,
      user_id TEXT NOT NULL REFERENCES users(id),
      original_url TEXT NOT NULL,
      final_url TEXT,
      source_type TEXT NOT NULL DEFAULT 'UNKNOWN',
      importer_key TEXT,
      etag TEXT,
      last_modified TEXT,
      last_synced_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'idle',
      error_message TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE sync_records (
      id TEXT PRIMARY KEY,
      source_id TEXT NOT NULL REFERENCES timetable_sources(id),
      status TEXT NOT NULL,
      message TEXT,
      started_at TEXT NOT NULL,
      finished_at TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
    CREATE TABLE time_slots (
      id TEXT PRIMARY KEY,
      term_id TEXT NOT NULL REFERENCES terms(id),
      section_index INTEGER NOT NULL,
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    );
  `)
  console.log('数据库表已自动创建')
}

export const db = drizzle(sqlite, { schema })

export { schema }
