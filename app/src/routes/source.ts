import { Elysia } from 'elysia'
import { SourceService } from '../services/source.service'
import { SyncService } from '../services/sync.service'
import { getUserFromRequest } from '../middleware/auth'

const sourceService = new SourceService()
const syncService = new SyncService()

export const sourceRoutes = new Elysia()
  .group('/api/sources', (app) =>
    app
      .get('/', async ({ request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        return sourceService.findAll(user.userId)
      })
      .get('/:id', async ({ params, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        return sourceService.findOne(params.id, user.userId)
      })
      .post('/:id/sync', async ({ params, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        return syncService.syncSource(params.id, user.userId)
      })
  )