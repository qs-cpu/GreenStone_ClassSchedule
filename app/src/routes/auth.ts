import { Elysia, t } from 'elysia'
import { eq } from 'drizzle-orm'
import { db, schema } from '../db'
import { AuthService } from '../services/auth.service'

const authService = new AuthService()

export const authRoutes = new Elysia()
  .group('/api/auth', (app) =>
    app
      .post(
        '/register',
        async ({ body, set }) => {
          try {
            const { username, password, nickname } = body

            const existing = await db.query.users.findFirst({
              where: eq(schema.users.username, username),
            })

            if (existing) {
              set.status = 409
              return { error: '用户名已存在' }
            }

            const passwordHash = await Bun.password.hash(password)
            const [user] = await db
              .insert(schema.users)
              .values({
                username,
                passwordHash,
                nickname: nickname || null,
              })
              .returning()

            set.status = 201
            return {
              user: {
                id: user.id,
                username: user.username,
                nickname: user.nickname,
                createdAt: user.createdAt,
              },
            }
          } catch (error) {
            set.status = 500
            return {
              error: error instanceof Error ? error.message : '注册失败',
            }
          }
        },
        {
          body: t.Object({
            username: t.String({ minLength: 3, maxLength: 50 }),
            password: t.String({ minLength: 6 }),
            nickname: t.Optional(t.String({ maxLength: 100 })),
          }),
        }
      )
      .post(
        '/login',
        async ({ body, set }) => {
          try {
            const { username, password } = body
            const user = await db.query.users.findFirst({
              where: eq(schema.users.username, username),
            })

            if (!user?.passwordHash) {
              set.status = 401
              return { error: '用户名或密码错误' }
            }

            const isValid = await Bun.password.verify(password, user.passwordHash)
            if (!isValid) {
              set.status = 401
              return { error: '用户名或密码错误' }
            }

            return {
              token: await authService.generateToken(user.id),
              user: {
                id: user.id,
                username: user.username,
                nickname: user.nickname,
                role: user.role,
                createdAt: user.createdAt,
              },
            }
          } catch (error) {
            set.status = 500
            return {
              error: error instanceof Error ? error.message : '登录失败',
            }
          }
        },
        {
          body: t.Object({
            username: t.String({ minLength: 3, maxLength: 50 }),
            password: t.String({ minLength: 6 }),
          }),
        }
      )
  )
