# AirCtl Architecture

AirCtl is a no-panel Hysteria2 management toolkit.

## Components

- Ubuntu
- Hysteria2
- systemd
- UFW
- AirCtl CLI

## Runtime Paths

- `/opt/airctl` - AirCtl program files
- `/etc/airctl` - AirCtl configuration and user database
- `/etc/hysteria/config.yaml` - generated Hysteria2 server config
- `/etc/hysteria/certs` - TLS certificate files

## Principle

AirCtl is the single source of truth for configuration and user management.

Do not manually edit:

- `/etc/hysteria/config.yaml`
- `/etc/airctl/users.json`

Use `sudo airctl` instead.
