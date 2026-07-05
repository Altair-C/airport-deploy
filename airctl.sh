#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/airctl"

if [ "$(id -u)" -ne 0 ]; then
  echo "AirCtl 需要 root 权限运行，请使用：sudo airctl"
  exit 1
fi

source "${BASE_DIR}/lib/ui.sh"
source "${BASE_DIR}/lib/common.sh"

pause() {
  echo
  read -rp "按 Enter 返回菜单..."
}

show_dashboard() {
  local version
  local ip
  local status
  local status_icon
  local users
  local hy_version

  version="$(get_version)"
  ip="$(get_public_ip)"
  status="$(get_service_status_text)"
  status_icon="$(get_service_status_icon)"
  users="$(get_user_count)"
  hy_version="$(get_hysteria_version)"

  logo
  title "$version"

  printf " ${BRIGHT_BLUE}Server ${RESET}: ${BRIGHT_WHITE}%s${RESET}\n" "$ip"
  printf " ${BRIGHT_BLUE}Service${RESET}: %s ${BRIGHT_WHITE}%s${RESET}\n" "$status_icon" "$status"
  printf " ${BRIGHT_BLUE}Port   ${RESET}: ${BRIGHT_WHITE}8443/udp${RESET}\n"
  printf " ${BRIGHT_BLUE}Users  ${RESET}: ${BRIGHT_WHITE}%s${RESET}\n" "$users"
  printf " ${BRIGHT_BLUE}Core   ${RESET}: ${DIM}%s${RESET}\n" "${hy_version:-unknown}"
}

menu_item() {
  local key="$1"
  local text="$2"
  echo -e " ${BRIGHT_GREEN}${key} :${RESET} ${BRIGHT_WHITE}${text}${RESET}"
}

while true; do
  clear
  show_dashboard

  section "🟢" "服务管理" "$BRIGHT_GREEN"
  menu_item 1 "查看服务状态"
  menu_item 2 "启动服务"
  menu_item 3 "停止服务"
  menu_item 4 "重启服务"
  menu_item 5 "查看实时日志"

  section "👤" "用户管理" "$BRIGHT_BLUE"
  menu_item 10 "新增用户"
  menu_item 11 "删除用户"
  menu_item 12 "修改用户密码"
  menu_item 13 "查看用户"
  menu_item 14 "导出用户链接"
  menu_item 15 "显示二维码"

  section "⚙️" "配置管理" "$BRIGHT_CYAN"
  menu_item 20 "修改端口"
  menu_item 21 "修改 SNI"
  menu_item 22 "查看配置"
  menu_item 23 "重载配置"

  section "🛠" "维护" "$BRIGHT_YELLOW"
  menu_item 30 "系统检测"
  menu_item 31 "备份"
  menu_item 32 "恢复"
  menu_item 33 "更新 Hysteria2"

  echo
  line
  menu_item 0 "返回 / 退出"
  echo -e " ${DIM}q : 退出 AirCtl${RESET}"
  echo

  read -rp "AirCtl > " choice

  case "$choice" in
    1) bash "${BASE_DIR}/scripts/service-status.sh"; pause ;;
    2) bash "${BASE_DIR}/scripts/service-start.sh"; pause ;;
    3) bash "${BASE_DIR}/scripts/service-stop.sh"; pause ;;
    4) bash "${BASE_DIR}/scripts/service-restart.sh"; pause ;;
    5) bash "${BASE_DIR}/scripts/service-logs.sh" ;;

    10) bash "${BASE_DIR}/scripts/user-add.sh"; pause ;;
    11) bash "${BASE_DIR}/scripts/user-del.sh"; pause ;;
    12) bash "${BASE_DIR}/scripts/user-passwd.sh"; pause ;;
    13) bash "${BASE_DIR}/scripts/user-show.sh" ;;
    14) bash "${BASE_DIR}/scripts/user-link.sh"; pause ;;
    15) bash "${BASE_DIR}/scripts/user-qr.sh"; pause ;;

    20) bash "${BASE_DIR}/scripts/config-port.sh"; pause ;;
    21) bash "${BASE_DIR}/scripts/config-sni.sh"; pause ;;
    22) bash "${BASE_DIR}/scripts/config-show.sh"; pause ;;
    23) bash "${BASE_DIR}/scripts/config-reload.sh"; pause ;;

    30) bash "${BASE_DIR}/scripts/diagnose.sh"; pause ;;
    31) bash "${BASE_DIR}/scripts/backup.sh"; pause ;;
    32) bash "${BASE_DIR}/scripts/restore.sh"; pause ;;
    33) bash "${BASE_DIR}/scripts/update-hysteria.sh"; pause ;;

    0|q|Q) exit 0 ;;
    *) error "无效选择"; pause ;;
  esac
done
