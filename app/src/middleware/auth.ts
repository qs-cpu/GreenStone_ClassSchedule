import { Elysia } from 'elysia'
import { AuthService } from '../services/auth.service'

const authService = new AuthService()

export async function getUserFromRequest(request: Request): Promise<{ userId: string } | null> {
  const authHeader = request.headers.get('Authorization')
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return null
  }

  const token = authHeader.slice(7)
  return authService.verifyToken(token)
}

export { authService }