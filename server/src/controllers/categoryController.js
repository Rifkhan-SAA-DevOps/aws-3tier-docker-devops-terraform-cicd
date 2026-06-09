import slugify from "slugify";
import { body } from "express-validator";
import { pool } from "../config/db.js";
import { success, fail } from "../utils/apiResponse.js";

export const categoryRules = [
  body("name").trim().isLength({ min: 2 }).withMessage("Category name required"),
];

export async function getCategories(req, res) {
  const [categories] = await pool.query(
    `SELECT c.*, COUNT(p.id) AS post_count
     FROM categories c
     LEFT JOIN posts p ON p.category_id = c.id
     GROUP BY c.id
     ORDER BY c.name ASC`
  );

  return success(res, "Categories fetched", categories);
}

export async function createCategory(req, res) {
  const { name } = req.body;
  const slug = slugify(name, { lower: true, strict: true });

  try {
    const [result] = await pool.query(
      "INSERT INTO categories (name, slug) VALUES (?, ?)",
      [name, slug]
    );

    return success(
      res,
      "Category created",
      {
        id: result.insertId,
        name,
        slug,
      },
      201
    );
  } catch (error) {
    return fail(res, "Category already exists", 409);
  }
}

export async function deleteCategory(req, res) {
  const { id } = req.params;

  const [posts] = await pool.query(
    "SELECT id FROM posts WHERE category_id = ? LIMIT 1",
    [id]
  );

  if (posts.length) {
    return fail(res, "Cannot delete category with existing posts", 400);
  }

  await pool.query("DELETE FROM categories WHERE id = ?", [id]);

  return success(res, "Category deleted");
}
