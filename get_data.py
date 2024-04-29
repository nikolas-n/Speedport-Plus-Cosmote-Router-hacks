#!/bin/python3

import requests
import os
import urllib3
import json


with open('.credentials','r') as f:
	credentials = f.readlines()

for line in credentials:
	variable = line.split('=')[0].replace('\'', '').rstrip()
	value = line.split('=')[1].replace('\'', '').rstrip()
	if variable == 'USERNAME':
		username = value
	if variable == 'PASSWORD':
		password = value


# Suppress loggin about self-signed certificate
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Set headers
headers = {'Accept-Language': 'en'}

# Start session
session = requests.Session()

# Set username and password
login_data = {'showpw':'0','username':username,'password':password}

# Login
session.post('https://192.168.1.1/data/Login.json',data=login_data,headers=headers,verify=False)

# Load endpoints
with open('endpoints_list.txt') as endpoints_list:
	endpoints = endpoints_list.readlines()

# Create directory if it doesn't exist
if not os.path.exists('my_router_responses'):
    os.makedirs('my_router_responses')

# Download JSONs
for endpoint in endpoints:
	endpoint = endpoint.strip('\n')
	print('Retrieving endpoint '+endpoint)
	url='https://192.168.1.1/data/'+endpoint
	request = session.get(url, headers=headers,verify=False)
	pretty_json = json.dumps(json.loads(request.text),indent=4)
	print(pretty_json, file=open('my_router_responses/' + endpoint, "a"))
