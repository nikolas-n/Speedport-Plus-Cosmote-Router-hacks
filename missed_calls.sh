#!/bin/bash
#
# Description: Check missed calls. This script can run as a cronjob every one hour or so, e.g.:
#              0 * * * * /path/to/missed_calls.sh
#
# Requirements: jq
#

source config

# Log into your router
LOGIN=$(curl -sc - "http://$IP/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve missed calls
MISSED_CALLS=$(curl -s "http://$IP/data/PhoneCalls.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -r '.[] | select(.varid == "addmissedcalls") | .varvalue | map(.varvalue) | join(",")' | cut -f2,3,4 -d "," | tr ',' '\t')

# Check if missed_calls.csv exists, if not store the missed calls in it
if [[ ! -f missed_calls.csv ]]
then
    echo "First time running the script, supposing all calls are missed. Saving them on missed_calls.csv and exiting"
    echo "$MISSED_CALLS" > missed_calls.csv
    exit 0
fi

# Compare the missed calls retrieved with the ones you have locally
while read LINE
do
    grep -q "$LINE" missed_calls.csv
    if [[ $? == "1" ]]
    then
        LATEST_MISSED_CALLS+="${LINE}\n"
    fi
done <<< "$MISSED_CALLS"

if [[ -z $LATEST_MISSED_CALLS ]]
then
    echo "No missed calls!"
else
    echo -e "Calls missed\n"
    echo -e "$LATEST_MISSED_CALLS"
    echo "$MISSED_CALLS" > missed_calls.csv
    ## You can always send the missed calls to a Telegram bot with  
    # curl -s -X GET "https://api.telegram.org/$TELEGRAM_BOTPATH/sendMessage" -d "chat_id=$TELEGRAM_CHATID" -d "text=Missed call(s): $LATEST_MISSED_CALLS" > /dev/null

fi

