# UPS 01 – UGREEN + APC Back-UPS XS 700U

## Goal
Get the UPS visible in CLI and monitor power loss / restore events.

## Environment
- Host: UGREEN NAS
- UPS: APC Back-UPS XS 700U
- Tooling: NUT / upsc

## Initial problem
The UPS was visible in the GUI, but `upsc ups@localhost` returned:

```bash
Error: Unknown UPS
````
