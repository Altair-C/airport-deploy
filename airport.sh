#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/airport"

source "${BASE_DIR}/lib/ui.sh"
source "${BASE_DIR}/lib/common.sh"

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

  header "$version"
  echo
  printf " ${BRIGHT_BLUE}Server ${RESET}: ${BRIGHT_WHITE}%s${RESET}\n" "$ip"
  printf " ${BRIGHT_BLUE}Service${RESET}: %s ${BRIGHT_WHITE}%s${RESET}\n" "$status_icon" "$status"
  printf " ${BRIGHT_BLUE}Port   ${RESET}: ${BRIGHT_WHITE}8443/udp${RESET}\n"
  printf " ${BRIGHT_BLUE}Users  ${RESET}: ${BRIGHT_WHITE}%s${RESET}\n" "$users"
  printf " ${BRIGHT_BLUE}Core   ${RESET}: ${DIM}%s${RESET}\n" "$hy_version"
}

while true; do
  clear
  show_dashboard

  section "🟢" "服务管理" "$BRIGHT_GREEN"
  item 1 "查看服务状态"
  item 2 "启动服务"
  item 3 "停止服务"
  item 4 "重启服务"
  item 5 "查看实时日志"

  section "👤" "用户管理" "$BRIGHT_BLUE"
  item 10 "新增用户"
  item 11 "删除用户"
  item 12 "修改用户密码"
  item 13 "查看用户"
  item 14 "导出用户链接"
  item 15 "显示二维码"

  section "⚙️" "配置管理" "$BRIGHT_CYAN"
  item 20 "修改端口"
  item 21 "修改 SNI"
  item 22 "查看配置"
  item 23 "重载配置"

  section "🛠" "维护" "$BRIGHT_YELLOW"
  item 30 "系统检测"
  item 31 "备份"
  item 32 "恢复"
  item 33 "更新 Hysteria2"

  echo
  line
  item 0 "Exit"
  echo
  read -rp "请选择: " choice

  case "$choice" in
    1) bash "${BASE_DIR}/scripts/service-status.sh"; pause ;;
    2) bash "${BASE_DIR}/scripts/service-start.sh"; pause ;;
    3) bash "${BASE_DIR}/scripts/service-stop.sh"; pause ;;
    4) bash "${BASE_DIR}/scripts/service-restart.sh"; pause ;;
    5) bash "${BASE_DIR}/scripts/service-logs.sh" ;;

    10) bash "${BASE_DIR}/scripts/user-add.sh"; pause ;;
    11) bash "${BASE_DIR}/scripts/user-del.sh"; pause ;;
    12) bash "${BASE_DIR}/scripts/user-passwd.sh"; pause ;;
    13) bash "${BASE_DIR}/scripts/user-show.sh"; pause ;;
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

    0) exit 0 ;;
    *) error "无效选择"; pause ;;
  esac
done
