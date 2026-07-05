#!/usr/bin/env bash

ui_read_key() {
  local key
  IFS= read -rsn1 key < /dev/tty
  printf "%s" "$key"
}

ui_pause() {
  echo
  echo -ne "${DIM}按任意键继续...${RESET}"
  ui_read_key >/dev/null
  echo
}
