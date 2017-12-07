#!/usr/bin/env python

import json
import requests
import os
import random
import time
print("Turbonomic placement script version 1.1")

# Turbonomic login location and credentials.

s = requests.Session()

url = "http://172.16.204.243:8200/v1/secret/turbonomic"

headers = {
    'x-vault-token': "cc649599-7611-96d0-0a70-689552e6ff8b",
}

response = s.request("GET", url, headers=headers)

turbo_user = response.json()['data']['username']
turbo_pass = response.json()['data']['password']


turbo_ip = "172.16.202.242"
turbo_baseurl = "https://{turbo_ip}/vmturbo/rest".format(
    turbo_ip = turbo_ip
)

# vCenter VM folder to put the VM in - Just the folder itself, not the whole path.
# Not '/path/to/folder', just 'folder'.
deployment_folder = "jobs"

# vCenter folder where the template or VM is that will be cloned from.
# DON'T CHANGE
_clone_from_folder = "CliqrTemplates"


# Send script output to CloudCenter UI for processing
def print_ext_service_result(msg):
    print("CLIQR_EXTERNAL_SERVICE_RESULT_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_RESULT_END")


def get_template_uuid_from_name(name):
    my_template = None
    my_url = "{turbo_baseurl}/templates".format(turbo_baseurl=turbo_baseurl)
    resp = s.request("GET", url=my_url, verify=False, auth=(turbo_user, turbo_pass))
    # TODO: Use filter instead.
    for template in resp.json():
        template_name = template.get('displayName', "")
        class_name = template.get('className', "")
        if name == template_name and class_name == "VirtualMachineProfile":
            my_template = template.get('uuid')

    return my_template


def create_reservation_from_template(name, template):
    my_url = "{turbo_baseurl}/reservations".format(turbo_baseurl=turbo_baseurl)
    my_headers = {
        "Content-Type": "application/json"
    }
    data = {
        "demandName": name,
        "action": "PLACEMENT",
        "parameters": [
            {
                "placementParameters": {
                    "count": 1,
                    "templateID": template
                }
            }
        ]
    }
    resp = s.request("POST", url=my_url, headers=my_headers, data=json.dumps(data), verify=False,
                     auth=(turbo_user, turbo_pass))
    res = resp.json()
    print(json.dumps(res, indent=2))
    if res['status'] != "PLACEMENT_SUCCEEDED":
        res = None
    return res


def get_host_info(host_uuid):
    my_url = "{turbo_baseurl}/search/{entity}".format(
        turbo_baseurl=turbo_baseurl,
        entity=host_uuid
    )
    resp = s.request("GET", url=my_url, verify=False, auth=(turbo_user, turbo_pass))
    j = resp.json()
    json.dumps(j, indent=2)
    p = j['providers']
    datacenter = list(filter(lambda x: x['className'] == 'DataCenter', p))[0]
    cluster = list(filter(lambda x: x['className'] == 'VirtualDataCenter', p))[0]
    return {'datacenter': datacenter, 'cluster': cluster}


s = requests.Session()

# Get the name of the tier for this VM.
tier_name = os.getenv("eNV_cliqrAppName")

# Get the instance type selected for the deployment of this VM.
cc_instance_type = os.getenv("CliqrTier_{tier_name}_instanceType".format(tier_name=tier_name), "medium")

# Get the UUID of the Turbonomic template that matches the CloudCenter instance type used for this deployment.
deploy_template_uuid = get_template_uuid_from_name(cc_instance_type)
if not deploy_template_uuid:
    raise Exception("Couldn't find the template named {} in Turbonomic. Please add it.".format(cc_instance_type))
print("Deploy Template: {}, {}".format(cc_instance_type, deploy_template_uuid))

# Create a reservation for this VM using the Turbonomic template.
reservation = create_reservation_from_template(name="test1", template=deploy_template_uuid)
if not reservation:
    raise Exception("Placement failed.")

# Grab the relevant pieces of information from the reservation for use by CloudCenter
suggested_host = reservation['demandEntities'][0]['placements']['computeResources'][0]['provider']
suggested_datastore = reservation['demandEntities'][0]['placements']['storageResources'][0]['provider']

host_info = get_host_info(suggested_host['uuid'])
suggested_datacenter = host_info['datacenter']['displayName']
suggested_cluster = host_info['cluster']['displayName'].split('\\')[1]

# For my purposes I will randomly distribute across 4 equivalent port groups,
# but this could be done other ways as well.
network_list = [
    "apps-203 ()"
]

# This dict provides all of the deployment configuration to CloudCenter.
content = {
    # vCenter Datacenter.
    "UserDataCenterName": suggested_datacenter,

    # vCenter cluster.
    "UserClusterName": suggested_cluster,

    # Resource Pool.
    # "UserResourcePoolName": "",

    #
    "vmTagsList": "Name:my-vm",

    # Datastore or DS Cluster to deploy to.
    "UserDatastoreCluster": suggested_datastore['displayName'],

    # vCenter VM folder - Just the folder itself, not the whole path.
    # Not '/path/to/folder', just 'folder'.
    "UserFolderName": deployment_folder,

    # Use strings, not booleans
    "RootDiskResizable": "false",  #
    "FullClone": "false",  #
    "VmRelocationEnabled": "true",  #
    "LocalDataStoreEnabled": "true",  #

    # vCenter Folder where the VM snapshot or template is that will be cloned.
    "SystemFolderName": _clone_from_folder,

    # Port Group. Must be in form "<port group> (<DV Switch>)" If no DV switch, use empty parenthesis.
    # In my case I want to distribute across 4 equivalent port groups.
    "networkList": random.choice(network_list),
    "UserHost": suggested_host['displayName'],  # Removed for testing

    # These values will show up in the UI for the node being created.
    # Value should be a single string, not a nested dict.
    "nodeInfo": "Arbitrary String that shows up in Node Info area on deployment page."
}

print_ext_service_result(json.dumps(content))
