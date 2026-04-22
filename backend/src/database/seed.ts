import bcrypt from 'bcryptjs';
import { db } from './database';

const SEED_USERS = [
  {
    username: 'alice',
    password: 'password123',
    notes: [
      { title: 'Shopping list', content: 'Milk, eggs, bread, butter' },
      { title: 'Meeting notes', content: 'Discuss Q2 roadmap and sprint planning' },
      { title: 'Book recommendations', content: 'Clean Code, The Pragmatic Programmer' },
    ],
  },
  {
    username: 'bob',
    password: 'password123',
    notes: [
      { title: 'Workout plan', content: 'Mon: chest, Wed: back, Fri: legs' },
      { title: 'Recipe ideas', content: 'Try making pasta carbonara this weekend' },
    ],
  },
];

export async function runSeed(): Promise<void> {
  const existingUsers = db
    .prepare('SELECT COUNT(*) as count FROM users')
    .get() as { count: number };

  if (existingUsers.count > 0) {
    return;
  }

  for (const user of SEED_USERS) {
    const hashed = await bcrypt.hash(user.password, 10);
    const result = db
      .prepare('INSERT INTO users (username, password) VALUES (?, ?)')
      .run(user.username, hashed);

    const userId = result.lastInsertRowid as number;

    for (const note of user.notes) {
      db.prepare(
        'INSERT INTO notes (user_id, title, content) VALUES (?, ?, ?)',
      ).run(userId, note.title, note.content);
    }
  }

  console.log('Seed data inserted (alice & bob with sample notes)');
}
