```bash
Error: Unknown UPS
````
Tried commands

````
upsc ups
upsc ups@localhost
journalctl | grep ups
````

Key discovery

Listing UPS names showed:
````
upsc -l localhost
````

Output:

ups0

So the actual UPS name was not ups, but ups0.

Working command
upsc ups0@localhost
Result

The UPS returned full runtime and status information, including:

battery charge
runtime
input voltage
load
ups.status: OL
Notes
OL = online
OB = on battery
the message Init SSL without certificate database appeared, but did not block functionality

<img width="913" height="1059" alt="image" src="https://github.com/user-attachments/assets/4661e9ae-cd9c-4b58-a972-b3a14381601e" />


### Tworzenie  własnego logu o zaniku i powrotu prądu.
````
nano /home/Piotr/ups-monitor.sh
````
Wklej to:
````
#!/bin/sh

UPS="ups0@localhost"
LOGFILE="/home/Piotr/ups-events.log"
STATEFILE="/home/Piotr/ups-state.dat"

get_status() {
    upsc "$UPS" 2>/dev/null | awk -F': ' '/^ups.status:/ {print $2}'
}

log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

format_duration() {
    SECS="$1"
    H=$((SECS / 3600))
    M=$(((SECS % 3600) / 60))
    S=$((SECS % 60))

    if [ "$H" -gt 0 ]; then
        printf "%dh %dm %ds" "$H" "$M" "$S"
    elif [ "$M" -gt 0 ]; then
        printf "%dm %ds" "$M" "$S"
    else
        printf "%ds" "$S"
    fi
}

STATUS="$(get_status)"
NOW="$(date +%s)"

if [ -f "$STATEFILE" ]; then
    . "$STATEFILE"
else
    LAST_STATUS=""
    LOST_TS=""
fi

if [ "$LAST_STATUS" = "OB" ] && [ "$STATUS" = "OL" ] && [ -n "$LOST_TS" ]; then
    DURATION=$((NOW - LOST_TS))
    DUR_FMT="$(format_duration "$DURATION")"
    log_event "POWER RESTORED (after reboot) - outage lasted at least $DUR_FMT"
    LAST_STATUS="OL"
    LOST_TS=""
    echo "LAST_STATUS=\"$LAST_STATUS\"" > "$STATEFILE"
    echo "LOST_TS=\"$LOST_TS\"" >> "$STATEFILE"
fi

if [ -z "$LAST_STATUS" ] && [ -n "$STATUS" ]; then
    LAST_STATUS="$STATUS"
    echo "LAST_STATUS=\"$LAST_STATUS\"" > "$STATEFILE"
    echo "LOST_TS=\"$LOST_TS\"" >> "$STATEFILE"
    log_event "MONITOR STARTED - current UPS status: $STATUS"
fi

while true; do
    STATUS="$(get_status)"
    NOW="$(date +%s)"

    if [ -n "$STATUS" ] && [ "$STATUS" != "$LAST_STATUS" ]; then
        if [ "$STATUS" = "OB" ]; then
            LOST_TS="$NOW"
            log_event "POWER LOST"
        elif [ "$STATUS" = "OL" ]; then
            if [ -n "$LOST_TS" ]; then
                DURATION=$((NOW - LOST_TS))
                DUR_FMT="$(format_duration "$DURATION")"
                log_event "POWER RESTORED - outage lasted $DUR_FMT"
            else
                log_event "POWER RESTORED"
            fi
            LOST_TS=""
        else
            log_event "UPS STATUS CHANGED: $STATUS"
        fi

        LAST_STATUS="$STATUS"
        echo "LAST_STATUS=\"$LAST_STATUS\"" > "$STATEFILE"
        echo "LOST_TS=\"$LOST_TS\"" >> "$STATEFILE"
    fi

    sleep 5
done
````
5. Nadaj prawa
````
chmod +x /home/Piotr/ups-monitor.sh
````
7. Sprawdź, czy plik jest cały

To ważne. Wpisz:
````
cat /home/Piotr/ups-monitor.sh
````

Na końcu musi być ostatnia linia:

done

7. Uruchom testowo
````
/home/Piotr/ups-monitor.sh
````
Skrypt będzie działał „na pierwszym planie”, więc terminal jakby się zawiesi — to normalne.

8. W drugim oknie SSH sprawdź log
````
tail -f /home/Piotr/ups-events.log
````
Powinieneś zobaczyć coś typu:
````
2026-04-08 14:35:10 - MONITOR STARTED - current UPS status: OL
````
❗ Problem tej metody

Jak zamkniesz terminal → skrypt się wyłączy ❌

### uruchomić w tle

````
nohup /home/Piotr/ups-monitor.sh >/dev/null 2>&1 &
````
👉 teraz działa w tle

Sprawdzenie:
````
ps | grep ups-monitor
`````







