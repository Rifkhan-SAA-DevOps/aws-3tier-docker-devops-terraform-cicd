import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import api from "../api/axios.js";
import { useAuth } from "../context/AuthContext.jsx";

export default function PostDetails() {
  const { id } = useParams();
  const { user } = useAuth();
  const [post, setPost] = useState(null);
  const [comments, setComments] = useState([]);
  const [content, setContent] = useState("");

  async function loadPost() {
    const { data } = await api.get(`/posts/${id}`);
    setPost(data.data);
    const commentsRes = await api.get(`/posts/${data.data.id}/comments`);
    setComments(commentsRes.data.data);
  }

  async function submitComment(event) {
    event.preventDefault();
    if (!content.trim()) return;
    await api.post(`/posts/${post.id}/comments`, { content });
    setContent("");
    loadPost();
  }

  useEffect(() => {
    loadPost();
  }, [id]);

  if (!post) return <div className="empty-state">Loading article...</div>;

  return (
    <article className="article-layout">
      <div
        className="article-cover"
        style={{
          backgroundImage: `url(${post.cover_image || "https://images.unsplash.com/photo-1499750310107-5fef28a66643"})`,
        }}
      />

      <span className="category-pill">{post.category_name}</span>
      <h1>{post.title}</h1>
      <p className="article-excerpt">{post.excerpt}</p>
      <div className="article-meta">
        By {post.author_name} • {new Date(post.created_at).toLocaleDateString()}
      </div>

      <div className="article-content">
        {post.content.split("\n").map((para, index) => (
          <p key={index}>{para}</p>
        ))}
      </div>

      <section className="comments-box">
        <h2>Comments</h2>

        {user ? (
          <form onSubmit={submitComment} className="comment-form">
            <textarea
              placeholder="Write your comment..."
              value={content}
              onChange={(e) => setContent(e.target.value)}
            />
            <button className="primary-btn">Add comment</button>
          </form>
        ) : (
          <p className="muted">Login to comment.</p>
        )}

        <div className="comment-list">
          {comments.map((comment) => (
            <div className="comment" key={comment.id}>
              <strong>{comment.user_name}</strong>
              <p>{comment.content}</p>
            </div>
          ))}
        </div>
      </section>
    </article>
  );
}
