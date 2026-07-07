import { drizzle } from 'drizzle-orm/node-postgres';
import { migrate } from 'drizzle-orm/node-postgres/migrator';
import { Pool } from 'pg';
import * as path from 'path';

const connectionString = process.env.DATABASE_URL || 'postgres://postgres:postgres@localhost:5432/momentum';

const pool = new Pool({
  connectionString,
});

const db = drizzle(pool);

async function main() {
  console.log('Running migrations...');
  await migrate(db, { migrationsFolder: path.join(__dirname, '../migrations') });
  console.log('Migrations complete!');
  await pool.end();
}

main().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
