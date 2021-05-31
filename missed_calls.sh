#!/bin/bash
#
# Description: Check missed calls
#
# Requirements: jq
#

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=******" -d "password=********" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve missed calls
MISSED_CALLS=$(curl -s "http://192.168.1.1/data/PhoneCalls.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -r '.[] | select(.varid == "addmissedcalls") | .varvalue | map(.varvalue) | join(",")' | cut -f2,3,4 -d "," | tr ',' '\t')

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

    # You can always send the missed calls to a Telegram bot :-)
fi
