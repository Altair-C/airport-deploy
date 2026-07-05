#!/usr/bin/env bash

RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

BRIGHT_RED="\033[91m"
BRIGHT_GREEN="\033[92m"
BRIGHT_YELLOW="\033[93m"
BRIGHT_BLUE="\033[94m"
BRIGHT_MAGENTA="\033[95m"
BRIGHT_CYAN="\033[96m"
BRIGHT_WHITE="\033[97m"

UI_LINE="────────────────────────────────────────────"
UI_FIELD_WIDTH=12

ui_text_width() {
  python3 - "$1" <<'PY'
import sys
import unicodedata

s = sys.argv[1]
w = 0
for ch in s:
    if unicodedata.combining(ch):
        continue
    if unicodedata.east_asian_width(ch) in ("F", "W"):
        w += 2
    else:
        w += 1
print(w)
PY
}

ui_pad_right() {
  local text="$1"
  local target="$2"
  local width
  local pad

  width="$(ui_text_width "$text")"
  pad=$((target - width))
  if [ "$pad" -lt 0 ]; then
    pad=0
  fi

  printf "%s" "$text"
  printf "%*s" "$pad" ""
}

ui_line() {
  echo -e "${DIM}${UI_LINE}${RESET}"
}

ui_long_line() {
  echo -e "${DIM}${UI_LINE}${RESET}"
}

ui_logo() {
  echo -e "${BRIGHT_CYAN}"
  cat <<'LOGO'
 █████╗ ██╗██████╗  ██████╗████████╗██╗
██╔══██╗██║██╔══██╗██╔════╝╚══██╔══╝██║
███████║██║██████╔╝██║        ██║   ██║
██╔══██║██║██╔══██╗██║        ██║   ██║
██║  ██║██║██║  ██║╚██████╗   ██║   ███████╗
╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚══════╝
LOGO
  echo -e "${RESET}"
}

ui_header() {
  local version="$1"
  local subtitle="${2:-Private Proxy Management Toolkit}"

  ui_logo
  echo -e "${BOLD}${BRIGHT_WHITE}AirCtl ${BRIGHT_GREEN}v${version}${RESET}"
  echo -e "${DIM}${subtitle}${RESET}"
  ui_line
}

ui_page_title() {
  local title="$1"

  echo
  ui_line
  echo -e " ${BOLD}${BRIGHT_WHITE}${title}${RESET}"
  ui_line
}

ui_section() {
  local title="$1"
  local color="${2:-$BRIGHT_CYAN}"

  echo
  echo -e "${color}${title}${RESET}"
  ui_line
}

ui_field() {
  local label="$1"
  local value="$2"
  local padded

  padded="$(ui_pad_right "$label" "$UI_FIELD_WIDTH")"
  echo -e " ${BRIGHT_BLUE}${padded}${RESET}: ${BRIGHT_WHITE}${value}${RESET}"
}

ui_link() {
  local link="$1"

  echo -e "${BRIGHT_WHITE}${link}${RESET}"
}

ui_menu_item() {
  local key="$1"
  local text="$2"

  echo -e " ${BRIGHT_GREEN}${key} :${RESET} ${BRIGHT_WHITE}${text}${RESET}"
}

ui_nav() {
  echo
  ui_line
  ui_menu_item "0" "返回上一层"
  echo -e " ${DIM}q : 退出 AirCtl${RESET}"
}

ui_prompt() {
  echo
  echo -ne "${BRIGHT_CYAN}AirCtl > ${RESET}"
}

ui_success() {
  echo -e "${BRIGHT_GREEN}✓ $*${RESET}"
}

ui_warning() {
  echo -e "${BRIGHT_YELLOW}⚠ $*${RESET}"
}

ui_error() {
  echo -e "${BRIGHT_RED}✗ $*${RESET}"
}

ui_info() {
  echo -e "${BRIGHT_CYAN}ℹ $*${RESET}"
}

# Backward compatibility
line() { ui_line; }
logo() { ui_logo; }
success() { ui_success "$@"; }
warning() { ui_warning "$@"; }
error() { ui_error "$@"; }
info() { ui_info "$@"; }

section() {
  local icon="$1"
  local title="$2"
  local color="$3"

  ui_section "${icon} ${title}" "$color"
}

item() {
  local num="$1"
  local text="$2"

  echo -e " ${BRIGHT_GREEN}${num}.${RESET} ${BRIGHT_WHITE}${text}${RESET}"
}

title() {
  local version="$1"

  echo -e "${BOLD}${BRIGHT_WHITE}AirCtl ${BRIGHT_GREEN}v${version}${RESET}"
  echo -e "${DIM}Private Proxy Management Toolkit${RESET}"
  ui_line
}
