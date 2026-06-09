import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import api from "../api/axios.js";

const emptyForm = {
  title: "",
  excerpt: "",
  content: "",
  cover_image: "",
  category_id: "",
  status: "draft",
};

export default function PostEditor() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [categories, setCategories] = useState([]);
  const [form, setForm] = useState(emptyForm);
  const [error, setError] = useState("");

  async function loadData() {
    const categoryRes = await api.get("/categories");
    setCategories(categoryRes.data.data);

    if (id) {
      const { data } = await api.get(`/posts/${id}`);
      const post = data.data;
      setForm({
        title: post.title,
        excerpt: post.excerpt,
        content: post.content,
        cover_image: post.cover_image || "",
        category_id: post.category_id,
        status: post.status,
      });
    }
  }

  async function handleSubmit(event) {
    event.preventDefault();

    try {
      if (id) {
        await api.put(`/posts/${id}`, form);
      } else {
        await api.post("/posts", form);
      }

      navigate("/dashboard");
    } catch (error) {
      setError(error.response?.data?.message || "Save failed");
    }
  }

  useEffect(() => {
    loadData();
  }, [id]);

  return (
    <div className="editor-layout">
      <div className="page-header">
        <div>
          <span className="eyebrow">{id ? "Edit Post" : "New Post"}</span>
          <h1>{id ? "Update your article" : "Create a new article"}</h1>
        </div>
      </div>

      {error && <div className="alert error">{error}</div>}

      <form className="editor-form" onSubmit={handleSubmit}>
        <label>Title</label>
        <input
          value={form.title}
          onChange={(e) => setForm({ ...form, title: e.target.value })}
          placeholder="Example: How to deploy React and Node on AWS"
        />

        <label>Excerpt</label>
        <textarea
          value={form.excerpt}
          onChange={(e) => setForm({ ...form, excerpt: e.target.value })}
          placeholder="Short summary"
        />

        <label>Cover Image URL</label>
        <input
          value={form.cover_image}
          onChange={(e) => setForm({ ...form, cover_image: e.target.value })}
          placeholder="https://..."
        />

        <div className="two-col">
          <div>
            <label>Category</label>
            <select
              value={form.category_id}
              onChange={(e) => setForm({ ...form, category_id: e.target.value })}
            >
              <option value="">Select category</option>
              {categories.map((cat) => (
                <option value={cat.id} key={cat.id}>{cat.name}</option>
              ))}
            </select>
          </div>

          <div>
            <label>Status</label>
            <select
              value={form.status}
              onChange={(e) => setForm({ ...form, status: e.target.value })}
            >
              <option value="draft">Draft</option>
              <option value="published">Published</option>
            </select>
          </div>
        </div>

        <label>Content</label>
        <textarea
          className="content-editor"
          value={form.content}
          onChange={(e) => setForm({ ...form, content: e.target.value })}
          placeholder="Write the full article..."
        />

        <button className="primary-btn">{id ? "Update Post" : "Create Post"}</button>
      </form>
    </div>
  );
}
