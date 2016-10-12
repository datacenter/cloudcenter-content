#!/usr/bin/env python
import requests
import os
requests.packages.urllib3.disable_warnings()

hostRef = os.getenv('infobloxRef')

#Create Host Record
url = "https://10.110.5.254/wapi/v1.0/" + hostRef
payload = ""
headers = {}
response = requests.request("DELETE", url, data=payload, headers=headers, verify=False, auth=('admin', 'infoblox'))