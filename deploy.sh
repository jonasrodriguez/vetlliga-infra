#!/bin/bash
set -e  # Exit immediately if a command fails

# --- Paths to your services ---
FRONT_DIR="../vetlliga-front"
BACK_DIR="../vetlliga-back"
INFRA_DIR="$(dirname "$0")"

# --- Pull latest code ---
echo "Updating frontend..."
cd "$FRONT_DIR"
git pull

echo "Updating backend..."
cd "$BACK_DIR"
git pull

# --- Return to infra directory ---
cd "$INFRA_DIR"

# --- Pull remaining dependencies (databases, Nginx, etc.) ---
docker-compose pull

# --- Build and deploy containers ---
echo "Building and starting services with docker-compose..."
docker-compose up -d --build --remove-orphans

# --- Clean up old dangling images ---
echo "Pruning unused Docker images and build cache..."
docker image prune -f
docker builder prune -af

echo "Deployment complete!"
