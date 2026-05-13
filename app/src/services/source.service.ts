import { db, schema } from '../db'
import { eq, desc } from 'drizzle-orm'

export class SourceService {
  async findAll() {
    return db.select().from(schema.timetableSources).execute()
  }

  async findOne(id: string) {
    const [source] = await db.select().from(schema.timetableSources)
      .where(eq(schema.timetableSources.id, id))
      .execute()

    const records = await db.select().from(schema.syncRecords)
      .where(eq(schema.syncRecords.sourceId, id))
      .orderBy(desc(schema.syncRecords.startedAt))
      .limit(10)
      .execute()

    return { ...source, syncRecords: records }
  }
}