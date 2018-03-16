#!/bin/bash
#
# This file is designed to monitor for a failure in soundmodem or aprx and restart the process automatically
# Save this file to /root/aprx_watchdog.sh
#
# Crontab entry
# */5 * * * * /root/aprx_watchdog.sh >/dev/null 2>&1


/sbin/ifconfig | /bin/grep sm0 || (
        /bin/echo 'Network interface to soundmodem missing, restarting soundmodem and aprx . . .' | /usr/bin/wall
        /usr/sbin/service soundmodem restart
        /usr/sbin/service aprx restart
)

/usr/sbin/service soundmodem status || (
        /bin/echo 'Service soundmodem failed, restarting soundmodem and aprx . . .' | /usr/bin/wall
        /usr/sbin/service soundmodem restart
        /usr/sbin/service aprx restart
)

/usr/sbin/service aprx status || (
        /bin/echo 'Service aprx failed, restarting . . .' | /usr/bin/wall
        /usr/sbin/service aprx restart
)
