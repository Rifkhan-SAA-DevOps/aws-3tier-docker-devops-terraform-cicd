import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function Login() {
  const { login, loading } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ email: "admin@example.com", password: "Admin@123" });
  const [error, setError] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();
    const result = await login(form.email, form.password);

    if (!result.ok) {
      setError(result.message);
      return;
    }

    navigate("/dashboard");
  }

  return (
    <div className="auth-card">
      <h1>Welcome back</h1>
      <p>Login to manage your blog posts and comments.</p>

      {error && <div className="alert error">{error}</div>}

      <form onSubmit={handleSubmit} className="form-stack">
        <label>Email</label>
        <input
          value={form.email}
          onChange={(e) => setForm({ ...form, email: e.target.value })}
        />

        <label>Password</label>
        <input
          type="password"
          value={form.password}
          onChange={(e) => setForm({ ...form, password: e.target.value })}
        />

        <button className="primary-btn" disabled={loading}>
          {loading ? "Logging in..." : "Login"}
        </button>
      </form>

      <p className="muted">
        No account? <Link to="/register">Create one</Link>
      </p>
    </div>
  );
}
