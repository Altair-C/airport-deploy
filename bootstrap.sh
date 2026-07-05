#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="airport-deploy"
INSTALL_DIR="/opt/airport"

log() {
  echo "[${PROJECT_NAME}] $*"
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root: sudo ./bootstrap.sh"
    exit 1
  fi
}

install_packages() {
  log "Updating apt packages..."
  apt-get update -y

  log "Installing base packages..."
  apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw \
    jq
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker already installed."
    return
  fi

  log "Installing Docker..."
  install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    -o /etc/apt/keyrings/docker.asc

  chmod a+r /etc/apt/keyrings/docker.asc

  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
    > /etc/apt/sources.list.d/docker.list

  apt-get update -y

  apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  systemctl enable docker
  systemctl start docker
}

configure_firewall() {
  log "Configuring UFW firewall..."

  ufw allow 22/tcp
  ufw allow 8000/tcp
  ufw allow 8443/udp
  ufw allow 443/tcp

  ufw --force enable
}

prepare_dirs() {
  log "Preparing install directory: ${INSTALL_DIR}"

  mkdir -p "${INSTALL_DIR}"
  mkdir -p "${INSTALL_DIR}/data"
  mkdir -p "${INSTALL_DIR}/logs"
  mkdir -p "${INSTALL_DIR}/backup"
}

main() {
  require_root
  install_packages
  install_docker
  configure_firewall
  prepare_dirs

  log "Bootstrap completed."
  log "Docker version:"
  docker --version
  docker compose version
}

main "$@"
