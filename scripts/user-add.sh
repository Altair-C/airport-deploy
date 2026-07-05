#!/usr/bin/env bash
set -euo pipefail

source /opt/airctl/lib/users.sh

ensure_users_db
migrate_users_db

read -rp "请输入用户名: " username

if [ -z "$username" ]; then
  echo "用户名不能为空"
  exit 1
fi

if user_exists "$username"; then
  echo "用户已存在: $username"
  exit 1
fi

read -rp "请输入备注，可留空: " remark

password="$(openssl rand -base64 18 | tr -d '=+/')"
now="$(date '+%Y-%m-%d %H:%M:%S')"

user_add "$username" "$remark" "$password" "$now"
token="$(openssl rand -hex 24)"
user_set_token "$username" "$token"
token="$(openssl rand -hex 24)"
user_set_token "$username" "$token"

bash /opt/airctl/scripts/render-config.sh
systemctl restart hysteria-server

echo "用户创建成功"
echo "用户名: $username"
echo "备注: ${remark:-无}"
echo "密码: $password"
echo "订阅Token: $token"
echo "订阅Token: $token"
echo
bash /opt/airctl/scripts/user-link.sh "$username"
