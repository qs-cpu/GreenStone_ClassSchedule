import { Elysia } from "elysia";
import { cors } from '@elysiajs/cors'
import { join, normalize } from 'node:path'
import { timetableRoutes } from './routes/timetable'
import { importRoutes } from './routes/import'
import { sourceRoutes } from './routes/source'
import { importJwcRoutes } from './routes/import-jwc'
import { authRoutes } from './routes/auth'
import { adminUserRoutes } from './routes/admin/users'
import { config } from './config'

const publicDir = process.env.PUBLIC_DIR || './public'

async function serveWeb(pathname: string) {
  const requestedPath = pathname === '/' ? '/index.html' : pathname
  const safePath = normalize(requestedPath).replace(/^\.\.(\/|\\|$)/, '')
  const file = Bun.file(join(publicDir, safePath))

  if (await file.exists()) {
    return new Response(file)
  }

  return new Response(Bun.file(join(publicDir, 'index.html')))
}

const app = new Elysia()
  .use(cors())
  .use(authRoutes)
  .use(timetableRoutes)
  .use(importRoutes)
  .use(sourceRoutes)
  .use(importJwcRoutes)
  .use(adminUserRoutes)
  .get('/', () => serveWeb('/'))
  .get('/*', ({ path }) => serveWeb(path))
  .listen(config.app.port)

console.log(`Server running at ${app.server?.url}`)

export type App = typeof app
