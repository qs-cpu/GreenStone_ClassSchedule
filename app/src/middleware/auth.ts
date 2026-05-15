import { Elysia } from 'elysia'
import { AuthService } from '../services/auth.service'

const authService = new AuthService()

export const authMiddleware = new Elysia()
  .derive(async ({ request }: any) => {
    const authHeader = request.headers.get('Authorization')
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return { user: null }
    }

    const token = authHeader.slice(7)
    const payload = await authService.verifyToken(token)

    return { user: payload }
  })
  .onBeforeHandle(({ user, set }: any) => {
    if (!user) {
      set.status = 401
      return { error: '未授权，请先登录' }
    }
  })