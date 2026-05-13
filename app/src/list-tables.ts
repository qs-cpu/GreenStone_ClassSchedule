import pg from 'pg'
const { Pool } = pg

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
})

async function main() {
  // 查看所有表
  const tables = await pool.query(`
    SELECT table_name 
    FROM information_schema.tables 
    WHERE table_schema = 'public'
    ORDER BY table_name
  `)
  
  if (tables.rows.length === 0) {
    console.log('数据库中没有表，请先运行 drizzle-kit push')
    pool.end()
    return
  }

  console.log('数据库中的表：\n')
  
  for (const row of tables.rows) {
    const tableName = row.table_name
    
    // 查看每个表的字段
    const columns = await pool.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_name = $1 AND table_schema = 'public'
      ORDER BY ordinal_position
    `, [tableName])
    
    console.log(`### ${tableName}`)
    columns.rows.forEach(col => {
      const nullable = col.is_nullable === 'YES' ? 'null' : 'not null'
      const defaultVal = col.column_default ? ` default ${col.column_default}` : ''
      console.log(`  ${col.column_name}: ${col.data_type} ${nullable}${defaultVal}`)
    })
    console.log()
  }
  
  pool.end()
}

main()