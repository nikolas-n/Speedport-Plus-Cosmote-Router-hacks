#!/bin/bash
#
# Description: Notify when a device is connected to your router.
#              This can be set up as a cronjob and run periodically.
#              
#
# Requirements: jq
#

source .credentials

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve connected devices
CONNECTED_DEVICES=$(curl -s "http://192.168.1.1/data/LAN.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -r '.[] | . as $parent | select(.varid == "addmdevice") | .varvalue[] | select(.varid=="mdevice_connected") | select(.varvalue == "1") | $parent | select(.varid == "addmdevice") | .varvalue | map(.varvalue) | join(";")' | cut -d ";" -f2,3,6,8 | sort -n -k4 -t ".")

# Check if connected_devices.csv exists.
# If it doesn't exist, store connected devices in it.
if [[ ! -f connected_devices.csv ]]
then
    echo "First time running the script, supposing all devices are new. Saving them on connected_devices.csv and exiting"
    echo "$CONNECTED_DEVICES" > connected_devices.csv
    exit 0
fi

TMP=$(mktemp)

echo "$CONNECTED_DEVICES" > $TMP

CHECK_CHANGES=$(diff connected_devices.csv $TMP)

if [[ -z $CHECK_CHANGES ]]
then
    echo "No devices (dis)connected."
else
    DEVICES_CONNECTED=$(echo "$CHECK_CHANGES" | grep ">" | cut -d " " -f2 | column -t -s ";")
    DEVICES_DISCONNECTED=$(echo "$CHECK_CHANGES" | grep "<" | cut -d " " -f2 | column -t -s ";")
    if [[ -n $DEVICES_DISCONNECTED ]]
    then
    echo -e "The following device(s) were disconnected"
    echo "$DEVICES_DISCONNECTED"
    curl -s -X GET "https://api.telegram.org/$TELEGRAM_BOTPATH/sendMessage" -d "chat_id=$TELEGRAM_CHATID" -d "text=Device(s) disconnected: $DEVICES_DISCONNECTED" -d "disable_notification=true" > /dev/null
    fi
    if [[ -n $DEVICES_CONNECTED ]]
    then
    echo -e "The following device(s) were connected"
    echo "$DEVICES_CONNECTED"
    curl -s -X GET "https://api.telegram.org/$TELEGRAM_BOTPATH/sendMessage" -d "chat_id=$TELEGRAM_CHATID" -d "text=Device(s) connected: $DEVICES_CONNECTED" -d "disable_notification=true" > /dev/null
    fi
    cp $TMP connected_devices.csv
fi
