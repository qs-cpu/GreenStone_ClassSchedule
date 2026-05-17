import { db, schema } from '../db'
import { eq } from 'drizzle-orm'
import { toTimetableDTO, toTimetableListDTO, TimetableDTO, TimetableListDTO } from '../dto/timetable.dto'

export class TimetableService {
  async findAll(): Promise<TimetableListDTO[]> {
    const timetables = await db.select().from(schema.timetables).execute()
    return toTimetableListDTO(timetables)
  }

  async findOne(id: string): Promise<TimetableDTO | null> {
    const timetable = await db.select().from(schema.timetables)
      .where(eq(schema.timetables.id, id))
      .execute()

    if (!timetable[0]) return null

    const courses = await db.select().from(schema.courses)
      .where(eq(schema.courses.timetableId, id))
      .execute()

    const sessionsMap = new Map<string, any[]>()
    const locationsMap = new Map<string, any[]>()

    for (const course of courses) {
      const sessions = await db.select().from(schema.courseSessions)
        .where(eq(schema.courseSessions.courseId, course.id))
        .execute()
      sessionsMap.set(course.id, sessions)

      for (const session of sessions) {
        const locations = await db.select().from(schema.locations)
          .where(eq(schema.locations.sessionId, session.id))
          .execute()
        locationsMap.set(session.id, locations)
      }
    }

    return toTimetableDTO(timetable[0], courses, sessionsMap, locationsMap)
  }

  async getWeekView(id: string, weekNo: number): Promise<Record<number, any[]> | null> {
    const timetable = await this.findOne(id)
    if (!timetable) return null

    const weekData: Record<number, any[]> = {}

    for (const course of timetable.courses) {
      for (const session of course.sessions) {
        if (session.startWeek > weekNo || session.endWeek < weekNo) continue
        
        if (session.weekType && session.weekType !== 'all') {
          if (session.weekType === 'odd' && weekNo % 2 === 0) continue
          if (session.weekType === 'even' && weekNo % 2 === 1) continue
        }

        const weekday = session.weekday
        if (!weekData[weekday]) weekData[weekday] = []

        const existingCourse = weekData[weekday].find((c: any) => c.id === course.id)
        if (!existingCourse) {
          weekData[weekday].push(course)
        }
      }
    }

    return weekData
  }

  async getDayView(id: string, date: Date): Promise<any[] | null> {
    const [timetable] = await db.select().from(schema.timetables)
      .where(eq(schema.timetables.id, id))
      .execute()

    if (!timetable) return null

    const [term] = await db.select().from(schema.terms)
      .where(eq(schema.terms.id, timetable.termId))
      .execute()

    const startDate = term?.startDate || new Date('2024-08-26')

    const weekday = date.getDay() || 7
    const weekNo = this.getWeekNumber(date, startDate)

    const coursesData = await this.findOne(id)
    if (!coursesData) return null

    const result = []

    for (const course of coursesData.courses) {
      const matchingSessions = course.sessions.filter(
        (s) => s.weekday === weekday && s.startWeek <= weekNo && s.endWeek >= weekNo &&
        (s.weekType === 'all' || 
         (s.weekType === 'odd' && weekNo % 2 === 1) ||
         (s.weekType === 'even' && weekNo % 2 === 0))
      )

      if (matchingSessions.length > 0) {
        result.push({
          id: course.id,
          title: course.title,
          teacher: course.teacher,
          color: course.color,
          sessions: matchingSessions,
        })
      }
    }

    return result
  }

  private getWeekNumber(date: Date, startDate: Date): number {
    const diff = date.getTime() - startDate.getTime()
    return Math.floor(diff / (7 * 24 * 60 * 60 * 1000)) + 1
  }
}