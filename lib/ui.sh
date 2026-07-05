#!/usr/bin/env bash

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

BRIGHT_RED="\033[91m"
BRIGHT_GREEN="\033[92m"
BRIGHT_YELLOW="\033[93m"
BRIGHT_BLUE="\033[94m"
BRIGHT_MAGENTA="\033[95m"
BRIGHT_CYAN="\033[96m"
BRIGHT_WHITE="\033[97m"

line() {
  echo -e "${DIM}────────────────────────────────────────────────────────────${RESET}"
}

header() {
  local version="$1"

  echo -e "${BRIGHT_CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${BRIGHT_CYAN}║${RESET}                 ${BOLD}${BRIGHT_WHITE}Airport Deploy${RESET}                  ${BRIGHT_CYAN}║${RESET}"
  echo -e "${BRIGHT_CYAN}║${RESET}                    ${DIM}Version ${version}${RESET}                    ${BRIGHT_CYAN}║${RESET}"
  echo -e "${BRIGHT_CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
}

section() {
  local icon="$1"
  local title="$2"
  local color="$3"

  echo
  echo -e "${color}${icon} ${title}${RESET}"
  line
}

item() {
  local num="$1"
  local text="$2"

  printf " ${BRIGHT_GREEN}%3s${RESET}. ${BRIGHT_WHITE}%s${RESET}\n" "$num" "$text"
}

success() {
  echo -e "${BRIGHT_GREEN}✓ $*${RESET}"
}

warning() {
  echo -e "${BRIGHT_YELLOW}⚠ $*${RESET}"
}

error() {
  echo -e "${BRIGHT_RED}✗ $*${RESET}"
}

info() {
  echo -e "${BRIGHT_CYAN}ℹ $*${RESET}"
}
