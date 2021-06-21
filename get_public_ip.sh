#!/bin/bash
#
# Description: Get your public IP from your router without visiting any page on the web.
#
# Requirements: jq (or any other json parser)
#

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=******" -d "password=******" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve your IP
curl -s "http://192.168.1.1/data/INetIP.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -j '.[] | select((.varid == "public_ip_v4")) | .varvalue'

