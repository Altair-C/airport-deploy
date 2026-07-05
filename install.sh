#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="airport-deploy"
INSTALL_DIR="/opt/airport"

log() {
  echo "[${PROJECT_NAME}] $*"
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo ./install.sh"
    exit 1
  fi
}

prepare_files() {
  log "Preparing install directory..."

  mkdir -p "${INSTALL_DIR}"
  mkdir -p /var/lib/marzban

  cp -r compose "${INSTALL_DIR}/"
  cp -r env "${INSTALL_DIR}/"
  cp -r config "${INSTALL_DIR}/"
  cp -r scripts "${INSTALL_DIR}/"
  cp README.md LICENSE "${INSTALL_DIR}/" 2>/dev/null || true

  if [ ! -f "${INSTALL_DIR}/env/.env" ]; then
    cp "${INSTALL_DIR}/env/.env.example" "${INSTALL_DIR}/env/.env"

    SERVER_IP="$(curl -fsS https://api.ipify.org || hostname -I | awk '{print $1}')"
    sed -i "s/YOUR_SERVER_IP/${SERVER_IP}/g" "${INSTALL_DIR}/env/.env"
  fi
}

start_services() {
  log "Starting Marzban..."

  cd "${INSTALL_DIR}/compose"
  docker compose up -d
}

show_result() {
  SERVER_IP="$(curl -fsS https://api.ipify.org || hostname -I | awk '{print $1}')"

  log "Install completed."
  echo
  echo "Marzban Dashboard:"
  echo "http://${SERVER_IP}:8000/dashboard/"
  echo
  echo "Next:"
  echo "sudo docker exec -it marzban marzban cli admin create --sudo"
}

main() {
  require_root
  prepare_files
  start_services
  show_result
}

main "$@"
