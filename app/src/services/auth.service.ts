import { config } from '../config'
import { SignJWT, jwtVerify } from 'jose'

export class AuthService {
  async generateToken(userId: string): Promise<string> {
    const secret = new TextEncoder().encode(config.jwt.secret)
    const token = await new SignJWT({ userId })
      .setProtectedHeader({ alg: 'HS256' })
      .setIssuedAt()
      .setExpirationTime(config.jwt.expiresIn)
      .sign(secret)
    return token
  }

  async verifyToken(token: string): Promise<{ userId: string } | null> {
    try {
      const secret = new TextEncoder().encode(config.jwt.secret)
      const { payload } = await jwtVerify(token, secret)
      return { userId: payload.userId as string }
    } catch {
      return null
    }
  }
}
