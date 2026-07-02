#!/bin/bash

# Blipyy Native Deployment Script
# Usage: ./deploy-native.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "[DEPLOY] Starting native deployment..."

# Pull latest changes
echo "[DEPLOY] Pulling latest changes from git..."
git pull origin main

# Install backend dependencies if package.json changed
echo "[DEPLOY] Checking backend dependencies..."
pnpm install --filter blipyy-backend --prod --frozen-lockfile

# Build frontend
echo "[DEPLOY] Building frontend..."
pnpm install --filter blipyy-frontend --frozen-lockfile
pnpm --dir frontend run build

# Run database migrations
echo "[DEPLOY] Running database migrations..."
pnpm --dir backend run migrate

# Restart backend
echo "[DEPLOY] Restarting backend..."
pm2 restart all

# Install repo-managed nginx snippets, then reload nginx
echo "[DEPLOY] Installing nginx snippets..."
if [ -f scripts/nginx/blipyy-og.conf ]; then
  sudo mkdir -p /etc/nginx/snippets
  sudo cp scripts/nginx/blipyy-og.conf /etc/nginx/snippets/blipyy-og.conf
  if ! sudo grep -Rqs "blipyy-og.conf" /etc/nginx/sites-enabled /etc/nginx/conf.d 2>/dev/null; then
    echo "[DEPLOY] NOTICE: add 'include /etc/nginx/snippets/blipyy-og.conf;' inside the blipyy server { } block (one-time step)"
  fi
fi

echo "[DEPLOY] Reloading nginx..."
sudo nginx -t && sudo nginx -s reload

echo "[DEPLOY] Deployment complete!"
