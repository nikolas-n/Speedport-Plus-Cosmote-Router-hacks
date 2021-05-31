#!/bin/bash
#
# Description: Get how many days you're online (with the same IP)
#
# Requirements: jq (or any other json parser)
#

printf "Days Online: "

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=*****" -d "password=******" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Get the days online
curl -s "http://192.168.1.1/data/INetIP.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -j '.[] | select((.varid == "days_online")) | .varvalue'
