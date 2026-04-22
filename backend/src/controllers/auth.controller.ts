import { Request, Response, NextFunction } from 'express';
import { authService } from '../services/auth.service';

const MAX_USERNAME = 50;
const MIN_PASSWORD = 8;
const MAX_PASSWORD = 128;

export const authController = {
  async register(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { username, password } = req.body;
      if (!username || !password) {
        res.status(400).json({ error: 'Username and password are required' });
        return;
      }
      if (username.length > MAX_USERNAME) {
        res.status(400).json({ error: `Username must be at most ${MAX_USERNAME} characters` });
        return;
      }
      if (password.length < MIN_PASSWORD) {
        res.status(400).json({ error: `Password must be at least ${MIN_PASSWORD} characters` });
        return;
      }
      if (password.length > MAX_PASSWORD) {
        res.status(400).json({ error: `Password must be at most ${MAX_PASSWORD} characters` });
        return;
      }
      await authService.register(username, password);
      res.status(201).json({ message: 'User registered successfully' });
    } catch (err) {
      next(err);
    }
  },

  async login(req: Request, res: Response, next: NextFunction): Promise<void> {
    try {
      const { username, password } = req.body;
      if (!username || !password) {
        res.status(400).json({ error: 'Username and password are required' });
        return;
      }
      const token = await authService.login(username, password);
      res.status(200).json({ message: 'Login successful', token });
    } catch (err) {
      next(err);
    }
  },
};
