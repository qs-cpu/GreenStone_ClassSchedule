import { Elysia } from "elysia";
import { cors } from '@elysiajs/cors'
import { existsSync } from 'node:fs'
import { join, normalize } from 'node:path'
import { timetableRoutes } from './routes/timetable'
import { importRoutes } from './routes/import'
import { sourceRoutes } from './routes/source'
import { importJwcRoutes } from './routes/import-jwc'
import { authRoutes } from './routes/auth'
import { adminUserRoutes } from './routes/admin/users'
import { config } from './config'

const NODE_ENV = process.env.NODE_ENV || 'development'
const isDev = NODE_ENV !== 'production'

const publicDir = process.env.PUBLIC_DIR || './public'
const hasPublicDir = existsSync(publicDir)

async function serveWeb(pathname: string) {
  if (!hasPublicDir) return new Response('Not Found', { status: 404 })

  const requestedPath = pathname === '/' ? '/index.html' : pathname
  const safePath = normalize(requestedPath).replace(/^\.\.(\/|\\|$)/, '')
  const file = Bun.file(join(publicDir, safePath))

  if (await file.exists()) {
    return new Response(file)
  }

  return new Response(Bun.file(join(publicDir, 'index.html')))
}

const app = new Elysia()
  .use(cors({ origin: true }))
  .onRequest(({ request }) => {
    // 毫秒 start 时间戳存到请求上下文
    ;(request as any)._ts = Date.now()
  })
  .onAfterResponse(({ request, set, response }) => {
    if (!isDev) return
    const ts = (request as any)._ts
    const dur = ts ? Date.now() - ts : 0
    const status = set.status ?? response?.status
    const icon = status && status < 400 ? '✓' : '✗'
    console.log(
      `  ${icon} ${request.method} ${new URL(request.url).pathname}  ${status ?? '?'}  ${dur}ms`
    )
  })
  .get('/api/health', () => ({ status: 'ok' }))
  .use(authRoutes)
  .use(timetableRoutes)
  .use(importRoutes)
  .use(sourceRoutes)
  .use(importJwcRoutes)
  .use(adminUserRoutes)

if (hasPublicDir) {
  app.get('/', () => serveWeb('/'))
  app.get('/*', ({ path }) => serveWeb(path))
}

app.listen(config.app.port)

console.log(`Server running at ${app.server?.url}`)

export type App = typeof app
