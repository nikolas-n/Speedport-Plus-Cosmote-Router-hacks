#!/bin/bash
#
# Description: Check if your provider has put you behind a CG-NAT. If so, then the public IP you are getting from your router will be different than the actual one.
#
# Wikipedia about CG-NAT: https://en.wikipedia.org/wiki/Carrier-grade_NAT
#
# Requirements: jq (or any other json parser)
#

source .credentials

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Retrieve the public IP your router sees
ROUTER_PUBLIC_IP=$(curl -s "http://192.168.1.1/data/INetIP.json" -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | jq -j '.[] | select((.varid == "public_ip_v4")) | .varvalue')

# Retrieve your public IP
ACTUAL_PUBLIC_IP=$(curl -s -4 ip.ergma.stream)

if [[ $ROUTER_PUBLIC_IP == $ACTUAL_PUBLIC_IP ]]
then
	echo 'Your public IP is the one given to your router!'
	echo 'Port forwarding should work!'
	echo 'You can use get_public_ip.sh for getting your address.'
else
	echo 'You are behind a CG-NAT!'
	echo 'Your public IP is '$ACTUAL_PUBLIC_IP'.'
	echo 'The IP given to your router is '$ROUTER_PUBLIC_IP'.'
	echo 'Consider SSH reverse tunneling for exposing stuff.'
	echo 'You can use ip.ergma.stream (or any other such service) to get your real IP address.'
fi	
