#!/usr/bin/env bash
set -euo pipefail

USERS_DB="/etc/airport/users.json"
PORT="8443"
SNI="bing.com"

read -rp "请输入用户名，留空显示全部用户: " username

server_ip="$(curl -fsS https://api.ipify.org || hostname -I | awk '{print $1}')"

show_user() {
  local u="$1"
  local password
  local created_at
  local link

  password="$(jq -r --arg u "$u" '.[$u].password // empty' "$USERS_DB")"

  if [ -z "$password" ]; then
    echo "用户不存在: $u"
    return
  fi

  created_at="$(jq -r --arg u "$u" '.[$u].created_at // empty' "$USERS_DB")"
  link="hy2://${u}:${password}@${server_ip}:${PORT}/?sni=${SNI}&insecure=1#${u}"

  echo "------------------------------------------"
  echo "用户: $u"
  echo "密码: $password"
  echo "创建时间戳: ${created_at:-unknown}"
  echo
  echo "Shadowrocket / Hysteria2 链接:"
  echo "$link"
  echo
  echo "Mac Shadowrocket 可直接添加 hy2:// 链接。"
  echo "iPhone Shadowrocket 可复制链接或使用二维码。"
}

if [ -n "$username" ]; then
  show_user "$username"
else
  users="$(jq -r 'keys[]' "$USERS_DB")"

  if [ -z "$users" ]; then
    echo "暂无用户"
    exit 0
  fi

  for u in $users; do
    show_user "$u"
  done
fi
