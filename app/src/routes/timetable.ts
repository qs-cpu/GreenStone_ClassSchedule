import { Elysia, t } from 'elysia'
import { TimetableService } from '../services/timetable.service'

const timetableService = new TimetableService()

export const timetableRoutes = new Elysia()
  .group('/api/timetables', (app) =>
    app
      .get('/', async () => {
        return timetableService.findAll()
      })
      .get('/:id', async ({ params }) => {
        return timetableService.findOne(params.id)
      })
      .get('/:id/week/:weekNo', async ({ params }) => {
        const weekNo = parseInt(params.weekNo)
        return timetableService.getWeekView(params.id, weekNo)
      })
      .get('/:id/day', async ({ params, query }) => {
        const date = new Date(query.date)
        return timetableService.getDayView(params.id, date)
      })
  )