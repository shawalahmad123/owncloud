# ownCloud (Docker)

🔧 **Purpose**

This folder contains a Docker Compose setup to run ownCloud (server 10.15) with MariaDB and Redis for local development or small deployments.

---

## Quick Start ✅

Prerequisites:
- Docker (Engine) and Docker Compose CLI
- macOS or Linux host

From the `owncloud` project root:

```bash
# start the stack
docker compose up -d

# follow ownCloud logs
docker compose logs -f owncloud

# view composed config (validate)
docker compose config
```

---

## What this Compose does 🔎

- Runs three services: `mariadb`, `redis`, and `owncloud`.
- Uses a named Docker volume `owncloud_apps` for ownCloud custom apps storage.
- Mounts host `./data` into `/mnt/data` inside the container (ownCloud uses this for config, files and apps by default).

Key files:
- `docker-compose.yml` — Compose configuration.
- `scripts/migrate_apps_to_volume.sh` — helper to copy `./apps` into `owncloud_apps` volume.
- `MIGRATE_APPS.md` — migration instructions.

---

## Configuration & Environment ⚙️

Important environment variables you can set in `docker-compose.yml` under `environment` for the `owncloud` service:

- `OWNCLOUD_DOMAIN` — hostname used by ownCloud (default in this repo: `127.0.0.1:8959`)
- `OWNCLOUD_ADMIN_USERNAME` / `OWNCLOUD_ADMIN_PASSWORD` — bootstrap admin account
- `OWNCLOUD_DB_*` — DB connection configuration
- `OWNCLOUD_REDIS_*` — Redis connection configuration
- `OWNCLOUD_TRUSTED_DOMAINS` — comma-separated list of allowed hostnames

Change these values before first start if you require custom settings.

---

## Volumes & Data layout 📂

- Host `./data` → container `/mnt/data`
  - ownCloud expects `apps` and `config` under `/mnt/data` and creates symlinks to `/var/www/owncloud/custom` and `/var/www/owncloud/config` during initialization.
- `owncloud_apps` (named volume) → `/mnt/data/apps` inside container

Why we use a named volume for apps:
- The image removes `/var/www/owncloud/custom` and re-links it to `${OWNCLOUD_VOLUME_APPS}` (default `/mnt/data/apps`). Mounting the host directory directly at `/var/www/owncloud/custom` caused "Device or resource busy" errors when the image tried to remove that directory. The named volume avoids this problem and lets the container manage the app symlink cleanly.

---

## Migrating your `./apps` directory ⬆️

If you previously used a bind mount (`./apps`) or you have app code you want to move into the new named volume, use the included helper:

```bash
# make executable (first time)
chmod +x ./scripts/migrate_apps_to_volume.sh

# run migration (stops and restarts the stack)
./scripts/migrate_apps_to_volume.sh
```

Inspect the volume contents (optional):

```bash
docker run --rm -it -v owncloud_apps:/data alpine sh -c "ls -la /data"
```

---

## Troubleshooting 🛠️

Common issue and resolution:

- Symptom: "rm: cannot remove '/var/www/owncloud/custom': Device or resource busy"
  - Cause: A mount was placed directly at `/var/www/owncloud/custom` (or `/var/www/owncloud/config`), preventing the container from removing it to create a symlink.
  - Fix: Mount volumes at `/mnt/data/apps` and `/mnt/data/config` (the location ownCloud entrypoint expects), or use a named volume for apps (recommended). This repo already uses `owncloud_apps` mounted at `/mnt/data/apps`.

Useful commands:

```bash
# Validate compose file
docker compose config

# Show containers
docker compose ps

# Check logs
docker compose logs -f owncloud

# Inspect volumes
docker volume ls
docker volume inspect owncloud_apps
```

---

## Backups & Data Safety 💾

- Back up `./data` (host) or named Docker volumes regularly.
- You can export a named volume by copying its contents through a temporary container.

---

## Development & Contributing ✍️

If you'd like helper targets (Makefile) or CI integration, open an issue or submit a PR. I can add `make up`, `make down`, `make migrate` targets if you want.

---

## License

This folder contains configuration and helper scripts; apply your project license as appropriate.

---

If you want, I can also add a `Makefile` with `up`, `down`, and `migrate` targets — let me know and I will add it. ✅