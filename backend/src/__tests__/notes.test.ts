import request from 'supertest';
import { app } from '../app';
import { db } from '../database/database';
import { registerUser, loginUser } from './helpers';

let tokenAlice: string;
let tokenBob: string;

beforeEach(async () => {
  db.exec('DELETE FROM notes');
  db.exec('DELETE FROM users');

  await registerUser('alice', 'password123');
  await registerUser('bob', 'password123');
  tokenAlice = await loginUser('alice', 'password123');
  tokenBob = await loginUser('bob', 'password123');
});

// ─── GET /api/notes ──────────────────────────────────────────────────────────

describe('GET /api/notes', () => {
  it('200 — returns empty array when user has no notes', async () => {
    const res = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);

    expect(res.status).toBe(200);
    expect(res.body).toEqual([]);
  });

  it('200 — returns only the authenticated user\'s notes', async () => {
    await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Alice note', content: 'Alice content' });

    await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenBob}`)
      .send({ title: 'Bob note', content: 'Bob content' });

    const res = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveLength(1);
    expect(res.body[0]).toMatchObject({ title: 'Alice note' });
  });

  it('200 — each note has id, title, content', async () => {
    await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Test', content: 'Body' });

    const res = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);

    expect(res.body[0]).toHaveProperty('id');
    expect(res.body[0]).toHaveProperty('title', 'Test');
    expect(res.body[0]).toHaveProperty('content', 'Body');
  });

  it('401 — no token', async () => {
    const res = await request(app).get('/api/notes');
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('401 — malformed token', async () => {
    const res = await request(app)
      .get('/api/notes')
      .set('Authorization', 'Bearer not.a.valid.token');

    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('401 — Bearer prefix missing', async () => {
    const res = await request(app)
      .get('/api/notes')
      .set('Authorization', tokenAlice);

    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });
});

// ─── POST /api/notes ─────────────────────────────────────────────────────────

describe('POST /api/notes', () => {
  it('201 — creates a note', async () => {
    const res = await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'New note', content: 'Some content' });

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('message');
  });

  it('400 — missing title', async () => {
    const res = await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ content: 'No title here' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('400 — missing content', async () => {
    const res = await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'No content here' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('400 — title exceeds 200 characters', async () => {
    const res = await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'a'.repeat(201), content: 'Valid content' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('401 — no token', async () => {
    const res = await request(app)
      .post('/api/notes')
      .send({ title: 'Note', content: 'Body' });

    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });
});

// ─── PUT /api/notes/:id ───────────────────────────────────────────────────────

describe('PUT /api/notes/:id', () => {
  let noteId: number;

  beforeEach(async () => {
    await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Original', content: 'Original content' });

    const notesRes = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);

    noteId = notesRes.body[0].id as number;
  });

  it('200 — updates the note', async () => {
    const res = await request(app)
      .put(`/api/notes/${noteId}`)
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Updated', content: 'Updated content' });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('message');

    const check = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);
    expect(check.body[0]).toMatchObject({
      title: 'Updated',
      content: 'Updated content',
    });
  });

  it('400 — missing title', async () => {
    const res = await request(app)
      .put(`/api/notes/${noteId}`)
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ content: 'Updated content' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('400 — missing content', async () => {
    const res = await request(app)
      .put(`/api/notes/${noteId}`)
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Updated' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('401 — no token', async () => {
    const res = await request(app)
      .put(`/api/notes/${noteId}`)
      .send({ title: 'Updated', content: 'Updated content' });

    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('400 — non-numeric ID', async () => {
    const res = await request(app)
      .put('/api/notes/abc')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Updated', content: 'Updated content' });

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('404 — note does not exist', async () => {
    const res = await request(app)
      .put('/api/notes/99999')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'Updated', content: 'Updated content' });

    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });

  it('404 — cannot update another user\'s note', async () => {
    const res = await request(app)
      .put(`/api/notes/${noteId}`)
      .set('Authorization', `Bearer ${tokenBob}`)
      .send({ title: 'Hijacked', content: 'Hijacked content' });

    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });
});

// ─── DELETE /api/notes/:id ────────────────────────────────────────────────────

describe('DELETE /api/notes/:id', () => {
  let noteId: number;

  beforeEach(async () => {
    await request(app)
      .post('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`)
      .send({ title: 'To delete', content: 'Will be deleted' });

    const notesRes = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);

    noteId = notesRes.body[0].id as number;
  });

  it('200 — deletes the note', async () => {
    const res = await request(app)
      .delete(`/api/notes/${noteId}`)
      .set('Authorization', `Bearer ${tokenAlice}`);

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('message');

    const check = await request(app)
      .get('/api/notes')
      .set('Authorization', `Bearer ${tokenAlice}`);
    expect(check.body).toHaveLength(0);
  });

  it('401 — no token', async () => {
    const res = await request(app).delete(`/api/notes/${noteId}`);
    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error');
  });

  it('400 — non-numeric ID', async () => {
    const res = await request(app)
      .delete('/api/notes/abc')
      .set('Authorization', `Bearer ${tokenAlice}`);

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error');
  });

  it('404 — note does not exist', async () => {
    const res = await request(app)
      .delete('/api/notes/99999')
      .set('Authorization', `Bearer ${tokenAlice}`);

    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });

  it('404 — cannot delete another user\'s note', async () => {
    const res = await request(app)
      .delete(`/api/notes/${noteId}`)
      .set('Authorization', `Bearer ${tokenBob}`);

    expect(res.status).toBe(404);
    expect(res.body).toHaveProperty('error');
  });
});
