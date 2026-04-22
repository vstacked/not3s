import { db } from '../database/database';
import { AppError } from '../middlewares/error.middleware';

export interface Note {
  id: number;
  title: string;
  content: string;
  updated_at: string;
}

export const notesService = {
  getAll(userId: number): Note[] {
    return db
      .prepare(
        'SELECT id, title, content, updated_at FROM notes WHERE user_id = ? ORDER BY updated_at DESC, id DESC',
      )
      .all(userId) as Note[];
  },

  create(userId: number, title: string, content: string): void {
    db.prepare(
      'INSERT INTO notes (user_id, title, content) VALUES (?, ?, ?)',
    ).run(userId, title, content);
  },

  update(id: number, userId: number, title: string, content: string): void {
    const note = db
      .prepare('SELECT id FROM notes WHERE id = ? AND user_id = ?')
      .get(id, userId);

    if (!note) {
      const err: AppError = new Error('Note not found');
      err.statusCode = 404;
      throw err;
    }

    db.prepare(
      'UPDATE notes SET title = ?, content = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND user_id = ?',
    ).run(title, content, id, userId);
  },

  delete(id: number, userId: number): void {
    const note = db
      .prepare('SELECT id FROM notes WHERE id = ? AND user_id = ?')
      .get(id, userId);

    if (!note) {
      const err: AppError = new Error('Note not found');
      err.statusCode = 404;
      throw err;
    }

    db.prepare('DELETE FROM notes WHERE id = ? AND user_id = ?').run(
      id,
      userId,
    );
  },
};
