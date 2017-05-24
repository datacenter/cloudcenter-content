#!/usr/bin/env python

import json
import requests
import os
import random

# Turbonomic login location and credentials.
turbo_ip = "1.2.3.4"
turbo_user = "administrator"
turbo_pass = "vmturbo"
turbo_baseurl = "https://{turbo_ip}/vmturbo/rest".format(
    turbo_ip=turbo_ip
)

# vCenter VM folder to put the VM in - Just the folder itself, not the whole path.
# Not '/path/to/folder', just 'folder'.
deployment_folder = "jobs"

# vCenter folder where the template or VM is that will be cloned from.
# DON'T CHANGE
_clone_from_folder = "CliqrTemplates"

network_list = [
    "apps-201 ()",
    "apps-202 ()",
    "apps-203 ()",
    "apps-204 ()"
]

# Network to deploy the VM into.
# For my purposes I will randomly distribute across 4 equivalent port groups,
# but this could be done other ways as well.
deploy_network = random.choice(network_list)


# Send routine logging messages to CloudCenter UI
def print_log(msg):
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_END")


# Send error messages to CloudCenter UI
def print_error(msg):
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_END")


# Send script output to CloudCenter UI for processing
def print_ext_service_result(msg):
    print("CLIQR_EXTERNAL_SERVICE_RESULT_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_RESULT_END")

    
def get_template_uuid_from_name(name) :
    url = "{turbo_baseurl}/templates".format(turbo_baseurl=turbo_baseurl)
    resp = s.request("GET", url=url, verify=False, auth=(turbo_user, turbo_pass))
    for template in resp.json():
        # print(template.get('displayName', ""))
        template_name = template.get('displayName', "")
        class_name = template.get('className', "")
        if name == template_name and class_name == "VirtualMachineProfile":
            return template.get('uuid')
    # No VirtualMachineProfile with matching name found.
    return None


def create_reservation_from_template(name, template):
    url = "{turbo_baseurl}/reservations".format(turbo_baseurl=turbo_baseurl)
    headers = {
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
    attempts = 5
    for i in range(attempts):
        print("Trying to get a reservation. Attempt {}.".format(i+1))
        resp = s.request("POST", url=url, headers=headers, data=json.dumps(data), verify=False, 
            auth=(turbo_user, turbo_pass))
        reservation = resp.json()
        if reservation['status'] == "PLACEMENT_SUCCEEDED":
            print(reservation)
            return reservation
    print("Failed to get a reservation after {} attempts.".format(attempts))
    return None


def get_market(name):
    url = "{turbo_baseurl}/markets".format(turbo_baseurl=turbo_baseurl)
    resp = s.request("GET", url=url, verify=False, auth=(turbo_user, turbo_pass))
    for market in resp.json():
        # print(template.get('displayName', ""))
        market_name = market.get('displayName', "")
        if name == market_name:
            return market.get('uuid')
    # No VirtualMachineProfile with matching name found.
    return None


def get_cluster_from_host(host):
    market = get_market("Market")  # Get UUID of market.
    url = "{turbo_baseurl}/markets/{market}/entities".format(
        turbo_baseurl=turbo_baseurl,
        market=market
    )
    resp = s.request("GET", url=url, verify=False, auth=(turbo_user, turbo_pass))
    for entity in resp.json():
        entity_name = entity.get('displayName', "")
        class_name = entity.get('className', "")
        if host == entity_name and class_name == "PhysicalMachine":
            for consumer in entity['consumers']:
                if consumer['className'] == 'VirtualDataCenter':
                    name_parts = consumer['displayName'].split("\\")
                    cluster_name = name_parts[1]
                    print(cluster_name)
                    return cluster_name
    return None

   
def get_datacenter_from_host(host):
    market = get_market("Market")  # Get UUID of market.
    url = "{turbo_baseurl}/markets/{market}/entities".format(
        turbo_baseurl=turbo_baseurl,
        market=market
    )
    resp = s.request("GET", url=url, verify=False, auth=(turbo_user, turbo_pass))
    for entity in resp.json():
        entity_name = entity.get('displayName', "")
        class_name = entity.get('className', "")
        if host == entity_name and class_name == "PhysicalMachine":
            for provider in entity['providers']:
                if provider['className'] == 'DataCenter':
                    datacenter_name = provider['displayName']
                    return datacenter_name
    return None


s = requests.Session()

# Get the name of the tier for this VM.
tier_name = os.getenv("eNV_cliqrAppName")

# Get the instance type selected for the deployment of this VM.
cc_instance_type = os.getenv("CliqrTier_{tier_name}_instanceType".format(tier_name=tier_name))

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
suggested_host = reservation['demandEntities'][0]['placements']['computeResources'][0]['provider']['displayName']
suggested_datastore = reservation['demandEntities'][0]['placements']['storageResources'][0]['provider']['displayName']

# Turbonomic provides it's placement down to a specific host, but CloudCenter requires a cluster instead.
suggested_cluster = get_cluster_from_host(suggested_host)
suggested_datacenter = get_datacenter_from_host(suggested_host)

# This dict provides all of the deployment configuration to CloudCenter.
content = {
    # vCenter Datacenter.
    "UserDataCenterName": suggested_datacenter,

    # vCenter cluster.
    "UserClusterName": suggested_cluster,

    # TODO: Test resource pool assignment.
    # Resource Pool.
    # "UserResourcePoolName": "",

    # TODO: Test vm tag list.
    "vmTagsList": "Name:my-vm",

    # Datastore or DS Cluster to deploy to.
    "UserDatastoreCluster": suggested_datastore,

    # vCenter VM folder - Just the folder itself, not the whole path.
    # Not '/path/to/folder', just 'folder'.
    "UserFolderName": deployment_folder,

    # Use strings, not booleans
    "RootDiskResizable": "false",  #
    "FullClone": "true",  #
    "VmRelocationEnabled": "true",  #
    "LocalDataStoreEnabled": "true",  #

    # vCenter Folder where the VM snapshot or template is that will be cloned.
    "SystemFolderName": _clone_from_folder,

    # Port Group. Must be in form "<port group> (<DV Switch>)" If no DV switch, use empty parenthesis.
    # In my case I want to distribute across 4 equivalent port groups.
    "networkList": deploy_network,

    # These values will show up in the UI for the node being created.
    # Value should be a single string, not a nested dict.
    "nodeInfo": "Arbitrary String that shows up in Node Info area on deployment page."
}

print_ext_service_result(json.dumps(content))
