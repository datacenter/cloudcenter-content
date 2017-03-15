#!/usr/bin/python
# -*- coding: utf-8 -*-

# Deployment cleanup script

import requests
import json
import argparse
import logging
from requests.auth import HTTPBasicAuth

requests.packages.urllib3.disable_warnings()

parser = argparse.ArgumentParser()
parser.add_argument("username", help="Your API username. Not the same as your UI Login. See your CloudCenter admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")
parser.add_argument("-d", "--debug", help="Set debug logging", action='store_const', const=logging.DEBUG)


args = parser.parse_args()
username = args.username
apiKey = args.apiKey
ccm = args.ccm

session = requests.Session()

if args.debug:
    logging.basicConfig(level=args.debug)


url = "https://"+ccm+"/v1/jobs"

querystring = {}

headers = {
    'x-cliqr-api-key-auth': "true",
    'accept': "application/json",
    'content-type': "application/json",
    'cache-control': "no-cache"
    }

response = session.request("GET", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))
logging.debug(response.text.encode('utf-8'))

for job in response.json()['jobs']:
    if job['deploymentInfo'] and job['deploymentInfo']['deploymentStatus'] in ['Error', 'Stopped', 'Suspended']:
        deploymentId = job['deploymentInfo']['deploymentId']

        url = "https://"+ccm+"/v1/jobs/"+job['id']

        querystring = {"hide": "true"}

        headers = {
            'cache-control': "no-cache"
        }

        logging.info("Terminating and hiding Job {}".format(job['id']))
        response = session.request("DELETE", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))
        logging.debug(json.dumps(response.json(), indent=2))
    if job['deploymentInfo'] and job['deploymentInfo']['deploymentStatus'] in ['Terminated', 'Finished', 'Rejected']:
        deploymentId = job['deploymentInfo']['deploymentId']

        url = "https://"+ccm+"/v1/jobs/"+job['id']

        querystring = {"action": "hide"}

        headers = {
            'cache-control': "no-cache"
        }

        logging.info("Hiding Job {}".format(job['id']))
        response = session.request("PUT", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))
        logging.info(job['id'])
        logging.debug(json.dumps(response.json(), indent=2))
