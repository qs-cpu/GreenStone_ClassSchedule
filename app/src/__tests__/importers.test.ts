import { describe, it, expect } from 'bun:test'
import { IcsImporter } from '../parsers/importers/ics.importer'
import { JsonImporter } from '../parsers/importers/json.importer'

const icsImporter = new IcsImporter()
const jsonImporter = new JsonImporter()

describe('IcsImporter', () => {
  describe('canHandle', () => {
    it('accepts ICS source type', () => {
      expect(icsImporter.canHandle('ICS', '')).toBe(true)
    })

    it('accepts content with BEGIN:VCALENDAR', () => {
      expect(icsImporter.canHandle('UNKNOWN', 'BEGIN:VCALENDAR\n')).toBe(true)
    })

    it('rejects plain text', () => {
      expect(icsImporter.canHandle('UNKNOWN', 'hello world')).toBe(false)
    })
  })

  describe('parse', () => {
    it('parses a single event', async () => {
      const ics = [
        'BEGIN:VCALENDAR',
        'BEGIN:VEVENT',
        'SUMMARY:高等数学',
        'LOCATION:教学楼A-301',
        'ORGANIZER:张老师',
        'DTSTART:20250310',
        'DTEND:20250310',
        'END:VEVENT',
        'END:VCALENDAR',
      ].join('\n')

      const result = await icsImporter.parse(ics)
      expect(result.title).toBe('Imported Timetable')
      expect(result.courses).toHaveLength(1)
      expect(result.courses[0].title).toBe('高等数学')
      expect(result.courses[0].teacher).toBe('张老师')
      expect(result.courses[0].sessions[0].location).toBe('教学楼A-301')
    })

    it('groups events with the same summary into one course', async () => {
      const ics = [
        'BEGIN:VCALENDAR',
        'BEGIN:VEVENT',
        'SUMMARY:高等数学',
        'DTSTART:20250310',
        'DTEND:20250310',
        'END:VEVENT',
        'BEGIN:VEVENT',
        'SUMMARY:高等数学',
        'DTSTART:20250312',
        'DTEND:20250312',
        'END:VEVENT',
        'END:VCALENDAR',
      ].join('\n')

      const result = await icsImporter.parse(ics)
      expect(result.courses).toHaveLength(1)
      expect(result.courses[0].sessions).toHaveLength(2)
    })

    it('returns empty courses for empty VCALENDAR', async () => {
      const result = await icsImporter.parse('BEGIN:VCALENDAR\nEND:VCALENDAR')
      expect(result.courses).toHaveLength(0)
    })
  })
})

describe('JsonImporter', () => {
  describe('canHandle', () => {
    it('accepts JSON source type', () => {
      expect(jsonImporter.canHandle('JSON', '')).toBe(true)
    })

    it('accepts JSON object', () => {
      expect(jsonImporter.canHandle('UNKNOWN', '{"title":"test"}')).toBe(true)
    })

    it('accepts JSON array', () => {
      expect(jsonImporter.canHandle('UNKNOWN', '[{"title":"test"}]')).toBe(true)
    })

    it('rejects plain text', () => {
      expect(jsonImporter.canHandle('UNKNOWN', 'hello world')).toBe(false)
    })
  })

  describe('parse', () => {
    it('parses an object with title and courses array', async () => {
      const json = JSON.stringify({
        title: '我的课表',
        courses: [
          {
            title: '高等数学',
            teacher: '张老师',
            sessions: [
              { weekday: 1, startSection: 1, endSection: 2, startWeek: 1, endWeek: 16, weekType: 'all', location: 'A301' },
            ],
          },
        ],
      })

      const result = await jsonImporter.parse(json)
      expect(result.title).toBe('我的课表')
      expect(result.courses).toHaveLength(1)
      expect(result.courses[0].title).toBe('高等数学')
      expect(result.courses[0].teacher).toBe('张老师')
      expect(result.courses[0].sessions[0].weekday).toBe(1)
      expect(result.courses[0].sessions[0].location).toBe('A301')
    })

    it('parses a bare course array', async () => {
      const json = JSON.stringify([
        { title: '英语', teacher: '李老师', sessions: [{ weekday: 2, startSection: 3, endSection: 4 }] },
      ])

      const result = await jsonImporter.parse(json)
      expect(result.title).toBe('Imported Timetable')
      expect(result.courses).toHaveLength(1)
      expect(result.courses[0].title).toBe('英语')
    })

    it('fills defaults for missing session fields', async () => {
      const json = JSON.stringify({ courses: [{ title: 'test', sessions: [{}] }] })

      const result = await jsonImporter.parse(json)
      const session = result.courses[0].sessions[0]
      expect(session.weekday).toBe(1)
      expect(session.startSection).toBe(1)
      expect(session.endSection).toBe(2)
      expect(session.weekType).toBe('all')
    })

    it('parses a course with sessions in course body (no sessions array)', async () => {
      const json = JSON.stringify({ courses: [{ title: '体育', weekday: 3, startSection: 5, endSection: 6 }] })

      const result = await jsonImporter.parse(json)
      expect(result.courses).toHaveLength(1)
      expect(result.courses[0].sessions[0].weekday).toBe(3)
    })
  })
})
