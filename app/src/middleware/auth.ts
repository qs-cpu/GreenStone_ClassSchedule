import { Elysia } from 'elysia'
import { AuthService } from '../services/auth.service'

const authService = new AuthService()

export const authMiddleware = new Elysia()
  .derive(async ({ request }: any) => {
    const authHeader = request.headers.get('Authorization')
    console.log('[DEBUG] authHeader:', authHeader)
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      console.log('[DEBUG] No valid auth header')
      return { user: null }
    }

    const token = authHeader.slice(7)
    console.log('[DEBUG] token:', token)
    const payload = await authService.verifyToken(token)
    console.log('[DEBUG] payload:', payload)

    return { user: payload }
  })
  .guard({
    beforeHandle: ({ user, set }: any) => {
      console.log('[DEBUG] beforeHandle user:', user)
      if (!user) {
        set.status = 401
        return { error: '未授权，请先登录' }
      }
    }
  })