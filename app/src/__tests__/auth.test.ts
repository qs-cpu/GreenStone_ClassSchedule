// Must be set before any imports that read JWT_SECRET
process.env.JWT_SECRET = 'test-secret-key-for-unit-tests-must-be-64chars'

import { describe, it, expect, beforeAll } from 'bun:test'
import { AuthService } from '../../services/auth.service'

const auth = new AuthService()

describe('AuthService', () => {
  describe('generateToken', () => {
    it('returns a non-empty string', async () => {
      const token = await auth.generateToken('user-123')
      expect(token).toBeString()
      expect(token.length).toBeGreaterThan(10)
    })

    it('returns different tokens for different users', async () => {
      const t1 = await auth.generateToken('user-a')
      const t2 = await auth.generateToken('user-b')
      expect(t1).not.toBe(t2)
    })
  })

  describe('verifyToken', () => {
    it('returns userId for a valid token', async () => {
      const token = await auth.generateToken('user-abc')
      const result = await auth.verifyToken(token)
      expect(result).not.toBeNull()
      expect(result!.userId).toBe('user-abc')
    })

    it('returns null for an empty string', async () => {
      const result = await auth.verifyToken('')
      expect(result).toBeNull()
    })

    it('returns null for a malformed token', async () => {
      const result = await auth.verifyToken('not.a.jwt')
      expect(result).toBeNull()
    })
  })
})
