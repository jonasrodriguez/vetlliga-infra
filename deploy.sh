#!/bin/bash
set -e  # Exit immediately if a command fails

# --- Input Parameter ---
if [ -z "$1" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

VERSION="$1"

# --- Paths to your services ---
FRONT_DIR="../vetlliga-front"
BACK_DIR="../vetlliga-back"
INFRA_DIR="$(dirname "$0")"

# --- Function to build a service ---
build_service() {
  local DIR="$1"
  local NAME="$2"

  echo "Updating $NAME..."
  cd "$DIR"

  # Fetch latest changes
  git fetch
  LOCAL_HASH=$(git rev-parse HEAD)
  REMOTE_HASH=$(git rev-parse @{u})

  if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "Pulling latest changes for $NAME..."
    git pull
    echo "Building $NAME..."
    docker build -t "$NAME:$VERSION" -t "$NAME:latest" .
  else
    echo "No changes for $NAME, skipping build."
  fi
}

# --- Build Frontend and Backend ---
build_service "$FRONT_DIR" "vetlliga-frontend"
build_service "$BACK_DIR" "vetlliga-backend"

# --- Return to infra directory ---
cd "$INFRA_DIR"

# --- Pull remaining dependencies (databases, Nginx, etc.) ---
docker-compose pull

# --- Deploy all containers ---
echo "Starting services with docker-compose..."
docker-compose up -d --remove-orphans

# --- Clean up old dangling images ---
echo "Pruning unused Docker images..."
docker image prune -f
docker builder prune -af

echo "Deployment complete!"
