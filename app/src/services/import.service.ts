import axios from 'axios'
import { db, schema } from '../db'
import { detectSourceType } from '../parsers/strategies/detector'
import { IcsImporter } from '../parsers/importers/ics.importer'
import { JsonImporter } from '../parsers/importers/json.importer'
import { validateUrl } from '../utils/url.validator'

export class ImportService {
  private importers = [new IcsImporter(), new JsonImporter()]

  async import(url: string, userId: string, termId?: string) {
    // 1. 校验 URL
    const validatedUrl = await validateUrl(url)

    // 2. 获取内容
    const response = await axios.get(validatedUrl, {
      timeout: 10000,
      maxContentLength: 5 * 1024 * 1024,
      maxRedirects: 0,
    })

    // 3. 识别来源类型
    const sourceType = detectSourceType(validatedUrl, response.data)

    // 4. 选择解析器
    const importer = this.importers.find((i) => i.canHandle(sourceType, response.data))
    if (!importer) {
      throw new Error(`Unsupported source type: ${sourceType}`)
    }

    // 5. 解析
    const parsed = await importer.parse(response.data)

    // 6. 保存到数据库
    const [timetable] = await db.insert(schema.timetables)
      .values({
        userId: userId,
        termId: termId || 'default-term',
        title: parsed.title,
      })
      .returning()

    // 创建课程
    for (const c of parsed.courses) {
      const [course] = await db.insert(schema.courses)
        .values({
          timetableId: timetable.id,
          title: c.title,
          teacher: c.teacher,
        })
        .returning()

      // 创建课次
      for (const s of c.sessions) {
        const weekType = ['all', 'odd', 'even'].includes(s.weekType || '') 
          ? s.weekType as 'all' | 'odd' | 'even' 
          : 'all'
        const [session] = await db.insert(schema.courseSessions)
          .values({
            courseId: course.id,
            weekday: s.weekday,
            startSection: s.startSection,
            endSection: s.endSection,
            startWeek: s.startWeek,
            endWeek: s.endWeek,
            weekType: weekType,
          })
          .returning()

        // 为 session 创建 locations
        if (s.location) {
          await db.insert(schema.locations)
            .values({
              sessionId: session.id,
              locationText: s.location,
            })
            .execute()
        }
      }
    }

    // 创建来源
    if (timetable.sourceId) {
      await db.insert(schema.timetableSources)
        .values({
          id: timetable.sourceId,
          userId: userId,
          originalUrl: validatedUrl,
          sourceType,
          importerKey: importer.constructor.name,
        })
        .execute()
    }

    return timetable
  }

}
