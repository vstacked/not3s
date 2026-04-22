import 'dotenv/config';
import { app } from './app';
import { runSeed } from './database/seed';

const PORT = process.env.PORT || 3000;

runSeed()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
      console.log(`Swagger docs: http://localhost:${PORT}/api-docs`);
    });
  })
  .catch((err) => {
    console.error('Startup failed:', err);
    process.exit(1);
  });
