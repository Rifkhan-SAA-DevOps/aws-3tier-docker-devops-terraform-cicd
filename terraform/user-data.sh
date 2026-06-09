#!/bin/bash
set -e

# -----------------------------
# Variables from Terraform template
# -----------------------------
AWS_REGION="${aws_region}"
AWS_ACCOUNT_ID="${aws_account_id}"

FRONTEND_IMAGE="${frontend_image}"
BACKEND_IMAGE="${backend_image}"

DB_HOST="${db_host}"
DB_PORT="${db_port}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"

JWT_SECRET="${jwt_secret}"

APP_DIR="/opt/blog-app"

# -----------------------------
# Update system
# -----------------------------
dnf update -y

# -----------------------------
# Install Docker, Git, AWS CLI
# -----------------------------
dnf install -y docker git awscli

# -----------------------------
# Start and enable Docker
# -----------------------------
systemctl start docker
systemctl enable docker

# -----------------------------
# Add ec2-user to docker group
# -----------------------------
usermod -aG docker ec2-user

# -----------------------------
# Install Docker Compose plugin
# -----------------------------
mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# -----------------------------
# Create app directory
# -----------------------------
mkdir -p $APP_DIR
cd $APP_DIR

# -----------------------------
# Create .env file
# -----------------------------
cat > .env <<EOF
NODE_ENV=production

DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d

VITE_API_URL=/api
EOF

# -----------------------------
# Create docker-compose.ecr.yml
# -----------------------------
cat > docker-compose.ecr.yml <<EOF
services:
  backend:
    image: $BACKEND_IMAGE
    container_name: blog-backend
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - "5000:5000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:5000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  frontend:
    image: $FRONTEND_IMAGE
    container_name: blog-frontend
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "80:80"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF

# -----------------------------
# Login to ECR
# -----------------------------
aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# -----------------------------
# Pull and run containers
# -----------------------------
docker compose -f docker-compose.ecr.yml pull
docker compose -f docker-compose.ecr.yml up -d