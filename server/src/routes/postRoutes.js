import express from "express";
import {
  createPost,
  deletePost,
  getPostById,
  getPosts,
  postRules,
  updatePost,
} from "../controllers/postController.js";
import {
  createComment,
  deleteComment,
  getComments,
  commentRules,
} from "../controllers/commentController.js";
import { authorize, protect } from "../middleware/authMiddleware.js";
import { validate } from "../middleware/validate.js";

const router = express.Router();

router.get("/", getPosts);
router.get("/:id", getPostById);

router.post("/", protect, authorize("admin", "author"), postRules, validate, createPost);
router.put("/:id", protect, authorize("admin", "author"), postRules, validate, updatePost);
router.delete("/:id", protect, authorize("admin", "author"), deletePost);

router.get("/:postId/comments", getComments);
router.post("/:postId/comments", protect, commentRules, validate, createComment);
router.delete("/comments/:id", protect, deleteComment);

export default router;
