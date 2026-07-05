#!/usr/bin/env bash
set -euo pipefail

AIRCTL_EXIT_CODE=88

source /opt/airctl/lib/users.sh
source /opt/airctl/lib/ui.sh
source /opt/airctl/lib/input.sh

ensure_users_db
migrate_users_db

while true; do
  clear
  ui_page_title "删除用户"

  mapfile -t users < <(user_list_names)

  if [ "${#users[@]}" -eq 0 ]; then
    ui_warning "暂无用户"
    ui_pause
    exit 0
  fi

  index=1
  for username in "${users[@]}"; do
    remark="$(user_remark "$username")"
    if [ -n "$remark" ]; then
      echo -e " ${BRIGHT_GREEN}${index} :${RESET} ${BRIGHT_WHITE}${username}${RESET} ${DIM}(${remark})${RESET}"
    else
      echo -e " ${BRIGHT_GREEN}${index} :${RESET} ${BRIGHT_WHITE}${username}${RESET}"
    fi
    index=$((index + 1))
  done

  echo
  ui_line
  echo -e " ${BRIGHT_GREEN}0 :${RESET} 返回上一层"
  echo -e " ${DIM}q : 退出 AirCtl${RESET}"
  echo

  ui_prompt
  choice="$(ui_read_choice)"
  echo

  case "$choice" in
    0) exit 0 ;;
    q|Q) exit "$AIRCTL_EXIT_CODE" ;;
  esac

  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    ui_warning "请输入数字"
    ui_pause
    continue
  fi

  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#users[@]}" ]; then
    ui_warning "无效选择"
    ui_pause
    continue
  fi

  username="${users[$((choice - 1))]}"

  echo
  ui_warning "即将删除用户: $username"
  read -rp "确认删除？输入 yes 继续: " confirm

  if [ "$confirm" != "yes" ]; then
    ui_info "已取消"
    ui_pause
    continue
  fi

  user_delete "$username"

  bash /opt/airctl/scripts/render-config.sh
  systemctl restart hysteria-server

  ui_success "用户已删除: $username"
  ui_pause
  exit 0
done
