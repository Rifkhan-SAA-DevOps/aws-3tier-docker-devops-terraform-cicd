import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function Register() {
  const { register, loading } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [error, setError] = useState("");

  async function handleSubmit(event) {
    event.preventDefault();
    const result = await register(form.name, form.email, form.password);

    if (!result.ok) {
      setError(result.message);
      return;
    }

    navigate("/dashboard");
  }

  return (
    <div className="auth-card">
      <h1>Create account</h1>
      <p>Join as an author and start publishing articles.</p>

      {error && <div className="alert error">{error}</div>}

      <form onSubmit={handleSubmit} className="form-stack">
        <label>Name</label>
        <input
          value={form.name}
          onChange={(e) => setForm({ ...form, name: e.target.value })}
        />

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
          {loading ? "Creating..." : "Register"}
        </button>
      </form>

      <p className="muted">
        Already have an account? <Link to="/login">Login</Link>
      </p>
    </div>
  );
}
