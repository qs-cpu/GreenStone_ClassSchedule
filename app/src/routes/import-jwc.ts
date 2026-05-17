import { Elysia, t } from 'elysia'
import { schools } from '../parsers/schools'
import { db, schema } from '../db'
import { AuthService } from '../services/auth.service'
import { TermService } from '../services/term.service'
import { redis } from '../lib/redis'

const authService = new AuthService()
const termService = new TermService()

function generateCaptchaId(): string {
  return crypto.randomUUID()
}

export const importJwcRoutes = new Elysia()
  .group('/api/import-jwc', (app) =>
    app
      .get(
        '/captcha',
        async ({ query, set }: any) => {
          console.log('[DEBUG] captcha route hit')

          const { school } = query as { school: string }
          console.log('[DEBUG] school:', school)

          const fetcher = schools[school]
          if (!fetcher) {
            set.status = 400
            return { error: `不支持的学校: ${school}` }
          }

          try {
            const result = await fetcher.initLogin()
            const captchaId = generateCaptchaId()

            const sessionData = {
              loginURL: result.loginURL,
              cookies: result.cookies,
            }

            await redis.setex(`captcha:${captchaId}`, 300, JSON.stringify(sessionData))
            console.log('[DEBUG] captchaId:', captchaId)

            return {
              captchaId,
              captchaImage: result.captchaImage,
            }
          } catch (error) {
            set.status = 500
            const message = error instanceof Error ? error.message : String(error)
            return { error: message }
          }
        },
        {
          query: t.Object({
            school: t.String(),
          }),
        }
      )
      .post(
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

          const { school, username, password, year, semester, captchaId, captcha } = body as {
            school: string
            username: string
            password: string
            year: number
            semester: string
            captchaId: string
            captcha: string
          }

          const fetcher = schools[school]
          if (!fetcher) {
            set.status = 400
            return { error: `不支持的学校: ${school}` }
          }

          try {
            const sessionDataRaw = await redis.get(`captcha:${captchaId}`)
            if (!sessionDataRaw) {
              set.status = 400
              return { error: '验证码已过期，请重新获取' }
            }

            const sessionData = JSON.parse(sessionDataRaw)
            await redis.del(`captcha:${captchaId}`)

            await fetcher.completeLogin(
              sessionData.loginURL,
              captcha,
              sessionData.cookies,
              username,
              password
            )

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

            const courseIndexMap = new Map<string, string>()
            let currentIndex = 1

            for (const c of courses) {
              if (!courseIndexMap.has(c.title)) {
                courseIndexMap.set(c.title, currentIndex.toString())
                currentIndex++
              }

              const color = courseIndexMap.get(c.title)

              const [course] = await db.insert(schema.courses)
                .values({
                  timetableId: timetable.id,
                  title: c.title,
                  teacher: c.teacher,
                  color,
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
            captchaId: t.String(),
            captcha: t.String(),
          }),
        }
      )
  )