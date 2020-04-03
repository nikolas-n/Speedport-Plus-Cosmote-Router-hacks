# Introduction

Here you can find some interesting data that you can get from your home router. Whatever is here has been found through a combination of crawling the web and sending http requests on the router's administration page.

# Responses Samples

You can find samples of all the endpoints found until now in the `responses_samples` folder. Values of the objects have been masked as they contain sensitive data :-)

# Endpoints

The endpoints all live under the **data** path, i.e. http://router.ip/data/*.json. For instance, if the router is on 192.168.1.1 (default one), then the login endpoint will be: `http://192.168.1.1/data/Login.json` (the capital L on Login is needed, as any other capital letter in all the endpoints).

## HTTP Requests to the router

All requests need at least one header to be accepted, and that is the Accept-Language (its value plays no role whatsoever). So, make sure you always add that, for example when checking the status of the router:

```
curl -H 'Accept-Language: en' "http://192.168.1.1/data/Status.json"
```

When not logged in, that will return data found on the `html/login/status.html` page.

## Logging in

You don't need to login because of a bug of the router's software. But if you'd like to here's how.

```
curl -H 'Accept-Language: en' "http://192.168.1.1/data/Login.json" -d "showpw=0" -d "username=*****" -d "password=*****"
```

After you have logged in, then you will have to use the cookie you got for the following requests. For instance, to have an overview of what's going on in your router you can hit the Overview endpoint like this:

```
curl -H "Cookie: session_id=2C43334D07267CAF5F9334596916E616" -H 'Accept-Language: en' "http://192.168.1.1/data/Overview.json"
```

### The bug

But actually, you don't need to login and get a cookie. You can just omit that part and just send:

```
curl -H "Cookie: session_id=" -H 'Accept-Language: en' "http://192.168.1.1/data/Overview.json"
```

You'll still get everything as if you were logged.

The only case you will get a 302 Error response is if someone else (including you) is logged into the router, e.g. normally through the web page on a regular browser. Even so, you can kick them out, with:

```
curl -H 'Accept-Language: en' "http://192.168.1.1/html/login/index.html"
```

And then you can access all endpoints with the "broken" requests provided earlier.

## List of the available endpoints
The Speedport Plus router has the following endpoints.

 - Abuseadv.json
 - Abuse.json
 - AnsweringMachine.json
 - Assistant.json
 - AuswAss.json
 - Connect.json
 - DECT.json
 - DECTStation.json
 - DiskDirectoryEntry.json
 - DynDNS.json
 - EAStatus.json
 - ExtendedRules.json
 - FilterAndTime.json
 - FirmwareUpdate.json
 - INetIP.json
 - InternetConnection.json
 - IPPhoneHandler.json
 - IPPhone.json
 - IPPhoneNumbers.json
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
 - OtherDevice.json
 - Overview.json
 - PhoneBook.json
 - PhoneCalls.json
 - PhoneDialedCalls.json
 - Phone.json
 - PhoneLineset.json
 - PhoneMissedCalls.json
 - PhoneNumberAssignment.json
 - PhoneNumbers.json
 - PhonePlugs.json
 - PhoneSettings.json
 - PhoneTakenCalls.json
 - PhoneWebnWalk.json
 - Portforwarding.json
 - Reboot.json
 - Router.json
 - SecureStatus.json
 - Status.json
 - SystemMessages.json
 - temp.json
 - TimeRules.json
 - WebnWalk.json
 - WLANAccess.json
 - WLANBasic.json
