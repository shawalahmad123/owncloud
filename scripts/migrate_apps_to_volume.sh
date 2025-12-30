#!/usr/bin/env sh
set -euo pipefail

# migrate_apps_to_volume.sh
# Usage: run from this repository (recommended): ./scripts/migrate_apps_to_volume.sh
# What it does:
#  - docker-compose down
#  - create the named volume "owncloud_apps" if it doesn't exist
#  - copy contents of ./apps into the named volume
#  - set ownership (uid 33, gid 33) on copied files (best-effort)
#  - docker-compose up -d

# switch to repo root (script lives in ./scripts)
cd "$(dirname "$0")/.." || exit 1
COMPOSE_DIR="$(pwd)"

echo "Working in ${COMPOSE_DIR}"

echo "Stopping docker-compose stack..."
docker-compose down

echo "Ensuring Docker volume 'owncloud_apps' exists..."
if ! docker volume inspect owncloud_apps >/dev/null 2>&1; then
  docker volume create owncloud_apps
fi

if [ ! -d "${COMPOSE_DIR}/apps" ]; then
  echo "No ./apps directory found in ${COMPOSE_DIR}; nothing to copy."
else
  echo "Copying contents of ./apps into 'owncloud_apps' volume..."
  docker run --rm -v "${COMPOSE_DIR}/apps":/from -v owncloud_apps:/to alpine sh -c "cp -a /from/. /to/ && chown -R 33:33 /to || true"
  echo "Copy complete. Note: ownership set to uid:33 gid:33 (www-data) if possible."
fi

echo "Starting docker-compose stack..."
docker-compose up -d

echo "Migration completed. Check owncloud logs: docker-compose logs -f owncloud"
