import { useEffect, useState } from "react";
import { Search } from "lucide-react";
import api from "../api/axios.js";
import PostCard from "../components/PostCard.jsx";

export default function Home() {
  const [posts, setPosts] = useState([]);
  const [categories, setCategories] = useState([]);
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [loading, setLoading] = useState(true);

  async function loadData() {
    setLoading(true);
    const query = new URLSearchParams({
      search,
      category,
      status: "published",
    }).toString();

    const [postRes, categoryRes] = await Promise.all([
      api.get(`/posts?${query}`),
      api.get("/categories"),
    ]);

    setPosts(postRes.data.data.posts);
    setCategories(categoryRes.data.data);
    setLoading(false);
  }

  useEffect(() => {
    loadData();
  }, []);

  function handleSubmit(event) {
    event.preventDefault();
    loadData();
  }

  return (
    <div>
      <section className="hero">
        <div>
          <span className="eyebrow">Fullstack Blog Platform</span>
          <h1>Read, write, manage and deploy real-world blog content.</h1>
          <p>
            A modern React + Node + Express + MySQL CRUD project designed for AWS 3-tier deployment practice.
          </p>

          <form className="search-bar" onSubmit={handleSubmit}>
            <Search size={18} />
            <input
              placeholder="Search cloud, devops, react..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
            <select value={category} onChange={(e) => setCategory(e.target.value)}>
              <option value="">All categories</option>
              {categories.map((cat) => (
                <option key={cat.id} value={cat.slug}>
                  {cat.name}
                </option>
              ))}
            </select>
            <button className="primary-btn">Search</button>
          </form>
        </div>
      </section>

      {loading ? (
        <div className="empty-state">Loading posts...</div>
      ) : posts.length ? (
        <section className="post-grid">
          {posts.map((post) => (
            <PostCard post={post} key={post.id} />
          ))}
        </section>
      ) : (
        <div className="empty-state">No posts found.</div>
      )}
    </div>
  );
}
