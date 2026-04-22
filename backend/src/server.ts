import "dotenv/config";
import { app } from "./app";
import { db } from "./database/database";

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
