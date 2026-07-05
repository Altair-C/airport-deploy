#!/usr/bin/env bash
set -euo pipefail

systemctl start hysteria-server
systemctl status hysteria-server --no-pager -l
