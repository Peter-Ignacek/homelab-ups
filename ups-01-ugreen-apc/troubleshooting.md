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
