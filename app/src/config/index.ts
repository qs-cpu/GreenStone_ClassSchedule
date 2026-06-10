import { join, dirname } from 'node:path'
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs'
import { randomBytes } from 'node:crypto'

const DB_PATH = process.env.DATABASE_PATH || 'data/greenstone.db'

function resolveJwtSecret(): string {
  // Explicit env var takes priority
  if (process.env.JWT_SECRET && process.env.JWT_SECRET !== 'greenstone-secret-key') {
    return process.env.JWT_SECRET
  }

  // Auto-generate and persist next to the database file
  const dataDir = dirname(DB_PATH)
  const secretFile = join(dataDir, 'jwt_secret')

  if (!existsSync(dataDir)) {
    mkdirSync(dataDir, { recursive: true })
  }

  if (existsSync(secretFile)) {
    const existing = readFileSync(secretFile, 'utf-8').trim()
    if (existing) {
      console.log('JWT_SECRET 未设置，复用已生成的密钥')
      return existing
    }
  }

  const secret = randomBytes(32).toString('hex')
  writeFileSync(secretFile, secret, { mode: 0o600 })
  console.log('JWT_SECRET 未设置，已自动生成并保存')
  return secret
}

export const config = {
  database: {
    path: DB_PATH,
  },
  app: {
    port: parseInt(process.env.PORT || '3001'),
  },
  jwt: {
    secret: resolveJwtSecret(),
    expiresIn: '7d',
  },
}
