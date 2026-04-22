---

Date/Time: 2026-04-22 04:00 WIB

Task: Create boilerplate for backend and flutter_app folders with required libraries

Prompt Used: based on @.cursorrules , create the boilerplate for backend & flutter_app folder with install libary what we needed for now (like bloc, express etc).

for flutter you can referencing from [https://github.com/vstacked/pokedex-] to flutter_app
while for backend from [https://github.com/w3tecch/express-typescript-boilerplate#-getting-started] to backend folder

do it with minimal setup first, and makesure separate the scope (backend & flutter_app)

Commit Hash: d9590fa8b0317f17c85f89794c3fe5ac0d2d6184

---

Date/Time: 2026-04-22 09:30 WIB

Task: Implement API contract endpoints for auth & notes with Swagger docs, and Flutter data/domain models

Prompt Used: use this API as a contract between backend and client flutter.

Global Rule for Errors (400, 401, 404, 500)
{ "error": "A user-friendly error message here" }

POST /api/auth/register [Request Body: username, password] | 201 { message }
POST /api/auth/login [Request Body: username, password] | 200 { message, token }
GET /api/notes [Bearer Token] | 200 [ { id, title, content } ]
POST /api/notes [Bearer Token, Request Body: title, content] | 201
PUT /api/notes/{id} [Bearer Token, Request Body: title, content] | 200
DELETE /api/notes/{id} [Bearer Token] | 200

made the notes attach to account that logged in, so we use bearer token for validating,

for backend, create endpoint based on this contract while generate Swagger documentation after finished.
for flutter_app, create models based this contract on features scope [data & domain]

Commit Hash: 94bea78950441308fd1259259171156607d49516

---

Date/Time: 2026-04-22 10:15 WIB

Task: Seed sample data on startup and write integration tests with Jest & Supertest covering edge cases

Prompt Used: backend,

seed sample data for the first time or can by auto-run on startup.

2nd, write integration tests using jest & supertest, also handle the edge-cases when the output is not success

Commit Hash: a0db0e11106da1638b3c5c1bab83c9d05ba47198

---

Date/Time: 2026-04-22 11:20 WIB

Task: Security hardening — fix edge cases identified in backend audit

Plan identified 5 issues. All were implemented:

1. NaN guard on :id path param (notes PUT/DELETE)
   - parseInt("abc") → NaN was silently passed to SQLite as NULL, causing a phantom 404
   - Fix: explicit isNaN(id) check → 400 "Note ID must be a number"

2. Input length validation (auth + notes controllers)
   - username: max 50 chars
   - password: min 8, max 128 chars
   - title: max 200 chars, content: max 10,000 chars
   - Fix: length guards added in each controller before hitting the service

3. Body size limit (app.ts)
   - express.json() previously accepted unlimited payloads
   - Fix: express.json({ limit: "50kb" }) and urlencoded({ limit: "50kb" })

4. JWT_SECRET production startup guard (server.ts)
   - Server booted silently with a weak hardcoded fallback if JWT_SECRET was unset
   - Fix: process.exit(1) with fatal log when NODE_ENV=production and JWT_SECRET is missing

5. Rate limiting on auth routes
   - POST /auth/login and /auth/register had no throttle (brute-force risk)
   - Fix: express-rate-limit, 20 requests per 15 min window, skipped in NODE_ENV=test

Tests: 6 new test cases added (auth field length, notes NaN ID, notes title length) — 36 total, all passing.

Prompt Used: check on backend, are we already handle like, sql injection? or other edge case → wrap up this plan, then implement it, then added to AI_PROMPT_README.md with mentioning our plan

Commit Hash:

---

Date/Time: 2026-04-22 11:30 WIB

Task: Implement data & domain layers for auth and notes features in flutter_app with secure token storage

Prompt Used: flutter_app,

implement the data & domain on each feature, we need to:
data sources [data]
repositores [data]
repositores [domain]
use cases [domain]

handle the interceptor to handle token user and save locally using flutter_secure_storage.

follow the existing core to generate data & domain, then call the injections

Commit Hash:

---

Date/Time: 2026-04-22 11:55 WIB

Task: Generate theme via Stitch MCP, build auth presentation layer, then refine light theme and auth mode handling in BLoC

Prompt Used: use Stich MCP to generate theme of this flutter apps, then move to login/register page in same file, but using state for change each view. extract the small components for reduce redundancy

Plan executed:
1. Created Stitch project `not3s` (projects/12196017803135880158)
2. Created `not3s Design System` via Stitch MCP:
   - Initial color mode: DARK, Seed: #6C63FF (indigo-violet), Variant: TONAL_SPOT
   - Headline font: Space Grotesk, Body/Label: Inter, Roundness: ROUND_EIGHT
3. Generated Login/Register mobile screen via Stitch (Gemini 3.1 Pro)
4. Updated `core/styles/app_theme.dart` — switched ThemeData to Material 3 light mode
5. Created `core/styles/app_colors.dart` — centralized color constants
6. Extracted small shared components:
   - `core/widgets/app_text_field.dart` — AppTextField
   - `core/widgets/app_button.dart` — AppButton (full-width, loading state)
7. Added AuthBloc presentation layer (bloc/event/state)
8. Created `features/auth/presentation/pages/auth_page.dart` — single file, state-based login/register view switching
9. Updated router, main.dart, auth_injections.dart
10. Added google_fonts to pubspec.yaml
--- Additional changes (NOT from original Prompt Used) ---
11. [EXTRA] Updated `core/styles/app_colors.dart` hex palette to light-mode values (background/surface/text/border/hint/divider/error)
12. [EXTRA] Added outside-tap keyboard dismiss behavior on `features/auth/presentation/pages/auth_page.dart`
13. [EXTRA] Moved auth mode source of truth from local widget state into `AuthBloc` state/event flow
14. [EXTRA] Removed deprecated `AuthReset` event/handler after mode migration cleanup
15. [EXTRA] Hardened `AuthState.mode` initialization to avoid null mode runtime crash

Commit Hash:
