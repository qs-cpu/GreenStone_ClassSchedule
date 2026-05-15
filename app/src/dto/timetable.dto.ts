export interface TimetableDTO {
  id: string
  title: string
  courses: CourseDTO[]
}

export interface CourseDTO {
  id: string
  title: string
  teacher: string | null
  color: string | null
  remark: string | null
  sessions: SessionDTO[]
}

export interface SessionDTO {
  id: string
  weekday: number
  startSection: number
  endSection: number
  startWeek: number
  endWeek: number
  weekType: string
  note: string | null
  location: string | null
}

export interface TimetableListDTO {
  id: string
  title: string
}

export function toTimetableDTO(
  timetable: any,
  courses: any[],
  sessionsMap: Map<string, any[]>,
  locationsMap: Map<string, any[]>
): TimetableDTO {
  return {
    id: timetable.id,
    title: timetable.title,
    courses: courses.map(course => toCourseDTO(course, sessionsMap, locationsMap)),
  }
}

export function toCourseDTO(
  course: any,
  sessionsMap: Map<string, any[]>,
  locationsMap: Map<string, any[]>
): CourseDTO {
  const sessions = sessionsMap.get(course.id) || []
  return {
    id: course.id,
    title: course.title,
    teacher: course.teacher,
    color: course.color,
    remark: course.remark,
    sessions: sessions.map(session => toSessionDTO(session, locationsMap)),
  }
}

export function toSessionDTO(session: any, locationsMap: Map<string, any[]>): SessionDTO {
  const locations = locationsMap.get(session.id) || []
  const locationText = locations.length > 0 ? locations[0].locationText : null
  return {
    id: session.id,
    weekday: session.weekday,
    startSection: session.startSection,
    endSection: session.endSection,
    startWeek: session.startWeek,
    endWeek: session.endWeek,
    weekType: session.weekType,
    note: session.note,
    location: locationText,
  }
}

export function toTimetableListDTO(timetables: any[]): TimetableListDTO[] {
  return timetables.map(t => ({
    id: t.id,
    title: t.title,
  }))
}