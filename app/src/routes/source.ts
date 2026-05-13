import { Elysia } from 'elysia'
import { SourceService } from '../services/source.service'
import { SyncService } from '../services/sync.service'

const sourceService = new SourceService()
const syncService = new SyncService()

export const sourceRoutes = new Elysia()
  .group('/api/sources', (app) =>
    app
      .get('/', async () => {
        return sourceService.findAll()
      })
      .get('/:id', async ({ params }) => {
        return sourceService.findOne(params.id)
      })
      .post('/:id/sync', async ({ params }) => {
        return syncService.syncSource(params.id)
      })
  )