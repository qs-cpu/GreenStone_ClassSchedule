import { db, schema } from '../db'
import { eq, and } from 'drizzle-orm'
import axios from 'axios'

function now() { return new Date().toISOString() }

export class SyncService {
  async syncSource(sourceId: string, userId: string) {
    const [source] = await db.select().from(schema.timetableSources)
      .where(and(
        eq(schema.timetableSources.id, sourceId),
        eq(schema.timetableSources.userId, userId)
      ))
      .execute()

    if (!source) {
      throw new Error('Source not found')
    }

    // 更新状态为 syncing
    await db.update(schema.timetableSources)
      .set({ syncStatus: 'syncing', updatedAt: now() })
      .where(eq(schema.timetableSources.id, sourceId))
      .execute()

    // 记录开始
    const [record] = await db.insert(schema.syncRecords)
      .values({
        sourceId,
        status: 'syncing',
        startedAt: now(),
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
          lastSyncedAt: now(),
          etag: response.headers.etag,
          lastModified: response.headers['last-modified'],
          updatedAt: now(),
        })
        .where(eq(schema.timetableSources.id, sourceId))
        .execute()

      // 更新记录
      await db.update(schema.syncRecords)
        .set({
          status: 'success',
          finishedAt: now(),
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
          finishedAt: now(),
        })
        .where(eq(schema.syncRecords.id, record.id))
        .execute()

      await db.update(schema.timetableSources)
        .set({
          syncStatus: 'failed',
          errorMessage: message,
          updatedAt: now(),
        })
        .where(eq(schema.timetableSources.id, sourceId))
        .execute()

      throw error
    }
  }
}
