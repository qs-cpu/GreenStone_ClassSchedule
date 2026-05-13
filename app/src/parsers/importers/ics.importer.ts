import { ITimetableImporter, ParsedTimetable } from './importer.interface'
import { SourceType } from '../strategies/detector'

export class IcsImporter implements ITimetableImporter {
  canHandle(sourceType: SourceType, content: string): boolean {
    return sourceType === 'ICS' || content.includes('BEGIN:VCALENDAR')
  }

  async parse(content: string): Promise<ParsedTimetable> {
    const events = this.parseIcs(content)
    const courses: ParsedTimetable['courses'] = []

    for (const event of events) {
      const course = courses.find((c) => c.title === event.summary)
      if (course) {
        course.sessions.push(this.mapToSession(event))
      } else {
        courses.push({
          title: event.summary,
          teacher: event.organizer,
          sessions: [this.mapToSession(event)],
        })
      }
    }

    return { title: 'Imported Timetable', courses }
  }

  private parseIcs(content: string) {
    const events: any[] = []
    const lines = content.split('\n')
    let current: any = null

    for (const line of lines) {
      if (line.startsWith('BEGIN:VEVENT')) {
        current = {}
      } else if (line.startsWith('END:VEVENT')) {
        if (current) events.push(current)
        current = null
      } else if (current) {
        const [key, ...valueParts] = line.split(':')
        const value = valueParts.join(':')
        if (key === 'SUMMARY') current.summary = value
        if (key === 'LOCATION') current.location = value
        if (key === 'ORGANIZER') current.organizer = value
        if (key.startsWith('DTSTART')) {
          current.start = this.parseDate(value)
        }
        if (key.startsWith('DTEND')) {
          current.end = this.parseDate(value)
        }
      }
    }

    return events
  }

  private parseDate(value: string): Date {
    const year = parseInt(value.slice(0, 4))
    const month = parseInt(value.slice(4, 6)) - 1
    const day = parseInt(value.slice(6, 8))
    return new Date(year, month, day)
  }

  private mapToSession(event: any) {
    const date = event.start
    const weekday = date.getDay() || 7

    return {
      weekday,
      startSection: 1,
      endSection: 2,
      startWeek: 1,
      endWeek: 20,
      location: event.location,
    }
  }
}