#!/usr/bin/python
# -*- coding: utf-8 -*-

# Deployment cleanup script

import requests
import json
import argparse
import logging
from requests.auth import HTTPBasicAuth

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


parser = argparse.ArgumentParser()
parser.add_argument("username", help="Your API username. Not the same as your UI Login."
                                     "See your CloudCenter admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")


args = parser.parse_args()
username = args.username
apiKey = args.apiKey
ccm = args.ccm

session = requests.Session()

url = "https://"+ccm+"/v1/jobs"

querystring = {}

headers = {
    'x-cliqr-api-key-auth': "true",
    'accept': "application/json",
    'content-type': "application/json",
    'cache-control': "no-cache"
}

response = session.request("GET", url, headers=headers, params=querystring, verify=False,
                           auth=HTTPBasicAuth(username, apiKey))
# logging.debug(response.text.encode('utf-8'))

for job in response.json()['jobs']:
    dep_status = job['deploymentInfo']['deploymentStatus']
    if job['deploymentInfo'] and dep_status not in ['Terminated', 'Finished', 'Rejected']:
        deploymentId = job['deploymentInfo']['deploymentId']

        url = "https://"+ccm+"/v1/jobs/"+job['id']

        querystring = {"hide": "true"}

        headers = {
            'cache-control': "no-cache"
        }

        print_log("Terminating and hiding Job {}".format(job['id']))
        response = session.request("DELETE", url, headers=headers, params=querystring, verify=False,
                                   auth=HTTPBasicAuth(username, apiKey))
        # print_log(json.dumps(response.json(), indent=2))
