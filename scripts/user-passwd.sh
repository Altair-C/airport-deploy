#!/usr/bin/env bash
set -euo pipefail

USERS_DB="/etc/airport/users.json"

read -rp "请输入用户名: " username

if ! jq -e --arg u "$username" '.[$u]' "$USERS_DB" >/dev/null; then
  echo "用户不存在: $username"
  exit 1
fi

password="$(openssl rand -base64 18 | tr -d '=+/')"

tmp="$(mktemp)"
jq --arg u "$username" --arg p "$password" \
  '.[$u].password = $p' \
  "$USERS_DB" > "$tmp"

cat "$tmp" > "$USERS_DB"
rm -f "$tmp"

bash /opt/airport/scripts/render-config.sh
systemctl restart hysteria-server

echo "密码已修改"
echo "用户: $username"
echo "新密码: $password"
echo
bash /opt/airport/scripts/user-link.sh "$username"
