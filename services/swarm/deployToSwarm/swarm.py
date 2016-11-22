#!/usr/bin/env python

import requests
import json
import sys
import os

requests.packages.urllib3.disable_warnings()

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


s = requests.Session()

url = "http://54.70.83.127:2376/"

r = s.request("GET", url+"services")

print(r.json())

if cmd == "start" :
    try:
        with open(os.environ['serviceDef'], 'r') as template_file_fd:
            serviceDef = json.load(template_file_fd)
    except Exception as err:
        print_log("Error loading the ARM Template: {0}. Check your syntax".format(err))
        sys.exit(1)

    r = s.request("POST", url+"services/create", data=json.dumps(serviceDef))

elif cmd == "stop" :
    pass
elif cmd == "reload" :
    pass


print(r.json())