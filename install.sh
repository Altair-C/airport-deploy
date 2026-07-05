#!/usr/bin/env bash
set -euo pipefail

APP="airport"
INSTALL_DIR="/opt/airport"
CONFIG_DIR="/etc/airport"
HYSTERIA_CONFIG="/etc/hysteria/config.yaml"
PORT="8443"

log() {
  echo "[${APP}] $*"
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo ./install.sh"
    exit 1
  fi
}

install_packages() {
  apt-get update -y
  apt-get install -y curl jq openssl qrencode ufw
}

install_hysteria() {
  log "Installing Hysteria2..."
  bash <(curl -fsSL https://get.hy2.sh/)
}

prepare_dirs() {
  mkdir -p "${INSTALL_DIR}" "${CONFIG_DIR}" /etc/hysteria /var/log/airport
  cp -r . "${INSTALL_DIR}/"
}

init_users_db() {
  if [ ! -f "${CONFIG_DIR}/users.json" ]; then
    echo '{}' > "${CONFIG_DIR}/users.json"
    chmod 600 "${CONFIG_DIR}/users.json"
  fi
}

write_hysteria_config() {
  SERVER_PASSWORD="$(openssl rand -base64 24 | tr -d '=+/')"

  cat > "${HYSTERIA_CONFIG}" <<EOF_CONFIG
listen: :${PORT}

tls:
  type: self-signed
  sni: bing.com

auth:
  type: userpass
  userpass:
    bootstrap: ${SERVER_PASSWORD}

masquerade:
  type: proxy
  proxy:
    url: https://www.bing.com/
    rewriteHost: true
EOF_CONFIG

  chown root:hysteria "${HYSTERIA_CONFIG}" 2>/dev/null || true
chmod 640 "${HYSTERIA_CONFIG}"
}

install_airport_command() {
  ln -sf "${INSTALL_DIR}/airport.sh" /usr/local/bin/airport
  chmod +x "${INSTALL_DIR}/airport.sh"
  chmod +x "${INSTALL_DIR}"/scripts/*.sh
}

configure_firewall() {
  ufw allow 22/tcp
  ufw allow ${PORT}/udp
  ufw --force enable
}

restart_service() {
  systemctl enable hysteria-server
  systemctl restart hysteria-server
}

main() {
  require_root
  install_packages
  install_hysteria
  prepare_dirs
  init_users_db
  write_hysteria_config
  install_airport_command
  configure_firewall
  restart_service

  log "Install completed."
  echo
  echo "Run management menu:"
  echo "  sudo airport"
}

main "$@"
