#!/bin/bash
# Created by Matthew Miller
# 06MAY2017
# Script to assist in configuring aprx APRS Digipeater/iGate software
# Required data includes callsign, aprsKey, lat, lon
# Assumption is soundcard is USB and PTT is serial USB0

APRSPASS_BUILD_DIR=~/aprspass_build
CONFIG_FILE="aprx.conf"
CONFIG_FILE2="soundmodem.conf"
aprs_gateway="noam.aprs2.net"
aprs_gateway_port=14580
status_text="APRX on $(uname -m) $(uname -s) built with https://git.io/vHUCM configuration"

set -e

if [ "$(whoami)" != "root" ]; then
	echo "ERROR: This script be run as root!"
  exit 1
fi

echo ''



#get callsign
read -p 'Enter your Amateur Radio license callsign: ' callsign
callsign="${callsign:=invalid}"
if [ "$callsign" == "invalid" ]
then
   echo 'ERROR: You did not specify a callsign!'
   exit 1
fi
callsign=${callsign^^}

#get aprsKey
read -p 'Do you have an APRS-IS key? (if unsure put "n") [y/N] ' userHasAprsKey
userHasAprsKey="${userHasAprsKey:=n}"
if [ "$userHasAprsKey" == "y" ] || [ "$userHasAprsKey" == "Y" ]
then
   aprsKey=0
   read -p 'Enter APRS-IS key: ' aprsKey
   aprsKey="${aprsKey:=0}"
else
   if [ ! -d $APRSPASS_BUILD_DIR ]
   then
      echo "Building APRSPASS calculator..."
      working_dir=`pwd`
      mkdir $APRSPASS_BUILD_DIR
      cd $APRSPASS_BUILD_DIR
      git clone https://github.com/mmiller7/aprspass.git
      cd aprspass
      make
      cd $working_dir
   fi
   keygenResult=$($APRSPASS_BUILD_DIR/aprspass/aprspass $callsign)
   echo "keygen - $keygenResult"
   aprsKey=$keygenResult
fi
echo ''



#callsign suffix
echo 'You should put a suffix for your iGate to differentiate it.'
echo 'This is a number which appears after your callsign on the'
echo "aprs.fi website.  For example, $callsign-1"
read -p "Input numeric suffix: ${callsign}-" callSuffix
callSuffix="${callSuffix:=1}"
callsign="${callsign}-$callSuffix"
echo ''



#get lat

#myloc lat ddmm.mmN lon dddmm.mmE

echo "Please sepcify latitude in degrees-minutes-decimal_minutes-direction."
echo "Examples: 38 06'00\" North --> 3806.00N"
echo "          10 28'15\" South --> 1028.25S"
read -p 'Enter latitude: ' lat
lat="${lat:=0000.00N}"
echo ''

#get lon
echo "Please sepcify longitude in degrees-minutes-decimal_minutes-direction."
echo "Examples: 120 06'00\" East --> 12006.00E"
echo "           77 40'15\" West --> 07740.25W"
read -p 'Enter longitude: ' lon
lon="${lon:=00000.00E}"
echo ''



#enable init.d
read -p 'Enable init.d for soundmodem and aprx iGate to run on boot? [Y/n] ' enable_init_d
enable_init_d="${enable_init_d:=y}"
echo ''



#print summary
echo 'The following settings have been configured:'
echo "iGate Call   : $callsign"
echo "APRS-IS Key  : $aprsKey"
echo "Latitude     : $lat"
echo "Longitude    : $lon"
echo "Boot script? : $enable_init_d"
echo ''



#apply configuration
echo "Applying settings to $CONFIG_FILE"
sed -i "s/^[\s]*mycall[\s]*.*/mycall $callsign/g" $CONFIG_FILE
sed -i "s/^[\s]*passcode[\s]*.*/passcode $aprsKey/g" $CONFIG_FILE
sed -i "s/^[\s]*server[\s]*.*/server $aprs_gateway/g" $CONFIG_FILE
sed -i "s/^[\s]*myloc[\s]*.*/myloc lat $lat lon $lon/g" $CONFIG_FILE
sed -i "s|^[\s]*beacon symbol[\s]*.*|beacon symbol \"I#\" \$myloc comment \"${status_text}\"|g" $CONFIG_FILE

echo "Applying settings to $CONFIG_FILE22"
sed -i "s/hwaddr=\"[^\"]*\"/hwaddr=\"$callsign\"/g" $CONFIG_FILE2

echo "Checking for old configuration in /etc and backing up if found"
cp -f /etc/$CONFIG_FILE /etc/${CONFIG_FILE}.old
cp -f /etc/ax25/$CONFIG_FILE2 /etc/ax25/${CONFIG_FILE2}.old

echo "Installing configuration files to /etc"
cp -f $CONFIG_FILE /etc
cp -f $CONFIG_FILE2 /etc/ax25


echo 'Applying ifconfig settings for soundmodem'
iptables rules for soundmodem interface:
iptables -A INPUT -i sm0 -p udp -j DROP
iptables -A OUTPUT -o sm0 -p udp -j DROP
iptables -A FORWARD -i sm0 -p udp -j DROP

#apply start-up scripts
if [ "$enable_init_d" == "y" ] || [ "$enable_init_d" == "Y" ]
then
   echo 'Setting rc.d soundmodem and aprx defaults'
   echo '********************************************************************'
   echo '* It is recommended you monitor and test your configuration with   *'
   echo '* a known working radio.  To start the services, you can kick them *'
   echo '* off run `sudo soundmodem start` and `sudo service aprx start` or *'
   echo '* wait until your next reboot to kick off the background service.  *'
   echo '********************************************************************'
   update-rc.d soundmodem defaults
   update-rc.d aprx defaults
   sudo systemctl enable soundmodem
   sudo systemctl enable aprx
else
   echo 'Removing soundmodem and aprx scripts from rc.d'
   echo '********************************************************************'
   echo '* It is recommended you monitor and test your configuration with   *'
   echo '* a known working radio.  To start the services, you can kick them *'
   echo '* off run `sudo soundmodem start` and `sudo service aprx start`.   *'
   echo '********************************************************************'
   sudo systemctl disable soundmodem
   sudo systemctl disable aprx
   update-rc.d -f soundmodem remove
   update-rc.d -f aprx remove
fi



echo 'Done!'
