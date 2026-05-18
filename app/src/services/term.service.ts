import { db, schema } from '../db'
import { eq, and } from 'drizzle-orm'

export class TermService {
  async findOrCreateTerm(userId: string, year: number, semester: string) {
    const name = `${year}年${semester}学期`
    
    const existing = await db.select().from(schema.terms)
      .where(and(
        eq(schema.terms.userId, userId),
        eq(schema.terms.name, name)
      ))
      .execute()

    if (existing.length > 0) {
      return existing[0]
    }

    const startDate = semester === '上' 
      ? new Date(year, 8, 1)   // 上学期：9月1日
      : new Date(year, 1, 1)   // 下学期：2月1日

    const endDate = semester === '上'
      ? new Date(year + 1, 0, 31)  // 上学期：次年1月31日
      : new Date(year, 5, 30)       // 下学期：6月30日

    const [newTerm] = await db.insert(schema.terms)
      .values({
        userId,
        name,
        startDate,
        endDate,
        totalWeeks: 20,
      })
      .returning()
      .execute()

    return newTerm
  }

  async findByUserId(userId: string) {
    return db.select().from(schema.terms)
      .where(eq(schema.terms.userId, userId))
      .execute()
  }
}