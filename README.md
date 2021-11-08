# Introduction

Here you can find some interesting data that you can get from your home router. Whatever is here has been found through a combination of crawling the web and sending http requests on the router's administration page.

# Scripts added so far

* `device_connected.sh`: Check which devices are connected to and disconnected from your router and send notifications in either case.
* `dynamic_dns.sh`: Create a dyndns service of your own (you'll need to have somewhere a DNS server that you can update)
* `get_line_uptime.sh`: Check how many days you've been online with the same IP
* `get_public_ip.sh`: Retrieve your public IP without visiting any website on the internet
* `missed_calls.sh`: Get notifications on your missed calls. You can always access all the calls (missed, received, outgoing) on this URL (which is surprisingly hidden from the web-ui): http://192.168.1.1/html/content/phone/phone_call_list.html
* `get_data.py`: Get the data from all of your endpoints (details at the bottom of this file)
##Confuguring Scripts

You may configure above scripts using the `config` file. The settings are set using bash variables.

###Required settings

`IP` setting sets the routers ip in your network, by default it is `192.168.1.1`
`USERNAME` setting sets the authentication username
`PASSWORD` setting sets the authentication password

###Optional settings

'TELEGRAM_BOTPATH' setting sets the telegram bot token. If you don't have one, you can get one at https://telegram.me/botfather
'TELEGRAM_CHAT_ID' setting sets the chat id of the chat to send the notifications to.

# Responses Samples

You can find samples of all the endpoints found until now in the `responses_samples` folder. Values of the objects have been masked as they contain sensitive data :-)

# Endpoints

The endpoints all live under the **data** path, i.e. http://speedport.ip/data/*.json. For instance, if the router is on 192.168.1.1 (default one), then the login endpoint will be: `http://192.168.1.1/data/Login.json` (the capital L on Login is needed, as any other capital letter in all the endpoints).

## HTTP Requests to the router

All requests need at least one header to be accepted, and that is the Accept-Language (its value plays no role whatsoever). So, make sure you always add that, for example when checking the status of the router:

```
curl -H 'Accept-Language: en' "http://192.168.1.1/data/Status.json"
```

When not logged in, that will return data found on the `html/login/status.html` page.

## Logging in

If your firmware version is earlier than 09022001.00.030_OTE5, then you don't need to login because of a bug of the router's software. If your firmware is 09022001.00.030_OTE5 then you have to login with the followin command:

```
curl -c - -H 'Accept-Language: en' "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=*****" -d "password=*****"
```

After you have logged in, then you will have to use the cookie you got for the following requests. For instance, to have an overview of what's going on in your router you can hit the Overview endpoint like this:

```
curl -H "Cookie: session_id=2C43334D07267CAF5F9334596916E616" -H 'Accept-Language: en' "http://192.168.1.1/data/Overview.json"
```

### The bug

**UPDATE**: It has been fixed with the latest update of the firmware (09022001.00.030_OTE5).

If your router hasn't (automatically) been updated yet or you downgraded with the included .img file, you don't need to login and get a cookie. You can just omit that part and just send:

```
curl -H "Cookie: session_id=" -H 'Accept-Language: en' "http://192.168.1.1/data/Overview.json"
```

You'll still get everything as if you were logged.

The only case you will get a 302 Error response is if someone else (including you) is logged into the router, e.g. normally through the web page on a regular browser. Even so, you can kick them out, with:

```
curl -H 'Accept-Language: en' "http://192.168.1.1/html/login/index.html"
```

And then you can access all endpoints with the "broken" requests provided earlier.

## Responses

All responses are valid JSON files that begin with the following:

```
{"vartype":"value","varid":"device_name","varvalue":"Speedport Plus"}
{"vartype":"value","varid":"rebooting","varvalue":"0"}
{"vartype":"value","varid":"router_state","varvalue":"OK"}
{"vartype":"value","varid":"provis_inet","varvalue":"xx3"}
{"vartype":"value","varid":"provis_voip","varvalue":"xx3"}
{"vartype":"value","varid":"save_fails","varvalue":"0"}
{"vartype":"page_title","varid":"title","varvalue":"Speedport Plus Configuration Program"}
{"vartype":"status","varid":"loginstate","varvalue":"1"}
{"vartype":"status","varid":"status","varvalue":"ok"}
```

If an endpoint is valid but not activated, i.e. does not return the relevant data, then it will at least return that JSON. For example, PhoneDialedCalls.json, PhoneMissedCalls.json and PhoneTakenCalls.json are examples of such responses.

## List of the available endpoints
The Speedport Plus router has the following endpoints (you can also find them in the `endpoints_list.txt` file):

 - Abuseadv.json
 - Abuse.json
 - AnsweringMachine.json
 - Assistant.json
 - AuswAss.json
 - Connect.json
 - DECT.json (empty)
 - DECTStation.json (empty)
 - DynDNS.json
 - EAStatus.json
 - ExtendedRules.json
 - FilterAndTime.json
 - FirmwareUpdate.json
 - INetIP.json
 - InternetConnection.json
 - IPPhoneHandler.json
    - **Applicable for versions older than 09022001.00.030_OTE5:** Here you will find info about your land line. Among that info you can find the password that is used to authenticate your user to the VoIP cosmote server. Below you can check how you can use your landline from any other client!
 - IPPhone.json (not activated)
 - IPPhoneNumbers.json (not activated)
 - IPPrenumber.json
 - ISDNPhonePlugs.json
 - LAN.json
 - Login.json
 - ManagedDevice.json
 - Modules.json
 - NASBackupEntry.json
 - NASBackup.json
 - NASDevice.json
 - NASGuest.json
 - NASLight.json
 - NASMediacenter.json
 - NASMediaReplay.json
 - NASSync.json
 - NASUser.json
 - NASWorkgroup.json
 - NewDirectoryEntry.json
 - OtherDevice.json (not activated)
 - Overview.json
 - PhoneBook.json
 - PhoneCalls.json
    - Returns all data regarding calls. Dialed, Taken (i.e. received) or Missed for up to (at least) three months.
 - PhoneDialedCalls.json (not activated)
 - Phone.json
 - PhoneLineset.json
 - PhoneMissedCalls.json (not activated)
 - PhoneNumberAssignment.json
 - PhoneNumbers.json (not activated)
 - PhonePlugs.json
 - PhoneSettings.json
 - PhoneTakenCalls.json (not activated)
 - PhoneWebnWalk.json
 - Portforwarding.json
 - Reboot.json
 - Router.json (not activated)
 - SecureStatus.json
 - Status.json
 - SystemMessages.json
 - temp.json
 - TimeRules.json
 - WebnWalk.json (empty)
 - WLANAccess.json
 - WLANBasic.json


# Receive/Make calls from anywhere

**UPDATE**: The latest update of Cosmote's firmware makes the IPPhoneHandler.json return an empty string, so this info is no longer available.

## Applicable for firmware versions older than 09022001.00.030_OTE5

The info needed to do so are the following:

```
User name: +30XXXXXXXXXX
Password: this is the password you found in IPPhoneHandler as  t_password
Domain/Registrar: ims.otenet.gr
Authentication Name: +30XXXXXXXXXX@ims.otenet.gr
```

You can enter these details in any VoIP client, e.g. CsipSimple in Android, and you can have your landline anywhere!

The only limitation is that you cannot be registered simultaneously from multiple clients. If you register from another client, then you will receive/make calls to that client. If you deregister from your other client, you'll have to make sure that SpeedPort is re-registered again. You can do that by disabling and enabling the tickbox **Enable** on the Tel.Numbers page of the administration webpage (https://speedport.ip/html/content/phone/VoIP_index.html).

# Getting your data

You can get all the current data of your router with getData.py (python 3). Create the folder `my_router_responses`, install the requests python3 package with `pip3 install requests` and then run the file with:

```
python3 getData.py
```

### Flashing the older Firmware
Clone or download this repository and then open your router at http://speedport.ip/ , login with your password then open http://speedport.ip/html/content/config/check_for_updates.html and click on the option choose file, navigate to your file and click install. Then your router will reboot.
When you're done with downloading you can change back to the latest version by doing the same steps using the latest firmware file you can download from https://help.cosmote.gr/system/templates/selfservice/gnosisgr/files2/09022001.00.030_OTE5.img (latest as of 8/7/20) VOIP password does not change this way since they realy had no idea you did that.
