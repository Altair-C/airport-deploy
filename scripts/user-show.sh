#!/usr/bin/env bash
set -euo pipefail

source /opt/airctl/lib/users.sh
source /opt/airctl/lib/config.sh
source /opt/airctl/lib/ui.sh

ensure_users_db
migrate_users_db
ensure_airctl_config

server_ip="$(curl -fsS https://api.ipify.org || hostname -I | awk '{print $1}')"
port="$(config_get_port)"
sni="$(config_get_sni)"

kv() {
  local k="$1"
  local v="$2"
  printf " ${BRIGHT_BLUE}%-10s${RESET}: ${BRIGHT_WHITE}%s${RESET}\n" "$k" "$v"
}

page_title() {
  local title="$1"

  echo
  echo -e "${BRIGHT_CYAN}────────────────────────────────────────────${RESET}"
  echo -e "${BOLD}${BRIGHT_WHITE} $title${RESET}"
  echo -e "${BRIGHT_CYAN}────────────────────────────────────────────${RESET}"
}

show_user_detail() {
  local username="$1"
  local password remark enabled created_at status_icon status_text link

  password="$(user_password "$username")"
  remark="$(user_remark "$username")"
  enabled="$(user_enabled "$username")"
  created_at="$(user_created_at "$username")"

  if [ "$enabled" = "true" ]; then
    status_icon="🟢"
    status_text="Enabled"
  else
    status_icon="🔴"
    status_text="Disabled"
  fi

  link="hy2://${username}:${password}@${server_ip}:${port}/?sni=${sni}&insecure=1#${username}"

  while true; do
    clear
    page_title "👤 用户详情"

    section "👤" "用户信息" "$BRIGHT_BLUE"
    kv "用户名" "$username"
    kv "备注" "${remark:-无}"
    kv "状态" "$status_icon $status_text"
    kv "创建时间" "${created_at:-unknown}"

    section "🌐" "连接信息" "$BRIGHT_CYAN"
    kv "服务器" "$server_ip"
    kv "端口" "${port}/udp"
    kv "SNI" "$sni"
    kv "协议" "Hysteria2"

    section "🔐" "认证信息" "$BRIGHT_YELLOW"
    kv "密码" "$password"

    section "🔗" "HY2 链接" "$BRIGHT_GREEN"
    echo -e "${BRIGHT_WHITE}${link}${RESET}"

    section "⚙️" "操作" "$BRIGHT_MAGENTA"
    item 1 "修改密码"
    item 2 "显示二维码"
    item 3 "导出配置"
    item 0 "返回上一层"
    echo
    echo -e "${DIM}q. 退出 AirCtl${RESET}"
    echo

    read -rp "AirCtl > " action

    case "$action" in
      1)
        bash /opt/airctl/scripts/user-passwd.sh "$username"
        read -rp "按 Enter 继续..."
        ;;
      2)
        bash /opt/airctl/scripts/user-qr.sh "$username"
        read -rp "按 Enter 继续..."
        ;;
      3)
        bash /opt/airctl/scripts/user-link.sh "$username"
        read -rp "按 Enter 继续..."
        ;;
      0)
        return
        ;;
      q|Q)
        exit 0
        ;;
      *)
        echo "无效选择"
        read -rp "按 Enter 继续..."
        ;;
    esac
  done
}

while true; do
  clear
  page_title "👤 用户列表"

  mapfile -t users < <(user_list_names)

  if [ "${#users[@]}" -eq 0 ]; then
    warning "暂无用户"
    echo
    read -rp "按 Enter 返回..."
    exit 0
  fi

  index=1
  for username in "${users[@]}"; do
    remark="$(user_remark "$username")"
    if [ -n "$remark" ]; then
      printf " ${BRIGHT_GREEN}%3s${RESET}. ${BRIGHT_WHITE}%s${RESET} ${DIM}(%s)${RESET}\n\n" "$index" "$username" "$remark"
    else
      printf " ${BRIGHT_GREEN}%3s${RESET}. ${BRIGHT_WHITE}%s${RESET}\n\n" "$index" "$username"
    fi
    index=$((index + 1))
  done

  line
  item 0 "返回上一层"
  echo
  echo -e "${DIM}q. 退出 AirCtl${RESET}"
  echo

  read -rp "AirCtl > " choice

  case "$choice" in
    0)
      exit 0
      ;;
    q|Q)
      exit 0
      ;;
  esac

  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    warning "请输入数字"
    read -rp "按 Enter 继续..."
    continue
  fi

  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#users[@]}" ]; then
    warning "无效选择"
    read -rp "按 Enter 继续..."
    continue
  fi

  selected="${users[$((choice - 1))]}"
  show_user_detail "$selected"
done
