# aprx_setup

Setup & Sample config files for aprx 2-way digipeater igate


These are my config files for using aprx and soundmodem to run a 2-way digipeater + iGate on Raspberry Pi with USB soundcard.

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
