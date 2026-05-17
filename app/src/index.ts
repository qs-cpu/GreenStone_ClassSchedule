import { Elysia } from "elysia";
import { cors } from '@elysiajs/cors'
import { timetableRoutes } from './routes/timetable'
import { importRoutes } from './routes/import'
import { sourceRoutes } from './routes/source'
import { importJwcRoutes } from './routes/import-jwc'
import { authRoutes } from './routes/auth'

const app = new Elysia()
  .use(cors())
  .use(authRoutes)
  .use(timetableRoutes)
  .use(importRoutes)
  .use(sourceRoutes)
  .use(importJwcRoutes)
  .get('/', () => 'GreenStone API')
  .listen(3001)

console.log(`Server running at ${app.server?.url}`)

export type App = typeof app