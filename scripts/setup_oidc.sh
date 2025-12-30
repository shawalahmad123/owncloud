#!/usr/bin/env bash
set -euo pipefail

OWNCLOUD_CONTAINER="${OWNCLOUD_CONTAINER:-owncloud_server}"

OIDC_PROVIDER_URL="${OIDC_PROVIDER_URL:-http://host.docker.internal:8960/realms/owncloud}"
OIDC_CLIENT_ID="${OIDC_CLIENT_ID:-owncloud}"
OIDC_CLIENT_SECRET="${OIDC_CLIENT_SECRET:-owncloud-secret}"

docker exec -u www-data "${OWNCLOUD_CONTAINER}" php occ status >/dev/null

docker exec -u www-data "${OWNCLOUD_CONTAINER}" php occ market:install openidconnect >/dev/null || true
docker exec -u www-data "${OWNCLOUD_CONTAINER}" php occ app:enable openidconnect >/dev/null || true

docker exec -u www-data "${OWNCLOUD_CONTAINER}" php occ config:app:set openidconnect openid-connect --value="$(
  printf '%s' \
    "{\"provider-url\":\"${OIDC_PROVIDER_URL}\","\
"\"client-id\":\"${OIDC_CLIENT_ID}\","\
"\"client-secret\":\"${OIDC_CLIENT_SECRET}\","\
"\"loginButtonName\":\"Keycloak SSO\","\
"\"autoRedirectOnLoginPage\":false,"\
"\"mode\":\"userid\","\
"\"search-attribute\":\"preferred_username\","\
"\"scopes\":[\"openid\",\"profile\",\"email\"],"\
"\"auto-provision\":{\"enabled\":true,\"email-claim\":\"email\",\"display-name-claim\":\"name\"}}"
)" >/dev/null

echo "OK: ownCloud OpenID Connect configured."
