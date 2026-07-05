#!/usr/bin/env python3
import json
import sys
import urllib.request
from pathlib import Path

USERS_DB = Path("/etc/airctl/users.json")
CONFIG_FILE = Path("/etc/airctl/config.json")


def public_ip():
    try:
        return urllib.request.urlopen("https://api.ipify.org", timeout=3).read().decode().strip()
    except Exception:
        return "127.0.0.1"


def load_json(path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def find_user_by_token(token):
    users = load_json(USERS_DB)
    for username, data in users.items():
        if data.get("subscription_token") == token:
            return username, data
    return None, None


def generate_mihomo(username, user, config):
    server_ip = public_ip()
    port = config["server"]["port"]
    sni = config["server"]["sni"]
    password = user["password"]

    node_name = f"{username}-hy2"

    return f"""mixed-port: 7890
allow-lan: false
mode: rule
log-level: info

proxies:
  - name: {node_name}
    type: hysteria2
    server: {server_ip}
    port: {port}
    password: {password}
    sni: {sni}
    skip-cert-verify: true

proxy-groups:
  - name: PROXY
    type: select
    proxies:
      - {node_name}
      - DIRECT

rules:
  - MATCH,PROXY
"""


def main():
    if len(sys.argv) != 2:
        print("Usage: generator.py <subscription_token>", file=sys.stderr)
        sys.exit(1)

    token = sys.argv[1]
    username, user = find_user_by_token(token)

    if not username:
        print("Invalid subscription token", file=sys.stderr)
        sys.exit(2)

    if user.get("enabled") is False:
        print("User disabled", file=sys.stderr)
        sys.exit(3)

    config = load_json(CONFIG_FILE)
    print(generate_mihomo(username, user, config))


if __name__ == "__main__":
    main()
