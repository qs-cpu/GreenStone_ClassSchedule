import { Elysia, t } from 'elysia'
import { AuthService } from '../services/auth.service'

const authService = new AuthService()

export const authRoutes = new Elysia()
  .group('/api/auth', (app) =>
    app
      .post('/register', async ({ body, set }) => {
        const { username, password, nickname } = body as {
          username: string
          password: string
          nickname?: string
        }

        try {
          const user = await authService.register(username, password, nickname)
          set.status = 201
          return user
        } catch (error) {
          set.status = 400
          return { error: error instanceof Error ? error.message : '注册失败' }
        }
      }, {
        body: t.Object({
          username: t.String({ minLength: 3, maxLength: 50 }),
          password: t.String({ minLength: 6 }),
          nickname: t.Optional(t.String({ maxLength: 100 })),
        }),
      })
      .post('/login', async ({ body, set }) => {
        const { username, password } = body as {
          username: string
          password: string
        }

        try {
          const result = await authService.login(username, password)
          return result
        } catch (error) {
          set.status = 401
          return { error: error instanceof Error ? error.message : '登录失败' }
        }
      }, {
        body: t.Object({
          username: t.String(),
          password: t.String(),
        }),
      })
  )