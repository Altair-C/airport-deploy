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

copy_if_exists() {
  local src="$1"
  local dst="$2"

  if [ -e "$src" ]; then
    cp -r "$src" "$dst"
  else
    log "Skip missing path: $src"
  fi
}

prepare_files() {
  log "Preparing install directory..."

  mkdir -p "${INSTALL_DIR}"
  mkdir -p "${INSTALL_DIR}/compose"
  mkdir -p "${INSTALL_DIR}/env"
  mkdir -p "${INSTALL_DIR}/config"
  mkdir -p "${INSTALL_DIR}/scripts"
  mkdir -p /var/lib/marzban

  copy_if_exists compose/* "${INSTALL_DIR}/compose/"
  copy_if_exists env/* "${INSTALL_DIR}/env/"
  copy_if_exists config/* "${INSTALL_DIR}/config/"
  copy_if_exists scripts/* "${INSTALL_DIR}/scripts/"
  copy_if_exists README.md "${INSTALL_DIR}/"
  copy_if_exists LICENSE "${INSTALL_DIR}/"

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
