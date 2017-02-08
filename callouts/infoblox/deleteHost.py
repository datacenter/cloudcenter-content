#!/usr/bin/env python
import infoblox
import requests
import os
requests.packages.urllib3.disable_warnings()

querystring = {
    "_return_fields" : ["host"],
    "ipv4addr": os.environ['nicIP_0']
}
headers = {}
url = "https://10.110.1.45/wapi/v1.0/record:host_ipv4addr"
response = requests.request("GET", url, headers=headers, params=querystring, verify=False, auth=('admin', 'infoblox'))
response.json()
fqdn = response.json()[0]['host']

iba_api = infoblox.Infoblox('10.110.1.45', 'admin', 'infoblox', '1.6', 'default', 'default', False)

try:
    # Create new host record with supplied network and fqdn arguments
    ip = iba_api.delete_host_record(fqdn)
except Exception as e:
    print e
