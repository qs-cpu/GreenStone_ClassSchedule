import { db, schema } from '../db'
import { desc, eq, and, inArray } from 'drizzle-orm'

export class TimetableService {
  async findAll(userId: string) {
    return db.select().from(schema.timetables)
      .where(eq(schema.timetables.userId, userId))
      .orderBy(desc(schema.timetables.createdAt))
      .execute()
  }

  async findOne(id: string, userId: string) {
    const timetable = await db.select().from(schema.timetables)
      .where(and(
        eq(schema.timetables.id, id),
        eq(schema.timetables.userId, userId)
      ))
      .execute()

    if (!timetable[0]) return null

    const courses = await db.select().from(schema.courses)
      .where(eq(schema.courses.timetableId, id))
      .execute()

    if (courses.length === 0) {
      return { ...timetable[0], courses: [] }
    }

    const courseIds = courses.map(c => c.id)

    const sessions = await db.select().from(schema.courseSessions)
      .where(inArray(schema.courseSessions.courseId, courseIds))
      .execute()

    const sessionIds = sessions.map(s => s.id)

    const locations = sessionIds.length > 0
      ? await db.select().from(schema.locations)
          .where(inArray(schema.locations.sessionId, sessionIds))
          .execute()
      : []

    const locationBySession = new Map<string, string | null>()
    for (const loc of locations) {
      locationBySession.set(loc.sessionId, loc.locationText)
    }

    const sessionsByCourse = new Map<string, typeof sessions>()
    for (const s of sessions) {
      const list = sessionsByCourse.get(s.courseId) ?? []
      list.push(s)
      sessionsByCourse.set(s.courseId, list)
    }

    const coursesWithSessions = courses.map(course => ({
      ...course,
      sessions: (sessionsByCourse.get(course.id) ?? []).map(s => ({
        ...s,
        location: locationBySession.get(s.id) ?? null,
      })),
    }))

    return { ...timetable[0], courses: coursesWithSessions }
  }

  async getWeekView(id: string, weekNo: number, userId: string) {
    const timetable = await this.findOne(id, userId)
    if (!timetable) return null

    const courses = timetable.courses.filter((c) =>
      c.sessions.some((s) => s.startWeek <= weekNo && s.endWeek >= weekNo)
    )

    const weekData: Record<number, typeof courses> = {}
    for (const course of courses) {
      for (const session of course.sessions) {
        if (session.weekType && session.weekType !== 'all') {
          if (session.weekType === 'odd' && weekNo % 2 === 0) continue
          if (session.weekType === 'even' && weekNo % 2 === 1) continue
        }
        const weekday = session.weekday
        if (!weekData[weekday]) weekData[weekday] = []
        weekData[weekday].push(course)
      }
    }

    return weekData
  }

  async getDayView(id: string, date: Date, userId: string) {
    const timetable = await this.findOne(id, userId)
    if (!timetable) return null

    const weekday = date.getDay() || 7
    const weekNo = this.getWeekNumber(date)

    const courses = timetable.courses.filter((c) =>
      c.sessions.some(
        (s) => s.weekday === weekday && s.startWeek <= weekNo && s.endWeek >= weekNo
      )
    )

    return courses
  }

  private getWeekNumber(date: Date): number {
    const start = new Date('2024-01-01')
    const diff = date.getTime() - start.getTime()
    return Math.floor(diff / (7 * 24 * 60 * 60 * 1000)) + 1
  }
}
