import { drizzle } from 'drizzle-orm/bun-sqlite'
import { Database } from 'bun:sqlite'
import * as schema from './schema'

const dbPath = process.env.DATABASE_PATH || 'data/greenstone.db'

const sqlite = new Database(dbPath)
sqlite.exec('PRAGMA journal_mode=WAL')
sqlite.exec('PRAGMA foreign_keys=ON')

export const db = drizzle(sqlite, { schema })

export { schema }
