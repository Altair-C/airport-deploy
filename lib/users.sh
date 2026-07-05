#!/usr/bin/env bash
set -euo pipefail

USERS_DB="/etc/airctl/users.json"

ensure_users_db() {
  mkdir -p /etc/airctl
  if [ ! -f "$USERS_DB" ]; then
    echo '{}' > "$USERS_DB"
    chmod 600 "$USERS_DB"
  fi
}

user_exists() {
  local username="$1"
  jq -e --arg u "$username" '.[$u]' "$USERS_DB" >/dev/null
}

user_password() {
  local username="$1"
  jq -r --arg u "$username" '.[$u].password // empty' "$USERS_DB"
}

user_remark() {
  local username="$1"
  jq -r --arg u "$username" '.[$u].remark // ""' "$USERS_DB"
}

user_enabled() {
  local username="$1"
  jq -r --arg u "$username" '.[$u].enabled // true' "$USERS_DB"
}

user_created_at() {
  local username="$1"
  jq -r --arg u "$username" '.[$u].created_at // ""' "$USERS_DB"
}

user_list_names() {
  jq -r 'keys[]' "$USERS_DB"
}

user_count() {
  jq 'length' "$USERS_DB"
}

user_add() {
  local username="$1"
  local remark="$2"
  local password="$3"
  local now="$4"

  local tmp
  tmp="$(mktemp)"

  jq \
    --arg u "$username" \
    --arg r "$remark" \
    --arg p "$password" \
    --arg now "$now" \
    '. + {
      ($u): {
        "remark": $r,
        "password": $p,
        "enabled": true,
        "created_at": $now,
        "updated_at": $now,
        "expire_at": null,
        "traffic_limit": "Unlimited",
        "subscription_token": ""
      }
    }' "$USERS_DB" > "$tmp"

  cat "$tmp" > "$USERS_DB"
  rm -f "$tmp"
}

user_delete() {
  local username="$1"
  local tmp
  tmp="$(mktemp)"
  jq --arg u "$username" 'del(.[$u])' "$USERS_DB" > "$tmp"
  cat "$tmp" > "$USERS_DB"
  rm -f "$tmp"
}

user_set_password() {
  local username="$1"
  local password="$2"
  local now="$3"
  local tmp
  tmp="$(mktemp)"

  jq \
    --arg u "$username" \
    --arg p "$password" \
    --arg now "$now" \
    '.[$u].password = $p | .[$u].updated_at = $now' \
    "$USERS_DB" > "$tmp"

  cat "$tmp" > "$USERS_DB"
  rm -f "$tmp"
}

migrate_users_db() {
  ensure_users_db

  local tmp
  tmp="$(mktemp)"

  jq '
    with_entries(
      .value =
      if (.value | type) == "object" then
        {
          remark: (.value.remark // ""),
          password: (.value.password // ""),
          enabled: (.value.enabled // true),
          created_at: (
            if (.value.created_at | type) == "number" then
              (.value.created_at | todate)
            else
              (.value.created_at // "")
            end
          ),
          updated_at: (.value.updated_at // ""),
          expire_at: (.value.expire_at // null),
          traffic_limit: (.value.traffic_limit // "Unlimited"),
          subscription_token: (.value.subscription_token // "")
        }
      else
        {
          remark: "",
          password: (.value | tostring),
          enabled: true,
          created_at: "",
          updated_at: "",
          expire_at: null,
          traffic_limit: "Unlimited"
        }
      end
    )
  ' "$USERS_DB" > "$tmp"

  cat "$tmp" > "$USERS_DB"
  rm -f "$tmp"
  chmod 600 "$USERS_DB"
}


user_token() {
  local username="$1"
  jq -r --arg u "$username" '.[$u].subscription_token // empty' "$USERS_DB"
}

user_set_token() {
  local username="$1"
  local token="$2"
  local tmp
  tmp="$(mktemp)"

  jq --arg u "$username" --arg t "$token" \
    '.[$u].subscription_token = $t' \
    "$USERS_DB" > "$tmp"

  cat "$tmp" > "$USERS_DB"
  rm -f "$tmp"
}

ensure_user_tokens() {
  ensure_users_db
  migrate_users_db

  local tmp
  tmp="$(mktemp)"

  jq '
    with_entries(
      if (.value.subscription_token == null or .value.subscription_token == "") then
        .value.subscription_token = ""
      else
        .
      end
    )
  ' "$USERS_DB" > "$tmp"

  cat "$tmp" > "$USERS_DB"
  rm -f "$tmp"

  for username in $(user_list_names); do
    token="$(user_token "$username")"
    if [ -z "$token" ]; then
      token="$(openssl rand -hex 24)"
      user_set_token "$username" "$token"
    fi
  done
}
