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
group.add_argument("-e", "--export", dest="e", metavar='servicename', help="(text, not int) Service ID of the service that you want to export.")
group.add_argument("-i", "--import", dest="i", metavar='filename', help="Filename of the service that you want to import.")
parser.add_argument("-o", "--overwrite", action='store_true', help="When importing, overwrite existing service in CloudCenter. When exporting, overwrite existing file.")
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

# Get the name of the service from the JSON
def getServiceName(serviceJson):
    serviceName = serviceJson['name']
    return(serviceName)

# Return a list of images used in the service
def getImagesFromService(serviceJson):
    images = []
    for image in serviceJson['images']:
        images.append(image['name'])

    return images

def getImages():
    tenantId = getTenantId()
    url = baseUrl+"/v1/tenants/"+tenantId+"/images"

    querystring = {}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))

    j = response.json()

    images = []
    for image in j.images:
        images.append(image['name'])
    return images

def createImage(image):
    tenantId = getTenantId()
    url = baseUrl+"/v1/tenants/"+tenantId+"/images"

    payload = {'name': image}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("POST", url, headers=headers, payload=payload, verify=False, auth=HTTPBasicAuth(username, apiKey))
    print("Image {} created".format(image))



# Import the service into a CloudCenter instance
def importService(serviceJson):
    tenantId = getTenantId()
    serviceName = getServiceName(serviceJson = serviceJson)
    serviceId = getServiceId(tenantId = tenantId, serviceName = serviceName)

    newImages = getImagesFromService(serviceJson) not in getImages()

    if newImages:
        print("Images {} not found. I will create them, but they will be UNMAPPED."
              "You will have to create the workers if necessary and map them yourself.".format(newImages.join(", ")))
        for image in newImages:
            createImage(image)
    else:
        print("All images named in this service have been found in the instance"
              ", but I can't promise that they are mapped properly or working with this service.")

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    if serviceId:
        print("Service ID: {} for service {} found.".format(serviceId, serviceName))
        if not args.overwrite:
            print("--overwrite not specified. Exiting")
            sys.exit()
        else:
            print("--overwrite specified. Updating existing service.")
            url = baseUrl+"/v1/tenants/"+tenantId+"/services/"+serviceId
            response = s.request("PUT", url, headers=headers, payload=serviceJson, verify=False, auth=HTTPBasicAuth(username, apiKey))
    else:
        print("Service ID for service {} not found. Creating".format(serviceName))
        url = baseUrl+"/v1/tenants/"+tenantId+"/services/"
        response = s.request("POST", url, headers=headers, payload=serviceJson, verify=False, auth=HTTPBasicAuth(username, apiKey))





# TODO: Check for existing file and properly use the overwrite flag.
if args.e :
    serviceName = args.e
    print("Exporting service: {}".format(serviceName))
    j = getServiceManifest(serviceName)
    filename = "{serviceName}.servicemanifest".format(serviceName=serviceName)
    with open(filename, 'w') as f:
        json.dump(j, f, indent=4)

    print("Service {} exported to {}".format(serviceName, filename))

if args.i :
    serviceFileName = args.i
    serviceJson = None

    with open(serviceFileName, 'r') as f:
        serviceJson = json.load(f)

    importService(serviceJson)




