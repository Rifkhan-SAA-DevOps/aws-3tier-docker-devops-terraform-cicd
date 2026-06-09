import { body } from "express-validator";
import { pool } from "../config/db.js";
import { success, fail } from "../utils/apiResponse.js";

export const commentRules = [
  body("content").trim().isLength({ min: 2 }).withMessage("Comment required"),
];

export async function getComments(req, res) {
  const { postId } = req.params;

  const [comments] = await pool.query(
    `SELECT cm.*, u.name AS user_name
     FROM comments cm
     JOIN users u ON u.id = cm.user_id
     WHERE cm.post_id = ?
     ORDER BY cm.created_at DESC`,
    [postId]
  );

  return success(res, "Comments fetched", comments);
}

export async function createComment(req, res) {
  const { postId } = req.params;
  const { content } = req.body;

  const [posts] = await pool.query("SELECT id FROM posts WHERE id = ?", [
    postId,
  ]);

  if (!posts.length) {
    return fail(res, "Post not found", 404);
  }

  const [result] = await pool.query(
    "INSERT INTO comments (content, post_id, user_id) VALUES (?, ?, ?)",
    [content, postId, req.user.id]
  );

  return success(
    res,
    "Comment added",
    {
      id: result.insertId,
      content,
    },
    201
  );
}

export async function deleteComment(req, res) {
  const { id } = req.params;

  const [comments] = await pool.query("SELECT * FROM comments WHERE id = ?", [
    id,
  ]);

  if (!comments.length) {
    return fail(res, "Comment not found", 404);
  }

  const comment = comments[0];

  if (req.user.role !== "admin" && comment.user_id !== req.user.id) {
    return fail(res, "You can delete only your own comment", 403);
  }

  await pool.query("DELETE FROM comments WHERE id = ?", [id]);

  return success(res, "Comment deleted");
}
