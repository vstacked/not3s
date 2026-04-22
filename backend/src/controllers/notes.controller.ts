import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { notesService } from '../services/notes.service';

const MAX_TITLE = 200;
const MAX_CONTENT = 10_000;

export const notesController = {
  getAll(req: AuthRequest, res: Response, next: NextFunction): void {
    try {
      const notes = notesService.getAll(req.userId!);
      res.status(200).json(notes);
    } catch (err) {
      next(err);
    }
  },

  create(req: AuthRequest, res: Response, next: NextFunction): void {
    try {
      const { title, content } = req.body;
      if (!title || !content) {
        res.status(400).json({ error: 'Title and content are required' });
        return;
      }
      if (title.length > MAX_TITLE) {
        res.status(400).json({ error: `Title must be at most ${MAX_TITLE} characters` });
        return;
      }
      if (content.length > MAX_CONTENT) {
        res.status(400).json({ error: `Content must be at most ${MAX_CONTENT} characters` });
        return;
      }
      notesService.create(req.userId!, title, content);
      res.status(201).json({ message: 'Note created' });
    } catch (err) {
      next(err);
    }
  },

  update(req: AuthRequest, res: Response, next: NextFunction): void {
    try {
      const id = parseInt(req.params.id, 10);
      if (isNaN(id)) {
        res.status(400).json({ error: 'Note ID must be a number' });
        return;
      }
      const { title, content } = req.body;
      if (!title || !content) {
        res.status(400).json({ error: 'Title and content are required' });
        return;
      }
      if (title.length > MAX_TITLE) {
        res.status(400).json({ error: `Title must be at most ${MAX_TITLE} characters` });
        return;
      }
      if (content.length > MAX_CONTENT) {
        res.status(400).json({ error: `Content must be at most ${MAX_CONTENT} characters` });
        return;
      }
      notesService.update(id, req.userId!, title, content);
      res.status(200).json({ message: 'Note updated' });
    } catch (err) {
      next(err);
    }
  },

  delete(req: AuthRequest, res: Response, next: NextFunction): void {
    try {
      const id = parseInt(req.params.id, 10);
      if (isNaN(id)) {
        res.status(400).json({ error: 'Note ID must be a number' });
        return;
      }
      notesService.delete(id, req.userId!);
      res.status(200).json({ message: 'Note deleted' });
    } catch (err) {
      next(err);
    }
  },
};
