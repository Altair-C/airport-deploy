#!/usr/bin/env bash
set -euo pipefail

USERS_DB="/etc/airport/users.json"
HYSTERIA_CONFIG="/etc/hysteria/config.yaml"
PORT="8443"

mkdir -p /etc/hysteria/certs

if [ ! -f /etc/hysteria/certs/server.crt ] || [ ! -f /etc/hysteria/certs/server.key ]; then
  openssl req -x509 -newkey rsa:2048 \
    -keyout /etc/hysteria/certs/server.key \
    -out /etc/hysteria/certs/server.crt \
    -days 3650 -nodes \
    -subj "/CN=bing.com"
fi

chown -R root:hysteria /etc/hysteria/certs 2>/dev/null || true
chmod 750 /etc/hysteria/certs
chmod 640 /etc/hysteria/certs/server.key /etc/hysteria/certs/server.crt

cat > "${HYSTERIA_CONFIG}" <<EOF_CONFIG
listen: :${PORT}

tls:
  cert: /etc/hysteria/certs/server.crt
  key: /etc/hysteria/certs/server.key

auth:
  type: userpass
  userpass:
EOF_CONFIG

jq -r 'to_entries[] | "    \(.key): \(.value.password)"' "${USERS_DB}" >> "${HYSTERIA_CONFIG}"

cat >> "${HYSTERIA_CONFIG}" <<EOF_CONFIG

masquerade:
  type: proxy
  proxy:
    url: https://www.bing.com/
    rewriteHost: true
EOF_CONFIG

chown root:hysteria "${HYSTERIA_CONFIG}" 2>/dev/null || true
chmod 640 "${HYSTERIA_CONFIG}"
