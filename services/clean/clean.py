#!/usr/bin/python
# -*- coding: utf-8 -*-

# Deployment cleanup script

import requests
# import json
import argparse
# import logging
from requests.auth import HTTPBasicAuth

# requests.packages.urllib3.disable_warnings()

parser = argparse.ArgumentParser()
parser.add_argument("username", help="Your API username. Not the same as your UI Login."
                                     "See your CloudCenter admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")
# parser.add_argument("-d", "--debug", help="Set debug logging", action='store_const', const=logging.DEBUG)


args = parser.parse_args()
username = args.username
apiKey = args.apiKey
ccm = args.ccm


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

session = requests.Session()

# if args.debug:
#     logging.basicConfig(level=args.debug)


url = "https://{}/v1/jobs".format(ccm)

querystring = {}

headers = {
    'x-cliqr-api-key-auth': "true",
    'accept': "application/json",
    'content-type': "application/json",
    'cache-control': "no-cache"
}

response = session.request("GET", url, headers=headers, params=querystring, verify=False,
                           auth=HTTPBasicAuth(username, apiKey))
# print_log(response.text.encode('utf-8'))

for job in response.json()['jobs']:
    if job['deploymentInfo'] and job['deploymentInfo']['deploymentStatus'] in ['Error', 'Stopped', 'Suspended']:
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
    if job['deploymentInfo'] and job['deploymentInfo']['deploymentStatus'] in ['Terminated', 'Finished', 'Rejected']:
        deploymentId = job['deploymentInfo']['deploymentId']

        url = "https://"+ccm+"/v1/jobs/"+job['id']

        querystring = {"action": "hide"}

        headers = {
            'cache-control': "no-cache"
        }

        print_log("Hiding Job {}".format(job['id']))
        response = session.request("PUT", url, headers=headers, params=querystring, verify=False,
                                   auth=HTTPBasicAuth(username, apiKey))
        # print_log(job['id'])
        # print_log(json.dumps(response.json(), indent=2))
