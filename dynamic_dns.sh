#!/bin/bash
#
# Description: This is a simple script that does the following:
#              1. Gets the external IP from the router
#              2. Compares it with the IP that is mapped to the domain
#              3. If the IPs differ, then
#                   a. There has been a change of your IP
#                   b. The DNS server is updated with the new IP
#              4. If the IPs do not differ, then no action is taken
#
# Requirements (on debian): curl, grep, jq, dnsutils
#              

source .credentials

# The domain you want to update
DOMAIN="example.com"

# Log out anyone currently on your router
curl -s -H 'Accept-Language: en' "http://192.168.1.1/html/login/index.html" > /dev/null

# Log into your router
LOGIN=$(curl -sc - "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=$USERNAME" -d "password=$PASSWORD" -H 'Accept-Language: el,en-US;q=0.7,en;q=0.3' | grep -oP "[0-Z]{32}")

# Get your external IP
ROUTERIP=$(curl -s -H "Cookie: session_id=$LOGIN" -H 'Accept-Language: en' "http://192.168.1.1/data/INetIP.json" | jq -j '.[] | select((.varid == "public_ip_v4")) | .varvalue')

# Check the current assigned IP of your domain
DOMAINIP=$(dig @8.8.8.8 "$DOMAIN" | grep "$DOMAIN" | cut -f5)

# Check and change if needed
if [[ $DOMAINIP == $ROUTERIP ]]
then
	# Domain does not need to be updated
	exit
else
	if [[ -z $ROUTERIP ]]
	then
		# Just a warning
		echo "ROUTERIP is empty! Something went wrong..."
	else

	# Run a command that will update the IP of example.com on the DNS server.
	# I'm using a combination of bind and webhook (both debian packages) on a remote server, something like
	# curl -s "http://mydomain.com:9000/webhook/IPchange?token=**************" -d "IP=$ROUTERIP" -d "domain=$DOMAIN"

	# Use telegram (or any other tool) to notify you about the IP change
	curl -s -X GET "https://api.telegram.org/$TELEGRAM_BOTPATH/sendMessage" -d "chat_id=$TELEGRAM_CHATID" -d "text=your IP changed to $ROUTERIP" > /dev/null
fi
fi

