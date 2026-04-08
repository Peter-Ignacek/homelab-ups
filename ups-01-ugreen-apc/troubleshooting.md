❗ Initial Issue

Error encountered:

```bash
Error: Unknown UPS
````
Tried commands

````
upsc ups
upsc ups@localhost
journalctl | grep ups
````

🔍 Discovery

Listing available UPS devices:
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


### 📝 Custom Power Event Logging Script

Create the script:
````
nano /home/Piotr/ups-monitor.sh
````
Paste the following:
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
5. 🔐 Make Script Executable
````
chmod +x /home/Piotr/ups-monitor.sh
````
6.Verify Script Integrity
````
cat /home/Piotr/ups-monitor.sh
````

Ensure the file ends with:

done

7. Test Run (Foreground)
````
/home/Piotr/ups-monitor.sh
````
Skrypt będzie działał „na pierwszym planie”, więc terminal jakby się zawiesi — to normalne.

8. Monitor Logs

In another SSH session:
````
tail -f /home/Piotr/ups-events.log
````
Example:
````
2026-04-08 14:35:10 - MONITOR STARTED - current UPS status: OL
````
###❗ Limitation

If you close the terminal → the script stops ❌

▶️ Run in Background

````
nohup /home/Piotr/ups-monitor.sh >/dev/null 2>&1 &
````
👉 teraz działa w tle

Check:
````
ps | grep ups-monitor
`````

<img width="707" height="204" alt="image" src="https://github.com/user-attachments/assets/29dc4721-46a4-4ea2-af0c-a9bb10d0fda1" />

### Docelowo (NAJWAŻNIEJSZE)

🚀 Autostart (Important)

The goal is to make sure the script starts automatically after every NAS reboot. 

👉 Autostart

🔧 Option 1 — Cron (Preferred if available)

First, check whether crontab is available:
````
crontab -l
````
If it works, edit the user crontab:
````
crontab -e
````
Add this line at the end:
````
@reboot /home/Piotr/ups-monitor.sh >/dev/null 2>&1 &
````

Then verify it:
````
crontab -l
````
Expected output:

@reboot /home/Piotr/ups-monitor.sh >/dev/null 2>&1 &
<img width="439" height="90" alt="image" src="https://github.com/user-attachments/assets/7b1febf7-6c27-47c6-bb68-ee3128f74559" />


❌ Problem

On UGREEN NAS, this method did not work.

The system blocks user crontab access, returning an error such as:

Permission denied: /var/spool/cron

This is normal on some restricted NAS systems where the user does not have full cron permissions.

✅ Working Solution — rc.local

Since crontab is blocked, a reliable workaround is to start the script from rc.local.

This method works on boot and is typically more dependable on restricted systems like UGREEN NAS.

🔧 Step 1 — Check whether rc.local exists
````
ls -l /etc/rc.local
`````
Step 2 — Edit rc.local
````
sudo nano /etc/rc.local
````
At the very bottom of the file, add this line before exit 0:

The end of the file should look like this:
````
/home/Piotr/ups-monitor.sh >/dev/null 2>&1 &

exit 0
````

<img width="1343" height="369" alt="image" src="https://github.com/user-attachments/assets/3a433b57-2fa6-4fd5-b946-707a5692069d" />

Step 3 — Verify the change

After saving the file, check the last lines immediately:
````
tail -10 /etc/rc.local
````
<img width="761" height="336" alt="image" src="https://github.com/user-attachments/assets/f2239d26-ab5e-42f6-91b2-ae50d8c9e511" />

