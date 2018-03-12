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
parser.add_argument("username", help="Your API username. Not the same"
                                     "as your UI Login. See your "
                                     "CloudCenter admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")
log_choices = {
    'critical': logging.CRITICAL,
    'error': logging.ERROR,
    'warning': logging.WARNING,
    'info': logging.INFO,
    'debug': logging.DEBUG
}
parser.add_argument("-d", "--debug", help="Set logging level.",
                    choices=log_choices)
parser.add_argument("-o", "--overwrite", action='store_true',
                    help="When importing, overwrite existing service "
                         "in CloudCenter. When exporting, overwrite "
                         "existing file.")
parser.add_argument("-l", "--logo", type=argparse.FileType('rb'),
                    required=False, help="Filename of the NEW or "
                                         "UPDATED logo to attach to "
                                         "this service.  Can be "
                                         "ommitted to leave logo"
                                         "unchanged.")

group = parser.add_mutually_exclusive_group(required=True)
group.add_argument("-e", "--export", dest="e", metavar='servicename',
                   help="(text, not int) Service ID of the service "
                        "that you want to export.")
group.add_argument("-i", "--import", dest="i", metavar='filename',
                   help="Filename of the service that you want to "
                        "import.", type=argparse.FileType('r'))

args = parser.parse_args()
parser.parse_args()

username = args.username
apiKey = args.apiKey
ccm = args.ccm
baseUrl = "https://"+args.ccm

if args.debug:
    logging.basicConfig(level=log_choices[args.debug])

s = requests.Session()


# Simple function to merge two dicts, with dict2 values overwriting
# dict1
def dict_merge(dict1=None, dict2=None):
    if dict1 and dict2:
        new_dict = dict1.copy()
        new_dict.update(dict2)
        return new_dict
    elif dict1:
        return dict1
    else:
        return dict2


def api_call(method, url, headers=None, params=None, data=None,
             files=None):
    if method == "GET":
        my_params = {
            "size": 0
        }
        params = dict_merge(my_params, params)
    my_headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    headers = dict_merge(my_headers, headers)
    try:
        response = s.request(method, url, headers=headers,
                             params=params, data=data, files=files,
                             verify=False, auth=HTTPBasicAuth(
                                username, apiKey))
        logging.debug("URL: {}".format(response.request.url))
        logging.debug("Request Body: {}".format(response.request.body))
        logging.debug("Request Headers: {}".format(
            response.request.headers))
        logging.debug("Status Code: {}".format(response.status_code))
        if 'image/' in response.headers['content-type']:
            logging.debug("Response: Image")
        else:
            logging.debug("Response: {}".format(response.text))

        response.raise_for_status()
    except Exception as e:
        if response.status_code in [401]:
            logging.error("API call failed, probably due to bad "
                          "credentials.")
        else:
            logging.error("API call failed.")
        logging.error(e)
        raise
    return response


def get_tenant_id():
    url = baseUrl+"/v1/users"

    response = api_call(method="GET", url=url)
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


def validate_category(tenant_id, category_id):
    category_id = str(category_id)
    params = {
        'parentService': True
    }
    url = baseUrl+"/v1/tenants/" + str(tenant_id) + "/services/"
    response = api_call("GET", url, params=params)
    j = response.json()
    category_name = None
    categories = []
    for parent_service in j['services']:
        logging.debug(parent_service['name'])
        categories.append({
            'Name': parent_service['displayName'],
            'ID': parent_service['id']
        })
        if parent_service['id'] == category_id:
            category_name = parent_service['displayName']
    if category_name:
        return True
    else:
        logging.info("Failed to find category matching ID: {}".format(
            category_id))
        logging.info("Valid categories are:"
                     "{}"
                     "You should update your servicemanifest file "
                     "accordingly.".format(json.dumps(categories,
                                                      indent=2)))
        return False


def get_service_id(tenant_id, service_name):
    logging.info("Getting ID for service {}".format(service_name))
    params = {
        'parentService': True
    }
    url = baseUrl+"/v1/tenants/" + str(tenant_id) + "/services/"
    response = api_call("GET", url, params=params)
    j = response.json()
    service_id = None
    for parent_service in j['services']:
        for service in parent_service['childServices']:
            logging.debug(service['name'])
            if service['name'] == service_name:
                service_id = service['id']
    # for service in j['services']:
    #     logging.debug(service['name'])
    #     if service['name'] == service_name:
    #         service_id = service['id']
    if service_id:
        logging.info("Found ID {} for service {}".format(service_id,
                                                         service_name))
    else:
        logging.info("Did not find ID for service {}".format(
            service_name))
    return service_id


def get_image_id(tenant_id, image_name):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/images/"

    response = api_call("GET", url)

    j = response.json()
    image_id = None
    for image in j['images']:
        if image['name'] == image_name:
            image_id = image['id']

    return image_id


def get_repo_id(repo_name):
    url = baseUrl+"/repositories/"

    response = api_call("GET", url)

    j = response.json()
    repo_id = None
    for repo in j['repositories']:
        if repo['displayName'] == repo_name:
            repo_id = repo['id']

    return repo_id


def get_image_name(tenant_id, image_id):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/images/"

    response = api_call("GET", url)

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
                      " in tenant Id {}".format(service_name,
                                                tenant_id))
        sys.exit(1)

    url = baseUrl+"/v1/tenants/"+tenant_id+"/services/"+service_id

    response = api_call("GET", url)
    logging.debug(json.dumps(response.json(), indent=2))
    j = response.json()

    # Add a custom attribute to persist the name of the default image
    # which makes this portal. The default image Id won't be. Remove
    # the default image Id for safety.
    j['defaultImageName'] = get_image_name(tenant_id,
                                           j['defaultImageId'])
    j.pop("defaultImageId", None)

    # Get rid of these instance/user/tenant-specific parameters to
    # make it importable.
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

    response = api_call("GET", url)

    j = response.json()

    images = []
    for image in j['images']:
        images.append(image['name'])
    return images


def create_image(image, tenant_id):
    url = baseUrl+"/v1/tenants/" + tenant_id + "/images"

    image.pop('id', None)
    image.pop('resource', None)
    image.pop('systemImage', None)

    response = api_call("POST", url, data=json.dumps(image))
    new_image = response.json()
    logging.info("Image {} created with ID {}".format(
        new_image['name'], int(new_image['id'])))
    return int(new_image['id'])


def create_repo(repo):
    url = baseUrl+"/repositories/"

    repo.pop('id', None)
    repo.pop('resource', None)

    response = api_call("POST", url, data=json.dumps(repo))
    new_repo = response.json()
    logging.info("Repo {} created with ID {}".format(
        new_repo['displayName'], int(new_repo['id'])))
    return int(new_repo['id'])


# Import the service into a CloudCenter instance
def import_service(service):
    tenant_id = get_tenant_id()
    service_name = get_service_name(service_json=service)
    service_id = get_service_id(tenant_id=tenant_id,
                                service_name=service_name)
    service.pop("id", None)
    service.pop("ownerUserId", None)
    service.pop("resource", None)
    service.pop("systemService", None)
    for port in service['servicePorts']:
        port.pop("id", None)
        port.pop("resource", None)

    if not validate_category(tenant_id, service.get('parentServiceId')):
        logging.critical("Unable to validate category. Update your "
                         "servicemanifest with a valid "
                         "parentServiceId that matches a category.")
        exit(1)

    # Update all the imageIds in the service to match the ones in the
    #  instance that you're importing into.
    if len(service.get('images', [])) > 0:
        for image in service['images']:
            image_id = get_image_id(tenant_id, image['name'])
            if image_id:
                image['id'] = image_id
            else:
                logging.warn("Image {} not found. I will create it so "
                             "that the service will import, but it "
                             "will be UNMAPPED. You will have to "
                             "create the worker if necessary and map "
                             "it yourself.".format(image['name']))
                image['id'] = create_image(image, tenant_id)
        # Assume that key defaultImageName was properly inserted into
        # the exported JSON, then use that to get correct Image Id
        # for the default Image.
        service['defaultImageId'] = get_image_id(
            tenant_id,service['defaultImageName'])

    # Create any repositories that are referenced by the service but
    # not yet in the instance.
    if len(service.get('repositories', [])) > 0:
        repo_map = {}
        for repo in service['repositories']:
            old_repo_id = repo['id']
            repo_id = get_repo_id(repo['displayName'])
            if repo_id:
                repo['id'] = repo_id
            else:
                print("Repo {} not found. I will create it so that "
                      "the service will import, but can't promise it "
                      "will be accessible or not.".format(
                    repo['displayName']))
                repo['id'] = create_repo(repo)
            # Create a map of old repo IDs to new ones.
            repo_map["REPO_ID_"+str(old_repo_id)] = "REPO_ID_"+str(
                repo['id'])

        logging.debug(json.dumps(repo_map, indent=2))

        # Dump service dict to json string.
        service_json = json.dumps(service)

        pattern = re.compile('|'.join(repo_map.keys()))

        # This lambda function replaces each of the keys with their
        # values from repo_map in service_json. This is used to
        # replace each of the old repo ID's with the new ones in the
        # service JSON.
        result = pattern.sub(lambda x: repo_map[x.group()],
                             service_json)

        # Load the json string back into a dict, replacing the old
        # service after replacing all the repo ID's
        service = json.loads(result)

    # Assume that key defaultImageName was properly inserted into the
    # exported JSON, then use that to get correct Image Id for the
    # default Image.
    if 'defaultImageName' in service:
        service['defaultImageId'] = get_image_id(tenant_id, service[
            'defaultImageName'])
    else:
        logging.warn("Your manifest file didn't have a defaultImageName key, as it would if"
                     " exported from the instance using this tool. Therefore I'm not able to"
                     " update the image ID to the one that matches your instance, which may"
                     " be different than the one it came from. Funny image related things may happen.")

    # Upload Logo
    if args.logo:
        service['logoPath'] = logo_upload(args.logo)
    else:
        logging.critical("You must specify a logo file for new "
                         "services. Use the -l switch.")
        exit(1)

    logging.debug(json.dumps(service, indent=2))

    if service_id:
        # Service exists. If overwrite flag, then update it.
        logging.info("Service ID: {} for service {} found in the "
                     "CloudCenter instance.".format(service_id,
                                                    service_name))
        if not args.overwrite:
            print("--overwrite not specified. Exiting")
            sys.exit()
        else:
            logging.info("--overwrite specified. Updating existing service.")
            url = baseUrl+"/v1/tenants/"+tenant_id+"/services/"+service_id
            service['id'] = service_id
            response = api_call("PUT", url, data=json.dumps(service))
            logging.debug(json.dumps(response.json(), indent=2))

    else:
        # Service doesn't exist, create it.
        if not args.logo:
            logging.critical("You must specify a logo file for new "
                             "services. Use the -l switch.")
            exit(1)
        logging.info("Service ID for service {} not found. "
                     "Creating".format(service_name))

        url = baseUrl+"/v1/tenants/"+tenant_id+"/services/"
        response = api_call("POST", url, data=json.dumps(service))
        logging.debug(json.dumps(response.json(), indent=2))
        if response.status_code == 201:
            logging.info("Service {} created with Id {}".format(
                service_name, response.json()['id']))
        else:
            logging.critical("Failed to create service.")
            exit(1)


def logo_upload(my_logo_file):
    headers = {
        'accept': "*/*",
        'content-type': None
    }
    params = {
        "type": "logo"
    }
    url = baseUrl + "/v1/file"
    files = {'file': my_logo_file}
    response = api_call("POST", url, files=files, headers=headers,
                        params=params)
    # After uploading the image the response contains a temporary
    # location for the logo which has to be placed into the logo_path
    # for the service. This gets changed behind the scenes
    # automatically to what it should be.
    j = response.json()
    my_logo_path = j['params'][0]['value']
    return my_logo_path


# TODO: Check for existing file and properly use the overwrite flag.


if args.e:
    serviceName = args.e
    filename = "{serviceName}.servicemanifest".format(
        serviceName=serviceName)

    logging.info("Exporting service: {}".format(serviceName))
    svc_manifest = get_service_manifest(serviceName)
    with open(filename, 'w') as f:
        json.dump(svc_manifest, f, indent=4)
    logging.info("Service {} exported to {}".format(serviceName,
                                                    filename))

    # Download logo too
    logo_path = baseUrl + svc_manifest['logoPath']
    logo_file = "{}.png".format(serviceName)
    try:
        logo_response = api_call(method="GET", url=logo_path)
        with open(logo_file, 'wb') as out_file:
            out_file.write(logo_response.content)
        logging.info("Logo downloaded to {}".format(logo_file))

    except Exception as err:
        logging.error("Unable to download logo from {}: {}".format(
            logo_path, err))
        raise

if args.i:
    import_service_json = json.load(args.i)

    import_service(import_service_json)
