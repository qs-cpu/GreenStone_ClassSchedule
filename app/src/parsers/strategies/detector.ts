export type SourceType = 'ICS' | 'JSON' | 'HTML' | 'UNKNOWN'

export function detectSourceType(url: string, content: string): SourceType {
  if (url.endsWith('.ics') || url.endsWith('.ical')) {
    return 'ICS'
  }
  if (url.endsWith('.json')) {
    return 'JSON'
  }

  if (content.includes('BEGIN:VCALENDAR')) {
    return 'ICS'
  }
  if (content.trim().startsWith('{') || content.trim().startsWith('[')) {
    return 'JSON'
  }

  return 'UNKNOWN'
}