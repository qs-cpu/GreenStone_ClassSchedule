import { db, schema } from './db'
import bcrypt from 'bcryptjs'

async function seed() {
  console.log('Seeding database...')

  const [user] = await db.insert(schema.users)
    .values({
      username: 'testuser',
      nickname: '测试用户',
      passwordHash: await bcrypt.hash('test123', 10),
    })
    .returning()

  console.log('Created user:', user.id)

  const [term] = await db.insert(schema.terms)
    .values({
      userId: user.id,
      name: '2024春季学期',
      startDate: new Date('2024-02-26'),
      endDate: new Date('2024-07-05'),
      totalWeeks: 20,
      timezone: 'Asia/Shanghai',
    })
    .returning()

  console.log('Created term:', term.id)

  const [timetable] = await db.insert(schema.timetables)
    .values({
      userId: user.id,
      termId: term.id,
      title: '我的课表',
    })
    .returning()

  console.log('Created timetable:', timetable.id)

  const [course] = await db.insert(schema.courses)
    .values({
      timetableId: timetable.id,
      title: '高等数学',
      teacher: '张老师',
      color: '#FF5722',
    })
    .returning()

  console.log('Created course:', course.id)

  const [session] = await db.insert(schema.courseSessions)
    .values({
      courseId: course.id,
      weekday: 1,
      startSection: 1,
      endSection: 2,
      startWeek: 1,
      endWeek: 16,
      weekType: 'all',
    })
    .returning()

  console.log('Created session:', session.id)

  await db.insert(schema.locations)
    .values({
      sessionId: session.id,
      locationText: '教学楼A 201',
      building: '教学楼A',
      room: '201',
    })
    .execute()

  console.log('Created location')

  console.log('Seeding completed!')
  process.exit(0)
}

seed().catch((error) => {
  console.error('Seed failed:', error)
  process.exit(1)
})