#!/bin/bash

set -e

# Log all output
exec > >(tee /var/log/backstage-setup.log)
exec 2>&1

echo "Starting Backstage setup..."

# Update system
yum update -y
yum install -y docker git curl

# Start Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create Backstage directory
mkdir -p /opt/backstage
cd /opt/backstage

# Create .env file with database and GitHub credentials
cat > /opt/backstage/.env << 'ENVFILE'
# Database configuration
DB_HOST=${db_host}
DB_PORT=${db_port}
DB_USER=${db_user}
DB_PASSWORD=${db_password}
DB_NAME=${db_name}

# GitHub OAuth2
GITHUB_CLIENT_ID=${github_client_id}
GITHUB_CLIENT_SECRET=${github_client_secret}
GITHUB_TOKEN=${github_token}

# Backstage configuration
NODE_ENV=production
LOG_LEVEL=debug
ENVFILE

# Create docker-compose.yml
cat > /opt/backstage/docker-compose.yml << 'DOCKER'
version: '3.8'

services:
  backstage:
    image: ghcr.io/backstage/backstage:${backstage_version}
    container_name: backstage
    restart: always
    ports:
      - "3000:3000"
    environment:
      DB_HOST: $${DB_HOST}
      DB_PORT: $${DB_PORT}
      DB_USER: $${DB_USER}
      DB_PASSWORD: $${DB_PASSWORD}
      DB_NAME: $${DB_NAME}
      GITHUB_CLIENT_ID: $${GITHUB_CLIENT_ID}
      GITHUB_CLIENT_SECRET: $${GITHUB_CLIENT_SECRET}
      GITHUB_TOKEN: $${GITHUB_TOKEN}
      NODE_ENV: production
      LOG_LEVEL: debug
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 60s
    logging:
      driver: "awslogs"
      options:
        awslogs-group: "/aws/ec2/backstage"
        awslogs-region: "us-east-1"
        awslogs-stream-prefix: "ecs"

  nginx:
    image: nginx:latest
    container_name: nginx-backstage
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./certs:/etc/nginx/certs:ro
    depends_on:
      - backstage
    logging:
      driver: "awslogs"
      options:
        awslogs-group: "/aws/ec2/backstage"
        awslogs-region: "us-east-1"
        awslogs-stream-prefix: "nginx"
DOCKER

# Create basic nginx config
cat > /opt/backstage/nginx.conf << 'NGINX'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tc p_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    upstream backstage {
        server backstage:3000;
    }

    server {
        listen 80;
        server_name _;

        location / {
            proxy_pass http://backstage;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
        }

        location /health {
            access_log off;
            proxy_pass http://backstage;
        }
    }
}
NGINX

# Create CloudWatch Logs group
aws logs create-log-group --log-group-name /aws/ec2/backstage || true
aws logs put-retention-policy --log-group-name /aws/ec2/backstage --retention-in-days 30

# Start Backstage with Docker Compose
cd /opt/backstage
docker-compose up -d

# Wait for Backstage to be healthy
echo "Waiting for Backstage to start..."
for i in {1..30}; do
  if docker ps | grep backstage | grep -q "healthy"; then
    echo "Backstage is running!"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 10
done

# Display access information
echo "========================================"
echo "Backstage Installation Complete!"
echo "========================================"
echo "Access Backstage at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):3000"
echo "Logs available at: /var/log/backstage-setup.log"
echo "========================================"
