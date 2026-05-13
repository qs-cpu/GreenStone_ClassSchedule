import { HTMLRewriter } from 'htmlrewriter'
import { ParsedCourse } from '../importers/importer.interface'

async function consume(stream: ReadableStream): Promise<void> {
  const reader = stream.getReader()
  while (!(await reader.read()).done) {}
}

export async function parseLoginLink(html: string): Promise<string> {
  const response = new Response(html)
  let link = ''

  const rewriter = new HTMLRewriter()
    .on('#frm', {
      element: (el: any) => { link = el.getAttribute('action') || '' }
    })

  await consume(rewriter.transform(response).body!)
  return link
}

export async function parseBeginDate(html: string): Promise<[number, number, number]> {
  const response = new Response(html)
  const date: [number, number, number] = [2024, 9, 1]

  const datePattern = /(\d{4})\/(\d{1,2})\/(\d{1,2})/
  const rewriter = new HTMLRewriter()
    .on('strong', {
      text: (t: any) => {
        const trimmed = t.text.trim()
        if (trimmed) {
          const match = trimmed.match(datePattern)
          if (match) {
            const [, year, month, day] = match
            date[0] = parseInt(year, 10)
            date[1] = parseInt(month, 10)
            date[2] = parseInt(day, 10)
          }
        }
      }
    })

  await consume(rewriter.transform(response).body!)
  return date
}

interface InfoToken {
  name?: string
  location?: string
  week?: Array<[number, number]>
  odd?: boolean
  even?: boolean
}

export async function parseFullTable(html: string): Promise<ParsedCourse[]> {
  const leftTable: string[][] = []
  const rightTable: Array<[number, string | null, ...string[]]> = []
  let leftCurrentCourse: string[] = []
  let rightCurrentCourse: [number, string | null, ...string[]] | null = null
  const response = new Response(html)

  const rewriter = new HTMLRewriter()
    .on('body > table:nth-child(3) td tr:not([height]):not([id])', {
      element() {
        if (leftCurrentCourse.length > 0) {
          leftTable.push(leftCurrentCourse)
          leftCurrentCourse = []
        }
      },
      text: (t: any) => {
        const trimmed = t.text.trim().replace('&nbsp;', '')
        if (trimmed) leftCurrentCourse.push(trimmed)
      },
    })
    .on('td[id][align][rowspan]', {
      element: (el: any) => {
        if (rightCurrentCourse) {
          rightTable.push(rightCurrentCourse)
          rightCurrentCourse = null
        }
        rightCurrentCourse = [
          parseInt(el.getAttribute('id') || '0', 10),
          el.getAttribute('rowspan'),
        ]
      },
      text: (t: any) => {
        const trimmed = t.text.trim()
        if (trimmed && rightCurrentCourse) {
          rightCurrentCourse.push(trimmed)
        }
      },
    })

  await consume(rewriter.transform(response).body!)

  if (leftCurrentCourse.length > 0) leftTable.push(leftCurrentCourse)
  if (rightCurrentCourse) rightTable.push(rightCurrentCourse)

  const leftMap = new Map<string, { teacher: string, weeks: Array<[number, number]> }>(
    leftTable.map((v) => {
      const name = v[0]?.replaceAll(' ', '') || ''
      const weeks: Array<[number, number]> = v
        .filter((item) => item.includes('～'))
        .flatMap((str) => {
          return str.split(',').map((range) => {
            const [start, end] = range.split('～').map(Number)
            return [start, end] as [number, number]
          })
        })
      return [name, { teacher: v[4] || '', weeks }]
    })
  )

  const splitBy = <T>(arr: T[], cond: (x: T) => boolean): T[][] =>
    arr.reduce((res: T[][], x: T) => {
      if (cond(x) || res.length === 0) res.push([x])
      else res[res.length - 1].push(x)
      return res
    }, [])

  const parseInfoToken = (token: string): InfoToken => {
    const weekPattern = /\((.*?)\)/
    const squareBracketsPattern = /(?<=\[)(.*?)(?=\])/g

    if (token.includes('周')) {
      const match = weekPattern.exec(token)
      if (match) {
        return {
          week: match[1].split(',').map((part) => {
            const [start, end] = part.replace('周', '').split('-').map(Number)
            return [start, end] as [number, number]
          }),
        }
      }
    }

    if (token.includes('[')) {
      const matches = [...token.matchAll(squareBracketsPattern)]
      const result: InfoToken = { location: '', odd: false, even: false }
      for (const [_, content] of matches) {
        if (content === '单') result.odd = true
        else if (content === '双') result.even = true
        else result.location = content
      }
      return result
    }

    return { name: token }
  }

  interface ParsedSessionItem extends InfoToken {
    index: number
    weekday: number
    duration: number
  }

  const parsedSessions: ParsedSessionItem[] = rightTable.flatMap((row) => {
    const [code, durationStr, ...rest] = row
    const duration = parseInt(durationStr || '1', 10)

    const groupedInfo = splitBy(
      rest,
      (token: string) => leftMap.has(parseInfoToken(token).name || '')
    ).map((v) => {
      const merged: InfoToken = {}
      for (const token of v) {
        Object.assign(merged, parseInfoToken(token))
      }
      return merged
    })

    return groupedInfo.map((i: InfoToken): ParsedSessionItem => ({
      index: Math.floor(code / 10),
      weekday: code % 10,
      duration,
      name: i.name,
      location: i.location,
      week: i.week,
      odd: i.odd,
      even: i.even,
    }))
  })

  const courses: ParsedCourse[] = []

  for (const item of parsedSessions) {
    const name = item.name || ''
    const existing = courses.find(c => c.title === name)
    const week = item.week?.[0] ?? leftMap.get(name)?.weeks?.[0] ?? [1, 20]
    const session = {
      weekday: item.weekday,
      startSection: item.index,
      endSection: item.index + item.duration - 1,
      startWeek: week[0],
      endWeek: week[1],
      weekType: item.odd ? 'odd' : item.even ? 'even' : 'all',
      location: item.location || '',
    }

    if (existing) {
      existing.sessions.push(session)
    } else {
      courses.push({
        title: name,
        teacher: leftMap.get(name)?.teacher || '',
        sessions: [session],
      })
    }
  }

  return courses
}