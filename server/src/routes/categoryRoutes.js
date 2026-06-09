import express from "express";
import {
  categoryRules,
  createCategory,
  deleteCategory,
  getCategories,
} from "../controllers/categoryController.js";
import { authorize, protect } from "../middleware/authMiddleware.js";
import { validate } from "../middleware/validate.js";

const router = express.Router();

router.get("/", getCategories);
router.post("/", protect, authorize("admin", "author"), categoryRules, validate, createCategory);
router.delete("/:id", protect, authorize("admin"), deleteCategory);

export default router;
