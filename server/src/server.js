import dotenv from "dotenv";
import app from "./app.js";
import { testDbConnection } from "./config/db.js";

dotenv.config();

const PORT = process.env.PORT || 5000;

async function startServer() {
  try {
    await testDbConnection();
    console.log("✅ MySQL connected");

    app.listen(PORT, "0.0.0.0", () => {
      // This 0.0.0.0 is important inside Docker.
      console.log(`🚀 API running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("❌ Server startup failed:", error.message);
    process.exit(1);
  }
}

startServer();
