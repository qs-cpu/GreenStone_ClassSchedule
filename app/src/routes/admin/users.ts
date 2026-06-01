import { Elysia, t } from 'elysia'
import { eq, like, count } from 'drizzle-orm'
import { db, schema } from '../../db'
import { adminMiddleware } from '../../middleware/admin'
import { toUserDTO, toUserDetailDTO, toUserListDTO, toUserStatsDTO } from '../../dto/user.dto'
import bcrypt from 'bcryptjs'

export const adminUserRoutes = new Elysia()
  .use(adminMiddleware)
  .group('/api/admin/users', (app) =>
    app
      .get(
        '/',
        async ({ query }) => {
          const { page = 1, pageSize = 20, search } = query
          const offset = (page - 1) * pageSize

          let whereCondition = undefined
          if (search) {
            whereCondition = like(schema.users.username, `%${search}%`)
          }

          const [usersList, totalResult] = await Promise.all([
            db.select()
              .from(schema.users)
              .where(whereCondition)
              .limit(pageSize)
              .offset(offset)
              .orderBy(schema.users.createdAt),
            db.select({ count: count() })
              .from(schema.users)
              .where(whereCondition),
          ])

          return toUserListDTO(usersList, totalResult[0].count, page, pageSize)
        },
        {
          query: t.Object({
            page: t.Optional(t.Number({ minimum: 1 })),
            pageSize: t.Optional(t.Number({ minimum: 1, maximum: 100 })),
            search: t.Optional(t.String()),
          }),
        }
      )

      .get(
        '/:id',
        async ({ params, set }) => {
          const user = await db.query.users.findFirst({
            where: eq(schema.users.id, params.id),
          })

          if (!user) {
            set.status = 404
            return { error: '用户不存在' }
          }

          const timetableCount = await db.select({ count: count() })
            .from(schema.timetables)
            .where(eq(schema.timetables.userId, user.id))

          return toUserDetailDTO(user, timetableCount[0].count)
        },
        {
          params: t.Object({
            id: t.String(),
          }),
        }
      )

      .post(
        '/',
        async ({ body, set }) => {
          const { username, password, nickname, role } = body

          const existing = await db.query.users.findFirst({
            where: eq(schema.users.username, username),
          })

          if (existing) {
            set.status = 409
            return { error: '用户名已存在' }
          }

          const passwordHash = await bcrypt.hash(password, 10)
          const [user] = await db.insert(schema.users)
            .values({
              username,
              passwordHash,
              nickname: nickname || username,
              role: role || 'user',
            })
            .returning()

          set.status = 201
          return { user: toUserDTO(user) }
        },
        {
          body: t.Object({
            username: t.String({ minLength: 3, maxLength: 50 }),
            password: t.String({ minLength: 6 }),
            nickname: t.Optional(t.String({ maxLength: 100 })),
            role: t.Optional(t.Union([t.Literal('user'), t.Literal('admin')])),
          }),
        }
      )

      .put(
        '/:id',
        async ({ params, request, set }) => {
          try {
            const body = await request.json()
            const { nickname, role, password } = body

            const user = await db.query.users.findFirst({
              where: eq(schema.users.id, params.id),
            })

            if (!user) {
              set.status = 404
              return { error: '用户不存在' }
            }

            const updateData: any = {
              updatedAt: new Date(),
            }

            if (nickname !== undefined) updateData.nickname = nickname
            if (role !== undefined) updateData.role = role
            if (password) {
              updateData.passwordHash = await bcrypt.hash(password, 10)
            }

            const [updated] = await db.update(schema.users)
              .set(updateData)
              .where(eq(schema.users.id, params.id))
              .returning()

            return { user: toUserDTO(updated) }
          } catch (error) {
            console.error('更新用户失败:', error)
            set.status = 500
            return { error: error instanceof Error ? error.message : '更新用户失败' }
          }
        }
      )

      .delete(
        '/:id',
        async ({ params, set }) => {
          try {
            const user = await db.query.users.findFirst({
              where: eq(schema.users.id, params.id),
            })

            if (!user) {
              set.status = 404
              return { error: '用户不存在' }
            }

            if (user.role === 'admin') {
              const adminCount = await db.select({ count: count() })
                .from(schema.users)
                .where(eq(schema.users.role, 'admin'))

              if (adminCount[0].count <= 1) {
                set.status = 400
                return { error: '不能删除最后一个管理员' }
              }
            }

            // 使用事务确保数据一致性
            await db.transaction(async (tx) => {
              // 删除课程表相关数据
              const timetables = await tx.query.timetables.findMany({
                where: eq(schema.timetables.userId, params.id),
              })

              for (const timetable of timetables) {
                const courses = await tx.query.courses.findMany({
                  where: eq(schema.courses.timetableId, timetable.id),
                })
                for (const course of courses) {
                  // 先删除地点
                  for (const session of await tx.query.courseSessions.findMany({
                    where: eq(schema.courseSessions.courseId, course.id),
                  })) {
                    await tx.delete(schema.locations)
                      .where(eq(schema.locations.sessionId, session.id))
                  }
                  await tx.delete(schema.courseSessions)
                    .where(eq(schema.courseSessions.courseId, course.id))
                }
                await tx.delete(schema.courses)
                  .where(eq(schema.courses.timetableId, timetable.id))
              }
              await tx.delete(schema.timetables)
                .where(eq(schema.timetables.userId, params.id))

              // 删除学期相关数据
              const termsList = await tx.query.terms.findMany({
                where: eq(schema.terms.userId, params.id),
              })
              for (const term of termsList) {
                await tx.delete(schema.timeSlots)
                  .where(eq(schema.timeSlots.termId, term.id))
              }
              await tx.delete(schema.terms)
                .where(eq(schema.terms.userId, params.id))

              // 删除来源相关数据
              const sources = await tx.query.timetableSources.findMany({
                where: eq(schema.timetableSources.userId, params.id),
              })
              for (const source of sources) {
                await tx.delete(schema.syncRecords)
                  .where(eq(schema.syncRecords.sourceId, source.id))
              }
              await tx.delete(schema.timetableSources)
                .where(eq(schema.timetableSources.userId, params.id))

              // 最后删除用户
              await tx.delete(schema.users)
                .where(eq(schema.users.id, params.id))
            })

            return { message: '用户已删除' }
          } catch (error) {
            console.error('删除用户失败:', error)
            set.status = 500
            return { error: error instanceof Error ? error.message : '删除用户失败' }
          }
        },
        {
          params: t.Object({ id: t.String() }),
        }
      )

      .get(
        '/stats/overview',
        async () => {
          const [totalUsers] = await db.select({ count: count() }).from(schema.users)
          const [adminUsers] = await db.select({ count: count() })
            .from(schema.users)
            .where(eq(schema.users.role, 'admin'))
          const [totalTimetables] = await db.select({ count: count() }).from(schema.timetables)

          return toUserStatsDTO(totalUsers.count, adminUsers.count, totalTimetables.count)
        }
      )
  )
