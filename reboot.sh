#!/bin/bash

source .credentials

LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

curl -s -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' -H "Cookie: session_id=$LOGIN" -s "http://192.168.1.1/html/content/config/problem_handling.html" > /dev/null

echo "Rebooting. This will take a while..."

curl -s --max-time 30 -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' -H "Cookie: session_id=$LOGIN" "http://192.168.1.1/data/Reboot.json" -d "reboot_device=true&sessionid=$LOGIN" | jq
