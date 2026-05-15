import bcrypt from 'bcryptjs'
import { db, schema } from '../db'
import { eq } from 'drizzle-orm'
import { config } from '../config'
import { SignJWT, jwtVerify } from 'jose'

export class AuthService {
  async register(username: string, password: string, nickname?: string) {
    const existing = await db.select().from(schema.users)
      .where(eq(schema.users.username, username))
      .execute()

    if (existing.length > 0) {
      throw new Error('用户名已存在')
    }

    const passwordHash = await this.hashPassword(password)

    const [user] = await db.insert(schema.users)
      .values({
        username,
        passwordHash,
        nickname: nickname || username,
      })
      .returning()
      .execute()

    return {
      id: user.id,
      username: user.username,
      nickname: user.nickname,
    }
  }

  async login(username: string, password: string) {
    const [user] = await db.select().from(schema.users)
      .where(eq(schema.users.username, username))
      .execute()

    if (!user) {
      throw new Error('用户名或密码错误')
    }

    const valid = await this.verifyPassword(password, user.passwordHash || '')
    if (!valid) {
      throw new Error('用户名或密码错误')
    }

    const token = await this.generateToken(user.id)

    return {
      token,
      user: {
        id: user.id,
        username: user.username,
        nickname: user.nickname,
      },
    }
  }

  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 10)
  }

  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash)
  }

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