worzenie własnego logu o zaniku i powrotu prądu.
nano /home/Piotr/ups-monitor.sh
Wklej to:

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
Nadaj prawa
chmod +x /home/Piotr/ups-monitor.sh
Sprawdź, czy plik jest cały
To ważne. Wpisz:

cat /home/Piotr/ups-monitor.sh
Na końcu musi być ostatnia linia:

done
