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
    path: process.env.DATABASE_PATH || 'data/greenstone.db',
  },
  app: {
    port: parseInt(process.env.PORT || '3001'),
  },
  jwt: {
    secret: jwtSecret,
    expiresIn: '7d',
  },
}
