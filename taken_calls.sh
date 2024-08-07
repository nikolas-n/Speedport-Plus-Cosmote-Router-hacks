#!/bin/bash
#
# Description: Check taken calls. This script can run as a cronjob every one hour or so, e.g.:
#              0 * * * * /path/to/taken_calls.sh
#
# Requirements: jq
#

source .credentials

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve taken calls
TAKEN_CALLS=$(curl -s "http://192.168.1.1/data/PhoneCalls.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -r '.[] | select(.varid == "addtakencalls") | .varvalue | map(.varvalue) | join(",")' | cut -f2,3,4 -d "," | tr ',' '\t')

# Check if taken_calls.csv exists, if not store the taken calls in it
if [[ ! -f taken_calls.csv ]]
then
    echo "First time running the script, supposing all calls are taken. Saving them on taken_calls.csv and exiting"
    echo "$TAKEN_CALLS" > taken_calls.csv
    exit 0
fi

# Compare the taken calls retrieved with the ones you have locally
while read LINE
do
    grep -q "$LINE" taken_calls.csv
    if [[ $? == "1" ]]
    then
        LATEST_TAKEN_CALLS+="${LINE}\n"
    fi
done <<< "$TAKEN_CALLS"

if [[ -z $LATEST_TAKEN_CALLS ]]
then
    echo "No taken calls!"
else
    echo -e "Calls taken\n"
    echo -e "$LATEST_TAKEN_CALLS"
    echo "$TAKEN_CALLS" > taken_calls.csv
    ## You can always send the taken calls to a Telegram bot with  
    # curl -s -X GET "https://api.telegram.org/$TELEGRAM_BOTPATH/sendMessage" -d "chat_id=$TELEGRAM_CHATID" -d "text=Missed call(s): $LATEST_TAKEN_CALLS" > /dev/null

fi

