import { Elysia } from 'elysia'
import { db, schema } from '../db'
import { eq } from 'drizzle-orm'
import { AuthService } from '../services/auth.service'

const authService = new AuthService()

export const adminMiddleware = new Elysia()
  .derive(async ({ request }: any) => {
    const authHeader = request.headers.get('Authorization')

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return { user: null, isAdmin: false }
    }

    const token = authHeader.slice(7)
    const payload = await authService.verifyToken(token)

    if (!payload) {
      return { user: null, isAdmin: false }
    }

    const user = await db.query.users.findFirst({
      where: eq(schema.users.id, payload.userId),
    })

    return {
      user: payload,
      isAdmin: user?.role === 'admin',
    }
  })
  .guard({
    beforeHandle: ({ user, isAdmin, set }: any) => {
      if (!user) {
        set.status = 401
        return { error: '未授权，请先登录' }
      }
      if (!isAdmin) {
        set.status = 403
        return { error: '权限不足，需要管理员权限' }
      }
    }
  })
