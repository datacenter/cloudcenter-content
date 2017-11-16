#!/usr/bin/env python

import requests
import json
import os
import sys


# I'm using Vault here to get my ServiceNow credential, but you could get some other way or just hard-code it.
def get_snow_credential():
    session = requests.Session()
    url = "http://172.16.204.243:8200/v1/secret/snow"
    headers = {
        'x-vault-token': "cc649599-7611-96d0-0a70-689552e6ff8b",
    }
    response = session.request("GET", url, headers=headers)
    return {
        "instance": response.json()['data']['instance'],
        "username": response.json()['data']['username'],
        "password": response.json()['data']['password']
    }

cmd = None
if len(sys.argv) > 1:
    cmd = sys.argv[1]


instance_creds = get_snow_credential()
instance = instance_creds['instance']
username = instance_creds['username']
password = instance_creds['password']
table = "u_cloudcenter_import_vms"

url = "https://{instance}/api/now/table/{table}".format(instance=instance, table=table)

tier_name = os.getenv('cliqrAppName')
print("Tier Name: {}".format(tier_name))

# Get lists of all info for all servers in this tier
node_list = os.getenv("CliqrTier_{}_NODE_ID".format(tier_name)).split(",")
print("Nodes: {}".format(node_list))

public_ip_list = os.getenv("CliqrTier_{}_PUBLIC_IP".format(tier_name)).split(",")
print("Public IPs: {}".format(public_ip_list))

private_ip_list = os.getenv("CliqrTier_{}_IP".format(tier_name)).split(",")
print("Private IPs: {}".format(private_ip_list))

hostname_list = os.getenv("CliqrTier_{}_HOSTNAME".format(tier_name)).split(",")
print("Hosts: {}".format(hostname_list))


hostname = os.getenv('cliqrNodeHostname')
print("Hostname: {}".format(hostname))

os_type = os.getenv('osName')
print("OS Type: {}".format(os_type))


# Figure out which position this particular vm is in the lists by comparing known hostname to
# the list of hostname. Assume that this list index is the same for this host in all other lists.
i = 0
for h in hostname_list:
    if h == hostname:
        break
    i = i + 1

host_index = i
print("Host Index: {}".format(host_index))

status = "Operational"
if cmd == "delete":
    status = "Terminated"

payload = {
    "u_hostname": hostname,
    "u_node_id": node_list[host_index],
    "u_public_ip": public_ip_list[host_index],
    "u_private_ip": private_ip_list[host_index],
    "u_os_type": os_type,
    "u_status": status
}
print("Payload: {}".format(payload))

s = requests.Session()

r = s.request("POST", url, data=json.dumps(payload), auth=(username, password))
