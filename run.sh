mkdir -p {db,data,apps,config};

docker compose up -d;

# ownCloud was successfully installed
# 👉 http://ip:8959
# Login with:
# user: admin
# password: ChangeThisPassword

# 🔐 Enable OpenID Connect (SSO)
# 1️⃣ Install OpenID Connect app
# docker exec -u www-data owncloud_server php occ market:install openidconnect
# docker exec -u www-data owncloud_server php occ app:enable openidconnect


# 🔑 Example OpenID configuration (Keycloak / Azure / Authentik)
# Redirect URI (VERY IMPORTANT)
# http://ip:8959/index.php/apps/openidconnect/redirect

