import { fail } from "../utils/apiResponse.js";

export function notFound(req, res, next) {
  return fail(res, `Route not found: ${req.originalUrl}`, 404);
}

export function errorHandler(err, req, res, next) {
  console.error("ERROR:", err);
  return fail(
    res,
    err.message || "Internal server error",
    err.statusCode || 500
  );
}
