#!/bin/bash
set -e

AWS_REGION="${aws_region}"
AWS_ACCOUNT_ID="${aws_account_id}"

FRONTEND_IMAGE="${frontend_image}"
INTERNAL_ALB_DNS="${internal_alb_dns}"

APP_DIR="/opt/frontend"

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

cat > docker-compose.yml <<EOF
services:
  frontend:
    image: $FRONTEND_IMAGE
    container_name: frontend
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      INTERNAL_ALB_DNS: $INTERNAL_ALB_DNS
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