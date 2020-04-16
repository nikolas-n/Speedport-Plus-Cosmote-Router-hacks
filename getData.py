#!/bin/python3

import requests

headers = {'Accept-Language': 'en','Cookie':'session_id='}

with open('endpoints_list.txt') as endpoints_list:
	endpoints = endpoints_list.readlines()

for endpoint in endpoints:
	endpoint = endpoint.strip('\n')
	print('Retrieving endpoint '+endpoint)
	url='http://192.168.1.1/data/'+endpoint
	request = requests.get(url, headers=headers)
	print(request.text, file=open('my_router_responses/' + endpoint, "a"))
