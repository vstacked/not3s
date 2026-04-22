# not3s

A simple, full-stack note-taking application built as a technical assessment. The project consists of a RESTful backend API and a cross-platform mobile frontend.

---

## Sample Login Credentials

Two seed accounts are created automatically on first launch:

| Username | Password      |
|----------|---------------|
| `alice`  | `password123` |
| `bob`    | `password123` |

---

## Project Overview

**not3s** lets a user register, log in, and manage personal notes (create, read, update, delete). Each user's notes are private and protected by JWT authentication.

- **Frontend** — Flutter app using BLoC for state management and Clean Architecture for layering.
- **Backend** — Node.js/Express REST API backed by a local SQLite database, written in TypeScript.

---

## Tech Stack

### Backend (`/backend`)

| Concern | Library / Tool |
|---|---|
| Runtime | Node.js ≥ 18 |
| Language | TypeScript 5 |
| Framework | Express 4 |
| Database | SQLite via `better-sqlite3` 9 |
| Authentication | `jsonwebtoken` (JWT) + `bcryptjs` |
| Security | `helmet`, `cors`, `express-rate-limit` |
| API Docs | Swagger (`swagger-jsdoc` + `swagger-ui-express`) |
| Testing | Jest + Supertest |
| Package Manager | Yarn 1 |

### Frontend (`/flutter_app`)

| Concern | Library / Tool |
|---|---|
| SDK | Flutter 3 (Dart SDK ≥ 3.3) |
| State Management | `flutter_bloc` 9 / `bloc` 9 |
| HTTP Client | `dio` 5 |
| Dependency Injection | `get_it` 9 |
| Functional Error Handling | `dartz` (Either type) |
| Token Persistence | `flutter_secure_storage` 9 |
| Fonts | `google_fonts` 6 |
| Testing | `bloc_test`, `mocktail`, `integration_test` |

---

## Project Structure

```
not3s/
├── backend/               # Node.js / Express / TypeScript API
│   └── src/
│       ├── controllers/   # Request handlers (auth, notes)
│       ├── database/      # SQLite init, migrations, seed
│       ├── middlewares/   # JWT auth, rate limiting
│       ├── routes/        # Route definitions
│       ├── services/      # Business logic
│       └── __tests__/     # Jest integration tests
└── flutter_app/           # Flutter mobile app
    └── lib/
        ├── core/          # Shared utilities, errors, network client
        ├── features/
        │   ├── auth/      # Login & registration (data / domain / presentation)
        │   ├── notes/     # Notes CRUD (data / domain / presentation / BLoC)
        │   ├── splash/    # Splash screen
        │   └── welcome/   # Onboarding / welcome screen
        └── shared/        # Shared widgets
```

---

## Local Setup

### Prerequisites

- Node.js ≥ 18
- Yarn (`npm install -g yarn`)
- Flutter SDK ≥ 3.3 ([install guide](https://docs.flutter.dev/get-started/install))

---

### 1. Backend

```bash
cd backend
yarn install
yarn dev
```

The server starts on **`http://localhost:3000`**.

> **Database is fully automatic.** On first start, `better-sqlite3` creates the SQLite file, runs migrations (creates `users` and `notes` tables), and seeds two sample accounts (`alice` and `bob`) with pre-populated notes. No manual setup is required.

Interactive API documentation is available at:

```
http://localhost:3000/api-docs
```

#### Available Scripts

| Command | Description |
|---|---|
| `yarn dev` | Start with hot-reload via `nodemon` + `ts-node` |
| `yarn build` | Compile TypeScript to `dist/` |
| `yarn start` | Run compiled production build |
| `yarn test` | Run Jest test suite |

---

### 2. Flutter App

Ensure the backend is running first, then in a separate terminal:

```bash
cd flutter_app
flutter pub get
flutter run
```

> By default the app points to `http://10.0.2.2:3000` for Android emulators (which maps to `localhost` on the host machine) and `http://localhost:3000` for other targets. Adjust the base URL in `lib/core/` if needed for a physical device.

#### Running Tests

```bash
# Unit & widget tests
flutter test

# Integration tests (requires a running emulator/device)
flutter test integration_test/
```

---

## API Endpoints

All notes endpoints require a `Bearer <token>` header.

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/api/auth/register` | — | Register a new user |
| `POST` | `/api/auth/login` | — | Login and receive a JWT |
| `GET` | `/api/notes` | ✓ | List all notes for the logged-in user |
| `POST` | `/api/notes` | ✓ | Create a new note |
| `PUT` | `/api/notes/:id` | ✓ | Update a note |
| `DELETE` | `/api/notes/:id` | ✓ | Delete a note |
| `GET` | `/api/health` | — | Health check |

---

## AI-Assisted Development

AI (Claude via Cursor) was used throughout this project as a **pair-programming tool** — generating boilerplate, suggesting architecture decisions, writing tests, and reviewing code. It was not used to blindly generate the entire codebase; all output was reviewed, adapted, and integrated deliberately.

For the full methodology, every prompt used, and a breakdown of what was AI-assisted versus written by hand, see:

**[`AI_PROMPT_README.md`](./AI_PROMPT_README.md)**
