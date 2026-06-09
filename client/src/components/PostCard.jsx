import { Link } from "react-router-dom";
import { MessageCircle, User } from "lucide-react";

export default function PostCard({ post }) {
  return (
    <article className="post-card">
      <div
        className="post-cover"
        style={{
          backgroundImage: `linear-gradient(120deg, rgba(15,23,42,.25), rgba(37,99,235,.18)), url(${post.cover_image || "https://images.unsplash.com/photo-1499750310107-5fef28a66643"})`,
        }}
      />

      <div className="post-card-body">
        <span className="category-pill">{post.category_name}</span>
        <h2>{post.title}</h2>
        <p>{post.excerpt}</p>

        <div className="post-meta">
          <span><User size={15} /> {post.author_name}</span>
          <span><MessageCircle size={15} /> {post.comment_count || 0}</span>
        </div>

        <Link className="read-link" to={`/posts/${post.slug}`}>
          Read article →
        </Link>
      </div>
    </article>
  );
}
