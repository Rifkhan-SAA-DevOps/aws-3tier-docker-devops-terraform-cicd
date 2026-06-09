import { createContext, useContext, useEffect, useMemo, useState } from "react";
import api from "../api/axios.js";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    const stored = localStorage.getItem("blog_user");
    return stored ? JSON.parse(stored) : null;
  });
  const [loading, setLoading] = useState(false);

  async function login(email, password) {
    setLoading(true);
    try {
      const { data } = await api.post("/auth/login", { email, password });
      localStorage.setItem("blog_token", data.data.token);
      localStorage.setItem("blog_user", JSON.stringify(data.data.user));
      setUser(data.data.user);
      return { ok: true };
    } catch (error) {
      return {
        ok: false,
        message: error.response?.data?.message || "Login failed",
      };
    } finally {
      setLoading(false);
    }
  }

  async function register(name, email, password) {
    setLoading(true);
    try {
      const { data } = await api.post("/auth/register", { name, email, password });
      localStorage.setItem("blog_token", data.data.token);
      localStorage.setItem("blog_user", JSON.stringify(data.data.user));
      setUser(data.data.user);
      return { ok: true };
    } catch (error) {
      return {
        ok: false,
        message: error.response?.data?.message || "Registration failed",
      };
    } finally {
      setLoading(false);
    }
  }

  function logout() {
    localStorage.removeItem("blog_token");
    localStorage.removeItem("blog_user");
    setUser(null);
  }

  useEffect(() => {
    async function loadMe() {
      const token = localStorage.getItem("blog_token");
      if (!token) return;

      try {
        const { data } = await api.get("/auth/me");
        setUser(data.data);
        localStorage.setItem("blog_user", JSON.stringify(data.data));
      } catch {
        logout();
      }
    }

    loadMe();
  }, []);

  const value = useMemo(
    () => ({ user, loading, login, register, logout, isAuthenticated: !!user }),
    [user, loading]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
