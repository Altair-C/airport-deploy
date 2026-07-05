#!/usr/bin/env bash
set -euo pipefail

systemctl stop hysteria-server
systemctl status hysteria-server --no-pager -l
