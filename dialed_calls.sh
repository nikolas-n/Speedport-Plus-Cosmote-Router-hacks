#!/bin/bash
#
# Description: Check dialed calls. This script can run as a cronjob every one hour or so, e.g.:
#              0 * * * * /path/to/dialed_calls.sh
#
# Requirements: jq
#

source .credentials

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve dialed calls
DIALED_CALLS=$(curl -s "http://192.168.1.1/data/PhoneCalls.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -r '.[] | select(.varid == "adddialedcalls") | .varvalue | map(.varvalue) | join(",")' | cut -f2,3,4 -d "," | tr ',' '\t')

# Check if dialed_calls.csv exists, if not store the dialed calls in it
if [[ ! -f dialed_calls.csv ]]
then
    echo "First time running the script, supposing all calls are dialed. Saving them on dialed_calls.csv and exiting"
    echo "$DIALED_CALLS" > dialed_calls.csv
    exit 0
fi

# Compare the dialed calls retrieved with the ones you have locally
while read LINE
do
    grep -q "$LINE" dialed_calls.csv
    if [[ $? == "1" ]]
    then
        LATEST_DIALED_CALLS+="${LINE}\n"
    fi
done <<< "$DIALED_CALLS"

if [[ -z $LATEST_DIALED_CALLS ]]
then
    echo "No dialed calls!"
else
    echo -e "Calls dialed\n"
    echo -e "$LATEST_DIALED_CALLS"
    echo "$DIALED_CALLS" > dialed_calls.csv
    ## You can always send the dialed calls to a Telegram bot with  
    # curl -s -X GET "https://api.telegram.org/$TELEGRAM_BOTPATH/sendMessage" -d "chat_id=$TELEGRAM_CHATID" -d "text=DIALED call(s): $LATEST_DIALED_CALLS" > /dev/null

fi

