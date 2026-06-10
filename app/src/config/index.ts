function requireEnv(key: string): string {
  const value = process.env[key]
  if (!value) {
    console.error(`FATAL: environment variable ${key} is required`)
    process.exit(1)
  }
  return value
}

const jwtSecret = process.env.JWT_SECRET
if (!jwtSecret || jwtSecret === 'greenstone-secret-key') {
  console.error(
    'FATAL: JWT_SECRET is not set or is using the insecure default.\n' +
    'Set JWT_SECRET to a random 64-character hex string:\n' +
    '  export JWT_SECRET=$(openssl rand -hex 32)'
  )
  process.exit(1)
}

export const config = {
  database: {
    url: requireEnv('DATABASE_URL'),
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
  },
  app: {
    port: parseInt(process.env.PORT || '3001'),
  },
  jwt: {
    secret: jwtSecret,
    expiresIn: '7d',
  },
}
