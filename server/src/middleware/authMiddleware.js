import jwt from "jsonwebtoken";
import { pool } from "../config/db.js";
import { fail } from "../utils/apiResponse.js";

export async function protect(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return fail(res, "Not authorized. Token missing.", 401);
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const [users] = await pool.query(
      "SELECT id, name, email, role, created_at FROM users WHERE id = ?",
      [decoded.id]
    );

    if (!users.length) {
      return fail(res, "User not found.", 401);
    }

    req.user = users[0];
    next();
  } catch (error) {
    return fail(res, "Not authorized. Invalid token.", 401);
  }
}

export function authorize(...roles) {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return fail(res, "Forbidden. You do not have permission.", 403);
    }
    next();
  };
}
