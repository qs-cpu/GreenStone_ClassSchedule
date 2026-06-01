import { Elysia, t } from 'elysia'
import { TimetableService } from '../services/timetable.service'
import { getUserFromRequest } from '../middleware/auth'

const timetableService = new TimetableService()

export const timetableRoutes = new Elysia()
  .group('/api/timetables', (app) =>
    app
      .get('/', async ({ request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        return timetableService.findAll(user.userId)
      })
      .get('/:id', async ({ params, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        const timetable = await timetableService.findOne(params.id, user.userId)
        if (!timetable) {
          set.status = 404
          return { error: '课程表不存在' }
        }
        return timetable
      })
      .get('/:id/week/:weekNo', async ({ params, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        const weekNo = parseInt(params.weekNo)
        const weekView = await timetableService.getWeekView(params.id, weekNo, user.userId)
        if (!weekView) {
          set.status = 404
          return { error: '课程表不存在' }
        }
        return weekView
      })
      .get('/:id/day', async ({ params, query, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }
        const date = new Date(query.date)
        const dayView = await timetableService.getDayView(params.id, date, user.userId)
        if (!dayView) {
          set.status = 404
          return { error: '课程表不存在' }
        }
        return dayView
      })
  )
