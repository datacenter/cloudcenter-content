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


s = requests.Session()

username = "admin@customer1"
password = "pa55word"

base_url = "http://172.16.204.34:8090/sim/v2/user"

try:
    hostname = os.getenv('cliqrNodeHostname')
    # Get the list of all the machines in AppD
    r = s.request("GET", url="{}/machines/".format(base_url), verify=False, auth=HTTPBasicAuth(username, password))

    # Filter the list to get the machine that matches the hostname of the machine we want to remove.
    machine = list(filter(lambda x: x['name'] == hostname, r.json()))
    if len(machine) < 1:
        print("Machine with hostname {} not found in AppD".format(hostname))

    # Get the id of that machine
    machine_id = machine[0]['id']

    # Delete the machine
    r = s.request("DELETE", url="{}/machines/{}".format(base_url, machine_id), verify=False,
                  auth=HTTPBasicAuth(username, password))

except Exception as err:
    print_log("Error Removing Machine from AppDynamics: {0}.".format(err))
    # sys.exit(1)
