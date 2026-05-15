import { Elysia, t } from 'elysia'
import { schools } from '../parsers/schools'
import { db, schema } from '../db'
import { AuthService } from '../services/auth.service'
import { TermService } from '../services/term.service'

const authService = new AuthService()
const termService = new TermService()

export const importJwcRoutes = new Elysia()
  .group('/api/import-jwc', (app) =>
    app.post(
      '/',
      async ({ body, set, request }: any) => {
        console.log('[DEBUG] import-jwc route hit')
        
        const authHeader = request.headers.get('Authorization')
        console.log('[DEBUG] authHeader:', authHeader)
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }

        const token = authHeader.slice(7)
        console.log('[DEBUG] token:', token)
        
        const payload = await authService.verifyToken(token)
        console.log('[DEBUG] payload:', payload)
        
        if (!payload) {
          set.status = 401
          return { error: '无效的 token' }
        }

        const userId = payload.userId
        console.log('[DEBUG] userId:', userId)

        const { school, username, password, year, semester } = body as {
          school: string
          username: string
          password: string
          year: number
          semester: string
        }

        const fetcher = schools[school]
        if (!fetcher) {
          set.status = 400
          return { error: `Unsupported school: ${school}` }
        }

        try {
          await fetcher.login(username, password)
          const courses = await fetcher.fetchTimetable(year, semester)
          const beginDate = await fetcher.fetchBeginDate(year, semester)

          const term = await termService.findOrCreateTerm(userId, year, semester)
          console.log('[DEBUG] term:', term)

          const [timetable] = await db.insert(schema.timetables)
            .values({
              userId,
              termId: term.id,
              title: `${year}年${semester}学期课程表`,
            })
            .returning()

          for (const c of courses) {
            const [course] = await db.insert(schema.courses)
              .values({
                timetableId: timetable.id,
                title: c.title,
                teacher: c.teacher,
              })
              .returning()

            for (const s of c.sessions) {
              const weekType = ['all', 'odd', 'even'].includes(s.weekType ?? '')
                ? s.weekType as 'all' | 'odd' | 'even'
                : 'all'

              const [session] = await db.insert(schema.courseSessions)
                .values({
                  courseId: course.id,
                  weekday: s.weekday,
                  startSection: s.startSection,
                  endSection: s.endSection,
                  startWeek: s.startWeek,
                  endWeek: s.endWeek,
                  weekType,
                })
                .returning()

              if (s.location) {
                await db.insert(schema.locations)
                  .values({
                    sessionId: session.id,
                    locationText: s.location,
                  })
                  .execute()
              }
            }
          }

          set.status = 201
          return {
            timetable,
            coursesCount: courses.length,
            beginDate,
          }
        } catch (error) {
          set.status = 500
          const message = error instanceof Error ? error.message : String(error)
          return { error: message }
        }
      },
      {
        body: t.Object({
          school: t.String(),
          username: t.String(),
          password: t.String(),
          year: t.Number(),
          semester: t.String(),
        }),
      }
    )
  )