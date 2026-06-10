import { db, schema } from './db'
import { eq } from 'drizzle-orm'
import bcrypt from 'bcryptjs'

async function seedAdmin() {
  const username = 'admin'
  const password = process.env.ADMIN_PASSWORD || 'admin123'
  const nickname = '系统管理员'

  if (!process.env.ADMIN_PASSWORD) {
    console.warn('ADMIN_PASSWORD not set, using default password "admin123" — change it after first login')
  }

  const existing = await db.query.users.findFirst({
    where: eq(schema.users.username, username),
  })

  if (existing) {
    if (existing.role !== 'admin') {
      await db.update(schema.users)
        .set({ role: 'admin', updatedAt: new Date().toISOString() })
        .where(eq(schema.users.id, existing.id))
      console.log(`用户 ${username} 已升级为管理员`)
    } else {
      console.log(`管理员 ${username} 已存在`)
    }
    return
  }

  const passwordHash = await bcrypt.hash(password, 10)
  const [admin] = await db.insert(schema.users)
    .values({
      username,
      passwordHash,
      nickname,
      role: 'admin',
    })
    .returning()

  console.log(`管理员账号创建成功:`)
  console.log(`  用户名: ${username}`)
  console.log(`  ID: ${admin.id}`)
}

seedAdmin()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error('创建管理员失败:', err)
    process.exit(1)
  })
