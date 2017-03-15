#!/usr/bin/python
# -*- coding: utf-8 -*-

# Deployment cleanup script

import argparse
import re
import requests
import sys
import json
import logging
from requests.auth import HTTPBasicAuth

# requests.packages.urllib3.disable_warnings()

parser = argparse.ArgumentParser()
parser.add_argument("username", help="Your API username. Not the same as your UI Login."
                                     " See your CloudCenter admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")
parser.add_argument("-d", "--debug", help="Set debug logging", action='store_const', const=logging.DEBUG)
parser.add_argument("-o", "--overwrite", action='store_true',
                    help="When importing, overwrite existing service in CloudCenter. When exporting,"
                         " overwrite existing file.")
parser.add_argument("-l", "--logo", type=argparse.FileType('rb'),
                    help="Filename of the NEW or UPDATED logo to attach to this service."
                         " Can be ommitted to leave logo unchanged.")

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("-e", "--export", dest="e", metavar='servicename',
                   help="(text, not int) Service ID of the service that you want to export.")
group.add_argument("-i", "--import", dest="i", metavar='filename',
                   help="Filename of the service that you want to import.", type=argparse.FileType('r'))

args = parser.parse_args()
parser.parse_args()

username = args.username
apiKey = args.apiKey
ccm = args.ccm
baseUrl = "https://"+args.ccm

s = requests.Session()


def get_tenant_id():
    url = baseUrl+"/v1/users"

    querystring = {}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    tenant_id = None
    for user in j['users']:
        if user['username'] == username:
            tenant_id = user['tenantId']
            break
    if not tenant_id:
        logging.error("Couldn't find tenant_id")
        sys.exit(1)
    return tenant_id


def get_service_id(tenant_id, service_name):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/services/"

    querystring = {
        "size": 0
    }

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    service_id = None
    for service in j['services']:
        if service['name'] == service_name:
            service_id = service['id']

    return service_id


def get_image_id(tenant_id, image_name):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/images/"

    querystring = {
        "size": 0
    }

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    image_id = None
    for image in j['images']:
        if image['name'] == image_name:
            image_id = image['id']

    return image_id


def get_repo_id(repo_name):
    url = baseUrl+"/repositories/"

    querystring = {
        "size": 0
    }

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    repo_id = None
    for repo in j['repositories']:
        if repo['displayName'] == repo_name:
            repo_id = repo['id']

    return repo_id


def get_image_name(tenant_id, image_id):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/images/"

    querystring = {
        "size": 0
    }

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=HTTPBasicAuth(username, apiKey))

    j = response.json()
    image_name = None
    for image in j['images']:
        if int(image['id']) == image_id:
            image_name = image['name']

    return image_name


def get_service_manifest(service_name):
    tenant_id = get_tenant_id()
    service_id = get_service_id(tenant_id, service_name)

    if not service_id:
        logging.error("Couldn't find service_id for service {}"
                      " in tenant Id {}".format(service_name, tenant_id))
        sys.exit(1)

    url = baseUrl+"/v1/tenants/"+tenant_id+"/services/"+service_id

    querystring = {}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring,
                         verify=False, auth=HTTPBasicAuth(username, apiKey))
    logging.debug(json.dumps(response.json(), indent=2))
    j = response.json()

    # Add a custom attribute to persist the name of the default image which makes this portal. The
    # default image Id won't be. Remove the default image Id for safety.
    j['defaultImageName'] = get_image_name(tenant_id, j['defaultImageId'])
    j.pop("defaultImageId", None)

    # Get rid of these instance/user/tenant-specific parameters to make it importable.
    j.pop("id", None)
    j.pop("ownerUserId", None)
    j.pop("resource", None)
    for port in j['servicePorts']:
        port.pop("id", None)
        port.pop("resource", None)

    return j


# Get the name of the service from the JSON
def get_service_name(service_json):
    service_name = service_json['name']
    return service_name


# Return a list of images used in the service
def get_images_from_service(service_json):
    images = []
    for image in service_json['images']:
        images.append(image['name'])

    return images


def get_images():
    tenant_id = get_tenant_id()
    url = baseUrl+"/v1/tenants/"+tenant_id+"/images"

    querystring = {}

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    response = s.request("GET", url, headers=headers, params=querystring,
                         verify=False, auth=HTTPBasicAuth(username, apiKey))

    j = response.json()

    images = []
    for image in j['images']:
        images.append(image['name'])
    return images


def create_image(image, tenant_id):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/images"

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    image.pop('id', None)
    image.pop('resource', None)
    image.pop('systemImage', None)

    response = s.request("POST", url, headers=headers, data=json.dumps(image),
                         verify=False, auth=HTTPBasicAuth(username, apiKey))
    new_image = response.json()
    logging.info("Image {} created with ID {}".format(new_image['name'], int(new_image['id'])))
    return int(new_image['id'])


def create_repo(repo):
    url = baseUrl+"/repositories/"

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    repo.pop('id', None)
    repo.pop('resource', None)

    response = s.request("POST", url, headers=headers, data=json.dumps(repo),
                         verify=False, auth=HTTPBasicAuth(username, apiKey))
    new_repo = response.json()
    logging.info("Repo {} created with ID {}".format(new_repo['displayName'], int(new_repo['id'])))
    return int(new_repo['id'])


# Import the service into a CloudCenter instance
def import_service(service):
    tenant_id = get_tenant_id()
    service_name = get_service_name(service_json=service)
    service_id = get_service_id(tenant_id=tenant_id, service_name=service_name)
    service.pop("id", None)
    service.pop("ownerUserId", None)
    service.pop("resource", None)
    for port in service['servicePorts']:
        port.pop("id", None)
        port.pop("resource", None)

    # Update all the imageIds in the service to match the ones in the instance that you're importing into.
    if len(service.get('images', [])) > 0:
        for image in service['images']:
            image_id = get_image_id(tenant_id, image['name'])
            if image_id:
                image['id'] = image_id
            else:
                logging.warn("Image {} not found. I will create it so that the service will import,"
                             " but it will be UNMAPPED. You will have to create the worker if"
                             " necessary and map it yourself.".format(image['name']))
                image['id'] = create_image(image, tenant_id)
        # Assume that key defaultImageName was properly inserted into the exported JSON, then use that to get correct
        # Image Id for the default Image.
        service['defaultImageId'] = get_image_id(tenant_id, service['defaultImageName'])

    # Create any repositories that are referenced by the service but not yet in the instance.
    if len(service.get('repositories', [])) > 0:
        repo_map = {}
        for repo in service['repositories']:
            old_repo_id = repo['id']
            repo_id = get_repo_id(repo['displayName'])
            if repo_id:
                repo['id'] = repo_id
            else:
                print("Repo {} not found. I will create it so that the service will import,"
                      " but can't promise it will be accessible or not.".format(repo['displayName']))
                repo['id'] = create_repo(repo)
            # Create a map of old repo IDs to new ones.
            repo_map["REPO_ID_"+str(old_repo_id)] = "REPO_ID_"+str(repo['id'])

        logging.debug(json.dumps(repo_map, indent=2))

        # Dump service dict to json string.
        service_json = json.dumps(service)

        pattern = re.compile('|'.join(repo_map.keys()))

        # This lambda function replaces each of the keys with their values from repo_map in service_json.
        # This is used to replace each of the old repo ID's with the new ones in the service JSON.
        result = pattern.sub(lambda x: repo_map[x.group()], service_json)

        # Load the json string back into a dict, replacing the old service after replacing all the repo ID's
        service = json.loads(result)

    # Assume that key defaultImageName was properly inserted into the exported JSON, then use that to get correct
    # Image Id for the default Image.
    if 'defaultImageName' in service:
        service['defaultImageId'] = get_image_id(tenant_id, service['defaultImageName'])
    else:
        logging.warn("Your manifest file didn't have a defaultImageName key, as it would if"
                     " exported from the instance using this tool. Therefore I'm not able to"
                     " update the image ID to the one that matches your instance, which may"
                     " be different than the one it came from. Funny image related things may happen.")

    # Upload Logo
    if args.logo:
        logo_file = args.logo
        headers = {
            'accept': "*/*"
        }
        params = {
            "type": "logo"
        }
        url = baseUrl+"/v1/file"
        files = {'file': logo_file}
        response = s.request("POST", url, files=files, params=params, headers=headers,
                             verify=False, auth=HTTPBasicAuth(username, apiKey))

        # After uploading the image the response contains a temporary location for the logo which
        # has to be placed into the logo_path for the service. This gets changed behind the scenes
        # automatically to what it should be.

        j = response.json()
        logo_path = j['params'][0]['value']
        service['logoPath'] = logo_path

    logging.debug(json.dumps(service, indent=2))

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    if service_id:
        logging.info("Service ID: {} for service {} found in the CloudCenter"
                     " instance.".format(service_id, service_name))
        if not args.overwrite:
            print("--overwrite not specified. Exiting")
            sys.exit()
        else:
            logging.info("--overwrite specified. Updating existing service.")
            url = baseUrl+"/v1/tenants/"+tenant_id+"/services/"+service_id
            service['id'] = service_id
            response = s.request("PUT", url, headers=headers, data=json.dumps(service), verify=False,
                                 auth=HTTPBasicAuth(username, apiKey))
            logging.debug(json.dumps(response.json(), indent=2))

    else:
        if not args.logo:
            logging.critical("You must specify a logo file for new services. Use the -l switch.")
            exit(1)
        logging.info("Service ID for service {} not found. Creating".format(service_name))
        url = baseUrl+"/v1/tenants/"+tenant_id+"/services/"
        response = s.request("POST", url, headers=headers, data=json.dumps(service),
                             verify=False, auth=HTTPBasicAuth(username, apiKey))
        logging.debug(json.dumps(response.json(), indent=2))
        if response.status_code == 201:
            logging.info("Service {} created with Id {}".format(service_name, response.json()['id']))
        else:
            logging.critical("Failed to create service.")
            exit(1)

# TODO: Check for existing file and properly use the overwrite flag.
if args.debug:
    logging.basicConfig(level=args.debug)

if args.e:
    serviceName = args.e
    logoPath = "{}/assets/img/appTiers/{}/logo.png".format(baseUrl, serviceName)
    logoFile = "{}.png".format(serviceName)
    filename = "{serviceName}.servicemanifest".format(serviceName=serviceName)

    logging.info("Exporting service: {}".format(serviceName))
    svc_manifest = get_service_manifest(serviceName)
    with open(filename, 'w') as f:
        json.dump(svc_manifest, f, indent=4)
    logging.info("Service {} exported to {}".format(serviceName, filename))

    # Download logo too
    try:
        logo_response = s.request("GET", logoPath)
        with open(logoFile, 'wb') as out_file:
            out_file.write(logo_response.content)
        logging.info("Logo downloaded to {}".format(logoFile))

    except Exception as err:
        logging.error("Unable to download logo from {}: {}".format(logoPath, err))

if args.i:
    import_service_json = json.load(args.i)

    import_service(import_service_json)
