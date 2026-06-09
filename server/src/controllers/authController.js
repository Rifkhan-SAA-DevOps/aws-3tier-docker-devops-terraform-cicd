import bcrypt from "bcryptjs";
import { body } from "express-validator";
import { pool } from "../config/db.js";
import { success, fail } from "../utils/apiResponse.js";
import { generateToken } from "../utils/generateToken.js";

export const registerRules = [
  body("name").trim().isLength({ min: 2 }).withMessage("Name is required"),
  body("email").isEmail().withMessage("Valid email is required"),
  body("password")
    .isLength({ min: 8 })
    .withMessage("Password should be at least 8 characters"),
];

export async function register(req, res) {
  const { name, email, password } = req.body;

  const [existing] = await pool.query("SELECT id FROM users WHERE email = ?", [
    email,
  ]);

  if (existing.length) {
    return fail(res, "Email already exists", 409);
  }

  const passwordHash = await bcrypt.hash(password, 12);

  const [result] = await pool.query(
    "INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)",
    [name, email, passwordHash, "author"]
  );

  const user = {
    id: result.insertId,
    name,
    email,
    role: "author",
  };

  return success(
    res,
    "Account created successfully",
    {
      user,
      token: generateToken(user),
    },
    201
  );
}

export const loginRules = [
  body("email").isEmail().withMessage("Valid email is required"),
  body("password").notEmpty().withMessage("Password is required"),
];

export async function login(req, res) {
  const { email, password } = req.body;

  const [users] = await pool.query("SELECT * FROM users WHERE email = ?", [
    email,
  ]);

  if (!users.length) {
    return fail(res, "Invalid email or password", 401);
  }

  const user = users[0];

  const isMatch = await bcrypt.compare(password, user.password_hash);

  if (!isMatch) {
    return fail(res, "Invalid email or password", 401);
  }

  const safeUser = {
    id: user.id,
    name: user.name,
    email: user.email,
    role: user.role,
    created_at: user.created_at,
  };

  return success(res, "Logged in successfully", {
    user: safeUser,
    token: generateToken(safeUser),
  });
}

export async function me(req, res) {
  return success(res, "Current user", req.user);
}
