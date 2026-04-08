# UPS Monitoring (UGREEN NAS)

## 🎯 Purpose

Verifyig:

the monitoring script runs after NAS reboot
the UPS correctly reports its status
power outages are detected and measured

---

## 🔁 🔁 Post-Reboot Check

After rebooting the NAS, verify that the script is running:

```bash
ps | grep ups-monitor
````
Expected result:

proces ups-monitor.sh jest widoczny

⚡ UPS Status Check
```
upsc ups0@localhost | grep ups.status
````

Status values:

OL = Online (power is available)
OB = On Battery (power outage)

📜 Power Outage History

View the latest log entries:
````
tail -20 /home/Piotr/ups-events.log
````
Filter only power-related events:
````
grep "POWER" /home/Piotr/ups-events.log
````
⏱️ Example Log

2026-04-08 18:52:07 - MONITOR STARTED - current UPS status: OL
2026-04-08 19:10:02 - POWER LOST
2026-04-08 19:18:44 - POWER RESTORED - outage lasted 8m 42s

🧠 Notes
If the NAS shuts down during a power outage:
→ the outage duration is measured until the NAS restarts
If the UPS keeps the NAS running:
→ the outage duration is accurate



🔎 Check Actual Runtime

Use:
````
ps -eo pid,etime,cmd | grep ups-monitor
````
Example output:

1738156  00:15:23 /home/Piotr/ups-monitor.sh

👉 ETIME = actual runtime of the script
