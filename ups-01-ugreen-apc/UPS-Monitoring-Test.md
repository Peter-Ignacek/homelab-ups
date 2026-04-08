# UPS Monitoring (UGREEN NAS)

## 🎯 Cel
Sprawdzenie:
- czy skrypt działa po restarcie NAS
- czy UPS poprawnie raportuje status
- ile trwały przerwy w zasilaniu

---

## 🔁 Test po restarcie NAS

Po restarcie sprawdź czy skrypt działa:

```bash
ps | grep ups-monitor
````
Oczekiwany wynik:

proces ups-monitor.sh jest widoczny

⚡ Sprawdzenie statusu UPS
```
upsc ups0@localhost | grep ups.status
````

Statusy:

OL = prąd jest (Online)
OB = brak prądu (On Battery)

📜 Historia przerw w zasilaniu

Podgląd ostatnich wpisów:
````
tail -20 /home/Piotr/ups-events.log
````
Tylko zdarzenia zasilania:
````
grep "POWER" /home/Piotr/ups-events.log
````
⏱️ Przykład logu

2026-04-08 18:52:07 - MONITOR STARTED - current UPS status: OL
2026-04-08 19:10:02 - POWER LOST
2026-04-08 19:18:44 - POWER RESTORED - outage lasted 8m 42s

🧠 Uwagi

jeśli NAS się wyłączy podczas braku prądu:
czas przerwy liczony jest do momentu restartu NAS
jeśli UPS podtrzyma NAS:
czas jest dokładny

🔎 Jak sprawdzić realny czas działania

Użyj:
````
ps -eo pid,etime,cmd | grep ups-monitor
````
👉 zobaczysz coś typu:

1738156  00:15:23 /home/Piotr/ups-monitor.sh

To jest:
👉 ETIME = realny czas działania
