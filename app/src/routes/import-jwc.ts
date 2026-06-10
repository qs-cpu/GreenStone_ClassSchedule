import { Elysia, t } from 'elysia'
import { FdzcFetcher } from '../parsers/schools/fdzc.fetcher'
import { db, schema } from '../db'
import { Buffer } from 'node:buffer'
import { getUserFromRequest } from '../middleware/auth'
import { insertCourses } from '../services/timetable-writer'

const CAPTCHA_TTL_MS = 5 * 60 * 1000
const captchaSessions = new Map<string, { fetcher: FdzcFetcher; createdAt: number }>()

function normalizeSemester(semester: string) {
  if (semester === '1' || semester === '上') return '上'
  if (semester === '2' || semester === '下') return '下'
  return semester
}

function cleanupCaptchaSessions() {
  const now = Date.now()
  for (const [id, session] of captchaSessions) {
    if (now - session.createdAt > CAPTCHA_TTL_MS) {
      captchaSessions.delete(id)
    }
  }
}

function createSchoolFetcher(school: string) {
  if (school === 'fdzc') {
    return new FdzcFetcher()
  }
  return null
}

async function resolveImportOwner(userId: string, termId: string | undefined, year: number, semester: string) {
  const normalizedSemester = normalizeSemester(semester)
  const termName = `${year}年${normalizedSemester}`

  if (termId) {
    return { userId, termId }
  }

  const existingTerms = await db.select().from(schema.terms)
  let term = existingTerms.find((item) => item.userId === userId && item.name === termName)

  if (!term) {
    const startDate = normalizedSemester === '上' ? new Date(`${year}-09-01`) : new Date(`${year}-02-20`)
    const endDate = normalizedSemester === '上' ? new Date(`${year + 1}-01-20`) : new Date(`${year}-07-10`)
    ;[term] = await db.insert(schema.terms)
      .values({
        userId: userId,
        name: termName,
        startDate,
        endDate,
      })
      .returning()
  }

  return { userId: userId, termId: term.id }
}

export const importJwcRoutes = new Elysia()
  .group('/api/import-jwc', (app) =>
    app.get(
      '/captcha',
      async ({ query, set }) => {
        cleanupCaptchaSessions()

        const school = query.school
        const fetcher = createSchoolFetcher(school)
        if (!fetcher) {
          set.status = 400
          return { error: `Unsupported school: ${school}` }
        }

        try {
          const image = await fetcher.fetchCaptcha()
          const captchaId = crypto.randomUUID()
          captchaSessions.set(captchaId, { fetcher, createdAt: Date.now() })
          return {
            captchaId,
            captchaImage: `data:image/bmp;base64,${Buffer.from(image).toString('base64')}`,
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
      async ({ body, request, set }) => {
        const user = await getUserFromRequest(request)
        if (!user) {
          set.status = 401
          return { error: '未授权，请先登录' }
        }

        const { username, password, year, semester, captchaId, captcha } = body as {
          username: string
          password: string
          year: number
          semester: string
          captchaId?: string
          captcha?: string
        }

        try {
          const normalizedSemester = normalizeSemester(semester)

          if (!captchaId || !captcha) {
            set.status = 400
            return { error: '请先获取验证码' }
          }

          const session = captchaSessions.get(captchaId)
          if (!session) {
            set.status = 400
            return { error: '验证码已过期，请刷新验证码后重试' }
          }

          await session.fetcher.loginWithCaptcha(username, password, captcha)
          captchaSessions.delete(captchaId)

          const fetcher = session.fetcher
          const courses = await fetcher.fetchTimetable(year, normalizedSemester)
          const beginDate = await fetcher.fetchBeginDate(year, normalizedSemester)
          const owner = await resolveImportOwner(user.userId, undefined, year, normalizedSemester)

          const [timetable] = await db.insert(schema.timetables)
            .values({
              userId: owner.userId,
              termId: owner.termId,
              title: `${year}年${normalizedSemester}课程表`,
            })
            .returning()

          const coursesCount = await insertCourses(timetable.id, courses)

          set.status = 201
          return {
            timetable,
            coursesCount,
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
          username: t.String(),
          password: t.String(),
          year: t.Number(),
          semester: t.String(),
          captchaId: t.Optional(t.String()),
          captcha: t.Optional(t.String()),
        }),
      }
    )
  )
