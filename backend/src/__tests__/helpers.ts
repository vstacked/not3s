import request from 'supertest';
import { app } from '../app';

export async function registerUser(
  username: string,
  password: string,
): Promise<void> {
  await request(app).post('/api/auth/register').send({ username, password });
}

export async function loginUser(
  username: string,
  password: string,
): Promise<string> {
  const res = await request(app)
    .post('/api/auth/login')
    .send({ username, password });
  return res.body.token as string;
}
