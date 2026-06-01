import { Elysia } from "elysia";
import { cors } from '@elysiajs/cors'
import { timetableRoutes } from './routes/timetable'
import { importRoutes } from './routes/import'
import { sourceRoutes } from './routes/source'
import { importJwcRoutes } from './routes/import-jwc'
import { authRoutes } from './routes/auth'
import { adminUserRoutes } from './routes/admin/users'

const app = new Elysia()
  .use(cors())
  .use(authRoutes)
  .use(timetableRoutes)
  .use(importRoutes)
  .use(sourceRoutes)
  .use(importJwcRoutes)
  .use(adminUserRoutes)
  .get('/', () => 'GreenStone API')
  .listen(3001)

console.log(`Server running at ${app.server?.url}`)

export type App = typeof app
