import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { db } from '../database/database';
import { AppError } from '../middlewares/error.middleware';

const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-change-in-production';
const SALT_ROUNDS = 10;

interface UserRow {
  id: number;
  password: string;
}

export const authService = {
  async register(username: string, password: string): Promise<void> {
    const existing = db
      .prepare('SELECT id FROM users WHERE username = ?')
      .get(username);

    if (existing) {
      const err: AppError = new Error('Username already taken');
      err.statusCode = 400;
      throw err;
    }

    const hashed = await bcrypt.hash(password, SALT_ROUNDS);
    db.prepare('INSERT INTO users (username, password) VALUES (?, ?)').run(
      username,
      hashed,
    );
  },

  async login(username: string, password: string): Promise<string> {
    const user = db
      .prepare('SELECT id, password FROM users WHERE username = ?')
      .get(username) as UserRow | undefined;

    if (!user) {
      const err: AppError = new Error('Invalid credentials');
      err.statusCode = 401;
      throw err;
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      const err: AppError = new Error('Invalid credentials');
      err.statusCode = 401;
      throw err;
    }

    return jwt.sign({ userId: user.id }, JWT_SECRET, { expiresIn: '7d' });
  },
};
