import { db, schema } from '../db'
import { desc, eq, and } from 'drizzle-orm'

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

    const coursesWithSessions = await Promise.all(
      courses.map(async (course) => {
        const sessions = await db.select().from(schema.courseSessions)
          .where(eq(schema.courseSessions.courseId, course.id))

        const sessionsWithLocations = await Promise.all(
          sessions.map(async (session) => {
            const locations = await db.select().from(schema.locations)
              .where(eq(schema.locations.sessionId, session.id))

            return {
              ...session,
              location: locations[0]?.locationText ?? null,
            }
          })
        )

        return { ...course, sessions: sessionsWithLocations }
      })
    )

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
