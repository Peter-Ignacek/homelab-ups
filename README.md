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

- [UPS 1](ups-01-ugreen-apc)

## Scripts
- [`scripts/ups-monitor.sh`](scripts/ups-monitor.sh)
🧩 Why a Custom Script?

The default UPS tools provide real-time status, but they do not keep a simple, persistent history of power outages.

To solve this, a custom monitoring script was created to:

detect power loss (OB) and power restore (OL) events
measure outage duration
store events in a readable log file
survive system reboots and continue tracking

This makes it possible to quickly verify:

when a power outage occurred
how long it lasted
whether the UPS successfully kept the NAS running
