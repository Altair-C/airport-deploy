#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="/opt/airport"

pause() {
  echo
  read -rp "按 Enter 返回菜单..."
}

while true; do
  clear
  echo "=========================================="
  echo " Airport Deploy v1.0"
  echo "=========================================="
  echo
  echo "【服务管理】"
  echo
  echo "1. 查看服务状态"
  echo "2. 启动服务"
  echo "3. 停止服务"
  echo "4. 重启服务"
  echo "5. 查看实时日志"
  echo
  echo "【用户管理】"
  echo
  echo "10. 新增用户"
  echo "11. 删除用户"
  echo "12. 修改用户密码"
  echo "13. 查看用户"
  echo "14. 导出用户链接"
  echo "15. 显示二维码"
  echo
  echo "【配置管理】"
  echo
  echo "20. 修改端口"
  echo "21. 修改SNI"
  echo "22. 查看配置"
  echo "23. 重载配置"
  echo
  echo "【维护】"
  echo
  echo "30. 系统检测"
  echo "31. 备份"
  echo "32. 恢复"
  echo "33. 更新Hysteria2"
  echo
  echo "0. Exit"
  echo "=========================================="
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
    *) echo "无效选择"; pause ;;
  esac
done
