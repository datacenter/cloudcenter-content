#!/usr/bin/python
# -*- coding: utf-8 -*-

# Deployment cleanup script

import requests, pdb, sys, json
from requests.auth import HTTPBasicAuth
import argparse


requests.packages.urllib3.disable_warnings()

parser = argparse.ArgumentParser()
parser.add_argument("username", help="Your API username. Not the same as your UI Login. See admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")
group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("-e", "--export", help="(text, not int) Service ID of the service that you want to export.")
group.add_argument("-i", "--import", help="Filename of the service that you want to import.")
args = parser.parse_args()
parser.parse_args()

username = args.username
apiKey = args.apiKey
ccm = args.ccm
baseUrl = "https://"+args.ccm

s = requests.Session()


def getTenantId():
    url = baseUrl+"/v1/users"

    querystring = {}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    tenantId = None
    for user in j['users']:
        #print(json.dumps(user['username'], indent=2))
        if user['username'] == username:
            tenantId = user['tenantId']
            break
    if not tenantId:
        print("Couldn't find tenantId")
        sys.exit(1)
    return tenantId

def getServiceId(tenantId, serviceName):
    url = baseUrl+"/v1/tenants/"+tenantId+"/services/"

    querystring = {
        "size" : 0
    }

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    serviceId = None
    for service in j['services']:
        #print(json.dumps(user['username'], indent=2))
        if service['name'] == serviceName:
            serviceId = service['id']
            break
    if not serviceId:
        print("Couldn't find serviceId")
        sys.exit(1)
    return serviceId

def getServiceManifest(serviceName):
    tenantId = getTenantId()
    serviceId = getServiceId(tenantId, serviceName)
    url = baseUrl+"/v1/tenants/"+tenantId+"/services/"+serviceId

    querystring = {}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))

    j = response.json()

    # Get rid of these two instance-specific parameters to make it importable.
    j.pop("id")
    j.pop("logoPath")

    return j

#parser.add_option("--import", dest="add", action="store_true", default=False)
#parser.add_argument("--export", dest="export", default=None)
#parser.add_option("--serviceName", dest="hostname", default=None)


if(args.export):
    serviceName = args.export
    print("Exporting service: {}".format(serviceName))
    j = getServiceManifest(serviceName)
    filename = "{serviceName}.servicemanifest".format(serviceName=serviceName)
    f = open(filename, 'w')

    json.dump(j, f, indent=4)
    print("Service {} exported to {}".format(serviceName, filename))


