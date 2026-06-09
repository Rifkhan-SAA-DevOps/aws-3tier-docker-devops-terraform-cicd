import { Link, NavLink } from "react-router-dom";
import { BookOpen, LogOut, PenSquare, UserCircle } from "lucide-react";
import { useAuth } from "../context/AuthContext.jsx";

export default function Navbar() {
  const { user, logout } = useAuth();

  return (
    <header className="navbar">
      <Link to="/" className="brand">
        <span className="brand-icon">
          <BookOpen size={20} />
        </span>
        Rifkhan
      </Link>

      <nav className="nav-links">
        <NavLink to="/">Explore</NavLink>
        {user && <NavLink to="/dashboard">Dashboard</NavLink>}
        {user && <NavLink to="/editor">Write</NavLink>}
        {user && <NavLink to="/categories">Categories</NavLink>}
      </nav>

      <div className="nav-actions">
        {user ? (
          <>
            <span className="user-chip">
              <UserCircle size={17} />
              {user.name}
            </span>
            <button className="ghost-btn" onClick={logout}>
              <LogOut size={16} /> Logout
            </button>
          </>
        ) : (
          <>
            <Link className="ghost-btn" to="/login">
              Login
            </Link>
            <Link className="primary-btn small" to="/register">
              <PenSquare size={16} /> Join
            </Link>
          </>
        )}
      </div>
    </header>
  );
}
