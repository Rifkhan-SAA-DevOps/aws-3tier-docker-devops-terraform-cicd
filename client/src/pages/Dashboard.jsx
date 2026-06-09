import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Edit, Plus, Trash2 } from "lucide-react";
import api from "../api/axios.js";
import { useAuth } from "../context/AuthContext.jsx";

export default function Dashboard() {
  const { user } = useAuth();
  const [posts, setPosts] = useState([]);

  async function loadPosts() {
    const mine = user?.role === "admin" ? "false" : "true";
    const { data } = await api.get(`/posts?status=all&mine=${mine}`);
    setPosts(data.data.posts);
  }

  async function deletePost(id) {
    const ok = window.confirm("Delete this post?");
    if (!ok) return;

    await api.delete(`/posts/${id}`);
    loadPosts();
  }

  useEffect(() => {
    loadPosts();
  }, []);

  return (
    <div>
      <div className="page-header">
        <div>
          <span className="eyebrow">Dashboard</span>
          <h1>Manage your articles</h1>
        </div>
        <Link to="/editor" className="primary-btn">
          <Plus size={18} /> New Post
        </Link>
      </div>

      <div className="table-card">
        <table>
          <thead>
            <tr>
              <th>Title</th>
              <th>Category</th>
              <th>Status</th>
              <th>Author</th>
              <th>Updated</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {posts.map((post) => (
              <tr key={post.id}>
                <td>{post.title}</td>
                <td>{post.category_name}</td>
                <td><span className={`status ${post.status}`}>{post.status}</span></td>
                <td>{post.author_name}</td>
                <td>{new Date(post.updated_at).toLocaleDateString()}</td>
                <td className="row-actions">
                  <Link className="icon-btn" to={`/editor/${post.id}`}>
                    <Edit size={16} />
                  </Link>
                  <button className="icon-btn danger" onClick={() => deletePost(post.id)}>
                    <Trash2 size={16} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {!posts.length && <div className="empty-state">No posts yet.</div>}
      </div>
    </div>
  );
}
