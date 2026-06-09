import { useEffect, useState } from "react";
import api from "../api/axios.js";
import { useAuth } from "../context/AuthContext.jsx";

export default function Categories() {
  const { user } = useAuth();
  const [categories, setCategories] = useState([]);
  const [name, setName] = useState("");

  async function loadCategories() {
    const { data } = await api.get("/categories");
    setCategories(data.data);
  }

  async function createCategory(event) {
    event.preventDefault();
    if (!name.trim()) return;
    await api.post("/categories", { name });
    setName("");
    loadCategories();
  }

  async function deleteCategory(id) {
    await api.delete(`/categories/${id}`);
    loadCategories();
  }

  useEffect(() => {
    loadCategories();
  }, []);

  return (
    <div>
      <div className="page-header">
        <div>
          <span className="eyebrow">Categories</span>
          <h1>Organize blog topics</h1>
        </div>
      </div>

      <form className="category-form" onSubmit={createCategory}>
        <input
          placeholder="New category name"
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <button className="primary-btn">Add Category</button>
      </form>

      <div className="category-grid">
        {categories.map((cat) => (
          <div className="category-card" key={cat.id}>
            <h3>{cat.name}</h3>
            <p>{cat.post_count} posts</p>
            {user?.role === "admin" && (
              <button className="ghost-btn danger-text" onClick={() => deleteCategory(cat.id)}>
                Delete
              </button>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
