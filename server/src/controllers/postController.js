import slugify from "slugify";
import { body } from "express-validator";
import { pool } from "../config/db.js";
import { success, fail } from "../utils/apiResponse.js";

export const postRules = [
  body("title").trim().isLength({ min: 5 }).withMessage("Title is too short"),
  body("excerpt").trim().isLength({ min: 10 }).withMessage("Excerpt is required"),
  body("content").trim().isLength({ min: 50 }).withMessage("Content is too short"),
  body("category_id").isInt().withMessage("Category is required"),
  body("status").isIn(["draft", "published"]).withMessage("Invalid status"),
];

function createSlug(title) {
  const random = Math.random().toString(36).slice(2, 7);
  return `${slugify(title, { lower: true, strict: true })}-${random}`;
}

export async function getPosts(req, res) {
  const {
    search = "",
    category = "",
    status = "published",
    page = 1,
    limit = 9,
    mine = "false",
  } = req.query;

  const offset = (Number(page) - 1) * Number(limit);

  const conditions = [];
  const params = [];

  if (search) {
    conditions.push("(p.title LIKE ? OR p.excerpt LIKE ? OR p.content LIKE ?)");
    params.push(`%${search}%`, `%${search}%`, `%${search}%`);
  }

  if (category) {
    conditions.push("c.slug = ?");
    params.push(category);
  }

  if (status !== "all") {
    conditions.push("p.status = ?");
    params.push(status);
  }

  if (mine === "true" && req.user) {
    conditions.push("p.author_id = ?");
    params.push(req.user.id);
  }

  const where = conditions.length ? `WHERE ${conditions.join(" AND ")}` : "";

  const [posts] = await pool.query(
    `SELECT 
       p.id, p.title, p.slug, p.excerpt, p.cover_image, p.status,
       p.created_at, p.updated_at,
       c.name AS category_name, c.slug AS category_slug,
       u.name AS author_name,
       COUNT(cm.id) AS comment_count
     FROM posts p
     JOIN categories c ON c.id = p.category_id
     JOIN users u ON u.id = p.author_id
     LEFT JOIN comments cm ON cm.post_id = p.id
     ${where}
     GROUP BY p.id
     ORDER BY p.created_at DESC
     LIMIT ? OFFSET ?`,
    [...params, Number(limit), offset]
  );

  const [[countResult]] = await pool.query(
    `SELECT COUNT(DISTINCT p.id) AS total
     FROM posts p
     JOIN categories c ON c.id = p.category_id
     ${where}`,
    params
  );

  return success(res, "Posts fetched", {
    posts,
    pagination: {
      total: countResult.total,
      page: Number(page),
      pages: Math.ceil(countResult.total / Number(limit)),
    },
  });
}

export async function getPostById(req, res) {
  const { id } = req.params;

  const [posts] = await pool.query(
    `SELECT 
       p.*,
       c.name AS category_name,
       c.slug AS category_slug,
       u.name AS author_name,
       u.email AS author_email
     FROM posts p
     JOIN categories c ON c.id = p.category_id
     JOIN users u ON u.id = p.author_id
     WHERE p.id = ? OR p.slug = ?`,
    [id, id]
  );

  if (!posts.length) {
    return fail(res, "Post not found", 404);
  }

  return success(res, "Post fetched", posts[0]);
}

export async function createPost(req, res) {
  const { title, excerpt, content, category_id, cover_image, status } = req.body;

  const slug = createSlug(title);

  const [result] = await pool.query(
    `INSERT INTO posts 
      (title, slug, excerpt, content, cover_image, category_id, author_id, status)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      title,
      slug,
      excerpt,
      content,
      cover_image || "",
      category_id,
      req.user.id,
      status,
    ]
  );

  return success(
    res,
    "Post created",
    {
      id: result.insertId,
      slug,
    },
    201
  );
}

export async function updatePost(req, res) {
  const { id } = req.params;
  const { title, excerpt, content, category_id, cover_image, status } = req.body;

  const [posts] = await pool.query("SELECT * FROM posts WHERE id = ?", [id]);

  if (!posts.length) {
    return fail(res, "Post not found", 404);
  }

  const post = posts[0];

  if (req.user.role !== "admin" && post.author_id !== req.user.id) {
    return fail(res, "You can update only your own post", 403);
  }

  await pool.query(
    `UPDATE posts 
     SET title = ?, excerpt = ?, content = ?, category_id = ?, cover_image = ?, status = ?
     WHERE id = ?`,
    [title, excerpt, content, category_id, cover_image || "", status, id]
  );

  return success(res, "Post updated");
}

export async function deletePost(req, res) {
  const { id } = req.params;

  const [posts] = await pool.query("SELECT * FROM posts WHERE id = ?", [id]);

  if (!posts.length) {
    return fail(res, "Post not found", 404);
  }

  const post = posts[0];

  if (req.user.role !== "admin" && post.author_id !== req.user.id) {
    return fail(res, "You can delete only your own post", 403);
  }

  await pool.query("DELETE FROM posts WHERE id = ?", [id]);

  return success(res, "Post deleted");
}
