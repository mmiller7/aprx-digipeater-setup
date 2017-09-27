# aprx_setup

Setup & Sample config files for aprx 2-way digipeater igate

These are my setup scripts and sample config files for using aprx and soundmodem to run a 2-way digipeater + iGate on Raspberry Pi with USB soundcard.

To get started, download this repository and you need to run two of the scripts:
1) download_install_apps.sh
This will install the dependencies, compile the software, and install the software to the required locations on your system.
2) configure_aprx.sh
This will guide you thru building the config files which should work for most configurations.  There is a very low possibility that you would be on a conflicting network with an IP address range 172.30.31.32-172.30.31.35 in which case you will need to manually change those addresses in /etc/ax25/soundmodem.conf after setup.



Here's some background on how I built this and what the scripts will help you automate if you want to do it manually:

I have started from this guide and tweaked the config to meet my own needs/desires.
https://philcrump.co.uk/Raspberry_Pi_APRS_Digipeater

The soundmodem application should be in the repositories, simply "apt-get install soundmodem" if you don't already have it.

The aprx application is a free download, build/install via makefile.
https://github.com/PhirePhly/aprx

Then you need to tweak the config files to insert your own callsign and APRS-IS key in place of mine.
Files are in these locations:
/etc/ax25/soundmodem.conf
/etc/aprx.conf

Then you'll need to set up startup scripts to load the soundmodem and aprx program on bootup.
