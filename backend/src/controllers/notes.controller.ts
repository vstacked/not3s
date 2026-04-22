import { Response, NextFunction } from 'express';
import { AuthRequest } from '../middlewares/auth.middleware';
import { notesService } from '../services/notes.service';

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
      notesService.create(req.userId!, title, content);
      res.status(201).json({ message: 'Note created' });
    } catch (err) {
      next(err);
    }
  },

  update(req: AuthRequest, res: Response, next: NextFunction): void {
    try {
      const { title, content } = req.body;
      const id = parseInt(req.params.id, 10);
      if (!title || !content) {
        res.status(400).json({ error: 'Title and content are required' });
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
      notesService.delete(id, req.userId!);
      res.status(200).json({ message: 'Note deleted' });
    } catch (err) {
      next(err);
    }
  },
};
