import BetterSqlite3, { Database } from 'better-sqlite3';
import path from 'path';
import fs from 'fs';
import { runMigrations } from './migrate';

const DB_PATH =
  process.env.DB_PATH || path.resolve(__dirname, '../../data/not3s.db');

if (DB_PATH !== ':memory:') {
  const dbDir = path.dirname(DB_PATH);
  if (!fs.existsSync(dbDir)) {
    fs.mkdirSync(dbDir, { recursive: true });
  }
}

export const db: Database = new BetterSqlite3(DB_PATH, {
  verbose: process.env.NODE_ENV === 'development' ? console.log : undefined,
});

db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

runMigrations(db);
