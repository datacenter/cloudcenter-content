#!/usr/bin/env python

import requests
import json

s = requests.Session()

requests.packages.urllib3.disable_warnings()

instance = "dev19712.service-now.com"
username = 'admin'
password = 'a boatman Chugged0'
table = "cmdb_ci_linux_server"

url = "https://{instance}/api/now/table/{table}".format(instance=instance, table=table)

payload = {
    "name" : "test1"
}

r = s.request("POST", url, data=json.dumps(payload), auth=(username, password))