import { db, schema } from '../db'
import { eq } from 'drizzle-orm'
import axios from 'axios'

export class SyncService {
  async syncSource(sourceId: string) {
    const [source] = await db.select().from(schema.timetableSources)
      .where(eq(schema.timetableSources.id, sourceId))
      .execute()

    if (!source) {
      throw new Error('Source not found')
    }

    // 更新状态为 syncing
    await db.update(schema.timetableSources)
      .set({ syncStatus: 'syncing', updatedAt: new Date() })
      .where(eq(schema.timetableSources.id, sourceId))
      .execute()

    // 记录开始
    const [record] = await db.insert(schema.syncRecords)
      .values({
        sourceId,
        status: 'running',
        startedAt: new Date(),
      })
      .returning()

    try {
      // 重新拉取
      const response = await axios.get(source.originalUrl, {
        timeout: 10000,
      })

      // 更新来源
      await db.update(schema.timetableSources)
        .set({
          syncStatus: 'success',
          lastSyncedAt: new Date(),
          etag: response.headers.etag,
          lastModified: response.headers['last-modified'],
          updatedAt: new Date(),
        })
        .where(eq(schema.timetableSources.id, sourceId))
        .execute()

      // 更新记录
      await db.update(schema.syncRecords)
        .set({
          status: 'success',
          finishedAt: new Date(),
        })
        .where(eq(schema.syncRecords.id, record.id))
        .execute()

      return record
    } catch (error) {
      const message = error instanceof Error ? error.message : String(error)
      // 记录失败
      await db.update(schema.syncRecords)
        .set({
          status: 'failed',
          message: message,
          finishedAt: new Date(),
        })
        .where(eq(schema.syncRecords.id, record.id))
        .execute()

      await db.update(schema.timetableSources)
        .set({
          syncStatus: 'failed',
          errorMessage: message,
          updatedAt: new Date(),
        })
        .where(eq(schema.timetableSources.id, sourceId))
        .execute()

      throw error
    }
  }
}