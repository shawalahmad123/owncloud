# Migrate host ./apps to Docker named volume (owncloud_apps)

This repository now uses a named volume `owncloud_apps` for `/var/www/owncloud/custom`.
If you previously used a bind mount (`./apps:/var/www/owncloud/custom`), run the included script to copy your local apps into the new volume.

## Usage

From the `owncloud` project root:

```sh
# make script executable (first time only)
chmod +x ./scripts/migrate_apps_to_volume.sh

# run migration (stops and starts the stack)
./scripts/migrate_apps_to_volume.sh
```

## Notes

- The script stops the docker-compose stack before copying and restarts it afterward.
- The copy uses an ephemeral `alpine` container, so Docker must be running and the CLI must be available.
- The script attempts to chown files to uid:33 gid:33 (common www-data uid). If your image uses a different uid/gid, adjust the script or fix ownership inside the container after start.
- If you want to inspect the volume contents, use a helper container:

```sh
docker run --rm -it -v owncloud_apps:/data alpine sh -c "ls -la /data"
```
