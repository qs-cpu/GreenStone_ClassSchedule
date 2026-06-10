import { Database } from 'bun:sqlite'
import { drizzle } from 'drizzle-orm/bun-sqlite'

/** Create an in-memory SQLite database with the app schema for testing. */
export function createTestDb() {
  const sqlite = new Database(':memory:')
  sqlite.exec('PRAGMA journal_mode=WAL')
  sqlite.exec('PRAGMA foreign_keys=ON')

  // Create all tables from schema
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

  return { sqlite, db: drizzle(sqlite) }
}

/** Insert a test user and return its ID */
export function insertTestUser(sqlite: Database) {
  const id = crypto.randomUUID()
  sqlite.run(
    'INSERT INTO users (id, username, password_hash, nickname, role, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
    [id, 'testuser', '$2a$10$aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', 'Test', 'user', now(), now()]
  )
  return id
}

export function now() {
  return new Date().toISOString()
}
