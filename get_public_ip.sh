#!/bin/bash
#
# Description: Get your public IP from your router without visiting any page on the web.
#
# Attention: This script works fine as long as you are not behind a CG-NAT. Check check_if_behind_nat.sh for more info.
#
# Requirements: jq (or any other json parser)
#

source .credentials

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve your IP
curl -s "http://192.168.1.1/data/INetIP.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -j '.[] | select((.varid == "public_ip_v4")) | .varvalue'

