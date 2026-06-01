import { db, schema } from '../db'
import { eq, desc, and } from 'drizzle-orm'

export class SourceService {
  async findAll(userId: string) {
    return db.select().from(schema.timetableSources)
      .where(eq(schema.timetableSources.userId, userId))
      .execute()
  }

  async findOne(id: string, userId: string) {
    const [source] = await db.select().from(schema.timetableSources)
      .where(and(
        eq(schema.timetableSources.id, id),
        eq(schema.timetableSources.userId, userId)
      ))
      .execute()

    if (!source) return null

    const records = await db.select().from(schema.syncRecords)
      .where(eq(schema.syncRecords.sourceId, id))
      .orderBy(desc(schema.syncRecords.startedAt))
      .limit(10)
      .execute()

    return { ...source, syncRecords: records }
  }
}