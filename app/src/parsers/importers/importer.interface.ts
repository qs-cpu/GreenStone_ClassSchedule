import { SourceType } from '../strategies/detector'

export interface ParsedCourse {
  title: string
  teacher?: string
  sessions: {
    weekday: number
    startSection: number
    endSection: number
    startWeek: number
    endWeek: number
    weekType?: string
    location?: string
  }[]
}

export interface ParsedTimetable {
  title: string
  courses: ParsedCourse[]
}

export interface ITimetableImporter {
  canHandle(sourceType: SourceType, content: string): boolean
  parse(content: string): Promise<ParsedTimetable>
}