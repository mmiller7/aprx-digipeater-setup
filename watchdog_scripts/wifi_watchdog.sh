#!/bin/bash
#
# This file is designed to monitor for a failure in the WiFi connection on a Pi Zero and restart it if or reboot if it fails
# NOTE: This requires tweaking to your network!  Replace 192.168.1.1 with your router's IP!
# Save this file to /root/wifi_watchdog.sh
#
# Crontab entry
# */5 * * * * /root/wifi_watchdog.sh >/dev/null 2>&1

routerIP=192.168.1.1

ping -c 4 google.com > /dev/null 2>&1 || (
        /bin/echo 'Warning: Internet connectivity failed!' | /usr/bin/wall
)

ping -c 4 $routerIP > /dev/null 2>&1 || (
        /bin/echo 'LAN connectivity failed, restarting wlan0 . . .' | /usr/bin/wall
        /sbin/ifdown 'wlan0'
        /bin/sleep 5
        /sbin/ifup --force 'wlan0'
        /bin/sleep 30

        ping -c 4 192.168.1.1 > /dev/null 2>&1 || (
                /bin/echo 'LAN connectivity STILL failed, taking drastic action - REBOOT NOW!!!' | /usr/bin/wall
                /sbin/shutdown -r now
        )
)

