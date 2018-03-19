#!/usr/bin/python

import requests
import json
import sys

hostname = sys.argv[1]
ipaddress = sys.argv[2]

url = "https://api.dnsimple.com/v1/domains/ciscolabs.net/records"

payload = {
  "record": {
    "name": hostname,
    "record_type": "A",
    "content": ipaddress,
    "ttl": 3600,
    "prio": 10
  }
}

headers = {
    'content-type': "application/json",
    'accept': "application/json",
    'x-dnsimple-token': "chocker@cisco.com:sO8q1V5faXTB0KJRSxApx3BE0uGUpAXv",
    }

response = requests.request("POST", url, data=json.dumps(payload), headers=headers)

print(response.text)
