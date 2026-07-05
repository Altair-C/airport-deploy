# Architecture

## Goal

Build a reusable deployment framework around Hiddify Manager.

## Components

- Ubuntu 24.04
- Docker
- Hiddify Manager
- SingBox
- Hysteria2

## Principle

Hiddify Manager handles panel, core, users, subscriptions, and protocol management.

airport-deploy handles:

- server bootstrap
- repeatable installation
- firewall preparation
- backup scripts
- restore scripts
- documentation
- Git-based maintenance

## Ports

Exact ports are finalized by Hiddify Manager during configuration.

Development access should use the public panel temporarily.

Production management should prefer SSH tunnel where possible.
