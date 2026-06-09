INSERT INTO users (name, email, password_hash, role) VALUES
('Admin User', 'admin@example.com', '$2a$12$VwOLgrnDZDQAE.sxxhXVPuy9TR1s8zVWu3BtvNDZNMPyAegwwfSb6', 'admin'),
('Author User', 'author@example.com', '$2a$12$kecxAv5nPsTVgKDA0FNtW.iFezvAMkWXurLc1GLgo3pmBl9VTqPRC', 'author');

INSERT INTO categories (name, slug) VALUES
('Cloud Computing', 'cloud-computing'),
('DevOps', 'devops'),
('Web Development', 'web-development'),
('Career', 'career');

INSERT INTO posts (title, slug, excerpt, content, cover_image, status, category_id, author_id) VALUES
(
  'How to Deploy a Fullstack App on AWS 3 Tier Architecture',
  'how-to-deploy-fullstack-app-aws-3-tier',
  'Learn the basic idea of deploying frontend, backend, and database in a secure AWS 3-tier architecture.',
  'A real-world AWS 3-tier architecture separates the frontend, backend, and database into different layers. The frontend can run behind an Application Load Balancer or CloudFront. The backend runs in private subnets behind an internal or public ALB depending on the design. The database should run in private subnets using Amazon RDS MySQL. This design improves scalability, security, and maintainability.',
  'https://images.unsplash.com/photo-1451187580459-43490279c0fa',
  'published',
  1,
  1
),
(
  'CI CD Pipeline for Node and React Applications',
  'ci-cd-pipeline-node-react-applications',
  'A practical introduction to building CI/CD pipelines for fullstack JavaScript applications.',
  'CI/CD helps developers automatically test, build, and deploy applications whenever code changes. A good AWS pipeline can use GitHub, CodeConnections, CodePipeline, CodeBuild, CodeDeploy, and deployment targets like EC2 Auto Scaling Groups or ECS. This gives teams repeatable deployments and reduces manual mistakes.',
  'https://images.unsplash.com/photo-1515879218367-8466d910aaa4',
  'published',
  2,
  2
),
(
  'Why Every MERN Developer Should Learn Infrastructure',
  'why-every-mern-developer-should-learn-infrastructure',
  'Modern fullstack developers become stronger when they understand cloud, networking, deployment, and monitoring.',
  'Knowing React, Node.js, Express, and databases is powerful. But companies also need developers who can deploy applications, debug production issues, understand load balancers, configure environment variables, use logs, secure databases, and automate infrastructure. Learning AWS, Docker, Terraform, and CI/CD makes a fullstack developer much more valuable.',
  'https://images.unsplash.com/photo-1498050108023-c5249f4df085',
  'published',
  3,
  2
);
