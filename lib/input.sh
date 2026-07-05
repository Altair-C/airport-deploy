#!/usr/bin/env bash

ui_read_key() {
  local key
  local old_tty

  old_tty="$(stty -g < /dev/tty)"

  stty raw -echo < /dev/tty
  key="$(dd bs=1 count=1 2>/dev/null < /dev/tty || true)"
  stty "$old_tty" < /dev/tty

  printf "%s" "$key"
}

ui_read_choice() {
  local first
  local rest

  first="$(ui_read_key)"

  case "$first" in
    q|Q)
      echo
      printf "q"
      return
      ;;
    "")
      echo
      printf ""
      return
      ;;
  esac

  printf "%s" "$first" > /dev/tty
  IFS= read -r rest < /dev/tty
  printf "%s%s" "$first" "$rest"
}

ui_pause() {
  echo
  echo -ne "${DIM}按任意键继续...${RESET}"
  ui_read_key >/dev/null
  echo
}
