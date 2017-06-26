#!/usr/bin/env python

import requests
import json


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

instance_creds = get_snow_credential()
instance = instance_creds['instance']
username = instance_creds['username']
password = instance_creds['password']
table = "cmdb_ci_linux_server"

url = "https://{instance}/api/now/table/{table}".format(instance=instance, table=table)

payload = {
    "name": "test1"
}
s = requests.Session()

r = s.request("POST", url, data=json.dumps(payload), auth=(username, password))
