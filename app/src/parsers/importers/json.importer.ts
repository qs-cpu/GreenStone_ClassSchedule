import { ITimetableImporter, ParsedTimetable } from './importer.interface'
import { SourceType } from '../strategies/detector'

export class JsonImporter implements ITimetableImporter {
  canHandle(sourceType: SourceType, content: string): boolean {
    return sourceType === 'JSON' || content.trim().startsWith('{') || content.trim().startsWith('[')
  }

  async parse(content: string): Promise<ParsedTimetable> {
    const data = JSON.parse(content)

    let courses: any[]
    if (Array.isArray(data)) {
      courses = data
    } else if (data.courses && Array.isArray(data.courses)) {
      courses = data.courses
    } else {
      courses = [data]
    }

    return {
      title: data.title || 'Imported Timetable',
      courses: courses.map((c) => ({
        title: c.title,
        teacher: c.teacher,
        sessions: (c.sessions || [c]).map((s: any) => ({
          weekday: s.weekday || 1,
          startSection: s.startSection || 1,
          endSection: s.endSection || 2,
          startWeek: s.startWeek || 1,
          endWeek: s.endWeek || 20,
          weekType: s.weekType || 'all',
          location: s.location,
        })),
      })),
    }
  }
}