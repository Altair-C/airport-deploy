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
    echo "=========================================================="
    echo "                      用户详情"
    echo "=========================================================="
    echo
    echo "用户名"
    echo "$username"
    echo
    echo "备注"
    echo "${remark:-无}"
    echo
    echo "状态"
    echo "$status_icon $status_text"
    echo
    echo "创建时间"
    echo "${created_at:-unknown}"
    echo
    echo "=========================================================="
    echo
    echo "服务器"
    echo "$server_ip"
    echo
    echo "端口"
    echo "$port"
    echo
    echo "SNI"
    echo "$sni"
    echo
    echo "协议"
    echo "Hysteria2"
    echo
    echo "=========================================================="
    echo
    echo "密码"
    echo "$password"
    echo
    echo "=========================================================="
    echo
    echo "HY2"
    echo "$link"
    echo
    echo "=========================================================="
    echo
    echo "1. 修改密码"
    echo "2. 显示二维码"
    echo "3. 导出配置"
    echo "4. 返回"
    echo
    read -rp "请选择: " action

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
      4)
        return
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
  echo "========================================="
  echo " 用户列表"
  echo "========================================="
  echo

  mapfile -t users < <(user_list_names)

  if [ "${#users[@]}" -eq 0 ]; then
    echo "暂无用户"
    echo
    read -rp "按 Enter 返回..."
    exit 0
  fi

  index=1
  for username in "${users[@]}"; do
    remark="$(user_remark "$username")"
    if [ -n "$remark" ]; then
      echo "$index. $username ($remark)"
    else
      echo "$index. $username"
    fi
    echo
    index=$((index + 1))
  done

  echo "0. 返回"
  echo
  read -rp "请选择: " choice

  if [ "$choice" = "0" ]; then
    exit 0
  fi

  if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
    echo "请输入数字"
    read -rp "按 Enter 继续..."
    continue
  fi

  if [ "$choice" -lt 1 ] || [ "$choice" -gt "${#users[@]}" ]; then
    echo "无效选择"
    read -rp "按 Enter 继续..."
    continue
  fi

  selected="${users[$((choice - 1))]}"
  show_user_detail "$selected"
done
