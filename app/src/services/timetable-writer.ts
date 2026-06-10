import { db, schema } from '../db'
import type { ParsedCourse } from '../parsers/importers/importer.interface'

/** Shared helper: insert courses, sessions, and locations for a timetable. */
export async function insertCourses(
  timetableId: string,
  courses: ParsedCourse[],
): Promise<number> {
  let count = 0
  for (const c of courses) {
    const [course] = await db.insert(schema.courses)
      .values({
        timetableId,
        title: c.title,
        teacher: c.teacher,
      })
      .returning()

    for (const s of c.sessions) {
      const weekType = ['all', 'odd', 'even'].includes(s.weekType ?? '')
        ? (s.weekType as 'all' | 'odd' | 'even')
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
    count++
  }
  return count
}
