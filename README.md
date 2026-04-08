# homelab-ups

# HomeLab Power

Power and UPS monitoring in my homelab.

## Stack
- UGREEN NAS + APC Back-UPS XS 700U (01)
- UNIFI DREAM Machine + APC Back-UPS XS 700U (02)
- Proxmox Intel U200 + APC Back-UPS XS 700U (03)
- NUT (Network UPS Tools)
- Shell scripts for logging power events

## Goals
- detect UPS correctly in CLI
- monitor power loss / restore events
- build logging for outages
- prepare shutdown logic for later
- document all 3 UPS units in the house

## Current devices
- UPS 01: APC Back-UPS XS 700U connected to UGREEN NAS

## Documentation
- [overview](https://github.com/Peter-Ignacek/homelab-ups/blob/main/ups-01-ugreen-apc/overview.md)
- [UPS 01 – UGREEN + APC Back-UPS XS 700U](docs/ups-01-ugreen-apc-backups-xs700u.md)
- [Troubleshooting](dups-01-ugreen-apc/troubleshooting.md)

## Scripts
- [`scripts/ups-monitor.sh`](scripts/ups-monitor.sh)
