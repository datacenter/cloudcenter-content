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
coll_name = os.getenv('parentJobName', None)+"-dbcoll"

s = requests.Session()

username = "admin@customer1"
password = "pa55word"
tier_name = os.getenv('cliqrAppTierName')
host_ip = os.getenv("CliqrTier_{}_PUBLIC_IP".format(tier_name))

base_url = "http://172.16.204.34:8090/controller/rest"

if cmd == "add":
    try:
        payload = {
            "name": coll_name,
            "type": "MYSQL",
            "hostname": host_ip,
            "username": "root",
            "password": "welcome2cliqr",
            "port": 3306,
            "enableOSMonitor": True,
            "hostOS": "LINUX",
            "hostUsername": "root",
            "hostPassword": "auslab",
            "sshPort": 22,
            "agentName": "DB Agent a2",
            "enabled": True
        }
        headers = {
            "Content-Type": "application/json"
        }
        r = s.request("POST", url="{}/databases/collectors/create".format(base_url), headers=headers, data=json.dumps(payload), verify=False,
                      auth=HTTPBasicAuth(username, password))
        print_log(r.status_code)
        # print_log(json.dumps(r.json(), indent=2))
        r.raise_for_status()
    except Exception as err:
        print_log("Error Adding DB Collector to AppDynamics: {0}.".format(err))
        print_log("Request Payload:\n {}".format(json.dumps(payload, indent=2)))
        # sys.exit(1)

# TODO: Implement MySQL collector delete from AppD
elif cmd == "remove":
    try:
        pass
    except Exception as err:
        print_log("Error Removing DB Collector from AppDynamics: {0}.".format(err))
        # sys.exit(1)
