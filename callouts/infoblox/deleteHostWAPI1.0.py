#!/usr/bin/env python
import requests
import os

ip_addr = os.getenv('nicIP_0')

wapi_version = "1.2"
ib_api_endpoint = "https://10.110.5.254/wapi/v{}".format(wapi_version)


s = requests.Session()

url = "{}/ipv4address".format(ib_api_endpoint)

querystring = {"ip_address": ip_addr}

headers = {}

response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                     auth=('admin', 'infoblox'))

print(response.text)

# Delete every object associated to this IP address.
for obj in response.json()[0]['objects']:
    url = "{}/{}".format(ib_api_endpoint, obj)
    s.request("DELETE", url, verify=False,
              auth=('admin', 'infoblox'))

