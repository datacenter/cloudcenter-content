#!/usr/bin/env python

import requests
import json
import sys
import os
from requests.auth import HTTPBasicAuth


def print_log(msg):
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_END")


def print_error(msg):
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_END")


def print_ext_service_result(msg):
    print("CLIQR_EXTERNAL_SERVICE_RESULT_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_RESULT_END")


cmd = sys.argv[1]
coll_name = os.getenv('parentJobName')+"-dbcoll"

s = requests.Session()

username = "admin@customer1"
password = "pa55word"
tier_name = os.getenv('cliqrAppTierName')
host_ip = os.getenv("CliqrTier_{}_PUBLIC_IP".format(tier_name))
db_username = "root"
db_password = os.getenv('cliqrDatabaseRootPass')
db_port = 3306

base_url = "http://172.16.204.34:8090/controller/rest"

if cmd == "add":
    try:
        payload = {
            "name": coll_name,
            "type": "MYSQL",
            "hostname": host_ip,
            "username": db_username,
            "password": db_password,
            "port": db_port,
            "enableOSMonitor": False,
            "agentName": "DB Agent a2",
            "enabled": True
        }
        headers = {
            "Content-Type": "application/json"
        }
        r = s.request("POST", url="{}/databases/collectors/create".format(base_url),headers=headers,
                      data=json.dumps(payload), verify=False, auth=HTTPBasicAuth(username, password))
        r.raise_for_status()
    except Exception as err:
        print_log("Error Adding DB Collector to AppDynamics: {0}.".format(err))
        print_log("Request Payload:\n {}".format(json.dumps(payload, indent=2)))
        # sys.exit(1)

elif cmd == "remove":
    try:
        headers = {
            "Content-Type": "application/json"
        }
        r = s.request("GET", url="{url}/databases/collectors/".format(url=base_url), headers=headers,
                      verify=False, auth=HTTPBasicAuth(username, password))
        r.raise_for_status()
        all_colls = r.json()
        my_colls = filter(lambda x: x['config']['name'] == coll_name, all_colls)

        for coll in my_colls:
            my_id = coll['config']['id']
            my_name = coll['config']['name']
            print_log("Deleting collection {} with id {}".format(my_name, my_id))
            headers = {
                "Content-Type": "application/json"
            }
            r = s.request("DELETE", url="{url}/databases/collectors/{id}".format(url=base_url, id=my_id),
                          headers=headers, verify=False, auth=HTTPBasicAuth(username, password))
            r.raise_for_status()
    except Exception as err:
        print_log("Error Removing DB Collector from AppDynamics: {0}.".format(err))
