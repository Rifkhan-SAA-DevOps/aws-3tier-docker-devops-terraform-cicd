#!/bin/bash
set -e

AWS_REGION="${aws_region}"
AWS_ACCOUNT_ID="${aws_account_id}"

BACKEND_IMAGE="${backend_image}"

DB_HOST="${db_host}"
DB_PORT="${db_port}"
DB_NAME="${db_name}"
DB_USER="${db_user}"
DB_PASSWORD="${db_password}"

JWT_SECRET="${jwt_secret}"

APP_DIR="/opt/backend"

dnf update -y
dnf install -y docker git

systemctl start docker
systemctl enable docker

usermod -aG docker ec2-user

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

mkdir -p $APP_DIR
cd $APP_DIR

cat > .env <<EOF
NODE_ENV=production

PORT=5000

DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD

JWT_SECRET=$JWT_SECRET
JWT_EXPIRES_IN=7d
EOF

cat > docker-compose.yml <<EOF
services:
  backend:
    image: $BACKEND_IMAGE
    container_name: backend
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
EOF

aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

docker compose pull
docker compose up -d