#!/usr/bin/env python

import json
import httplib2
import urllib

#set the headers and the base URL
headers = {
    'Content-type': 'application/x-www-form-urlencoded'
}

url = 'http://http://35.160.83.0//nitro/v1/config/'

#contruct the payload with URL encoding
payload = {
    "object":{
        "login":{
            "username":"user",
            "password":"secret"
        }
    }
}
payload_encoded = urllib.urlencode(payload)
#create a HTTP object, and use it to submit a POST request
http = httplib2.Http()
response, content = http.request(url, 'POST', body=payload_encoded, headers=headers)
#for debug purposes, print out the headers and the content of the response
print json.dumps(response, sort_keys=False, indent=4)
print json.dumps(content, sort_keys=False, indent=4)