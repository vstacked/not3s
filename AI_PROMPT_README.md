---

Date/Time: 2026-04-22 04:00 WIB

Task: Create boilerplate for backend and flutter_app folders with required libraries

Prompt Used: based on @.cursorrules , create the boilerplate for backend & flutter_app folder with install libary what we needed for now (like bloc, express etc).

for flutter you can referencing from [https://github.com/vstacked/pokedex-] to flutter_app
while for backend from [https://github.com/w3tecch/express-typescript-boilerplate#-getting-started] to backend folder

do it with minimal setup first, and makesure separate the scope (backend & flutter_app)

Commit Hash:

---

Date/Time: 2026-04-22 05:30 WIB

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

Commit Hash: d9590fa8b0317f17c85f89794c3fe5ac0d2d6184
