#!/usr/bin/env python
import os.path
import sys
import pdb
import os.path
import json
#from haikunator import Haikunator
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.network import NetworkManagementClient
from msrestazure.azure_exceptions import CloudError
from azure.mgmt.resource.resources.models import DeploymentMode

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


cmd = sys.argv[1]

my_subscription_id = os.environ.get('AZURE_SUBSCRIPTION_ID')   # your Azure Subscription Id
my_resource_group = os.environ['parentJobName']+os.environ['parentJobId']            # the resource group for deployment
#my_pub_ssh_key_path = '~/.ssh/id_rsa.pub'   # the path to your rsa public key file

#deployer = Deployer(my_subscription_id, my_resource_group, my_pub_ssh_key_path)

credentials = ServicePrincipalCredentials(
    client_id=os.environ['CliqrCloud_ClientId'],
    secret=os.environ['CliqrCloud_ClientKey'],
    tenant=os.environ['CliqrCloud_TenantId']
)


# msg = "\nInitializing the Deployer class with subscription id: {}, resource group: {}" \
#     "\nand public key located at: {}...\n\n"
# msg = msg.format(my_subscription_id, my_resource_group, my_pub_ssh_key_path)
# print(msg)

client = ResourceManagementClient(credentials, os.environ['CliqrCloudAccountId'])
network_client = NetworkManagementClient(credentials, os.environ['CliqrCloudAccountId'])

if cmd == "start" :


    print_log("Beginning the deployment...")
    
    # Dict that maps keys of CloudCenter's region names to values of Azure's region names.
    # Used below to control where something is deployed
    regionmap = {
        "us-west" : "westus",
        "us-southcentral" : "southcentralus",
        "us-east" : "eastus"
    }
    rg = client.resource_groups.create_or_update(
        my_resource_group,
        {
            'location': regionmap[os.environ['region']]
        }
    )
    try:
        with open(os.environ['armTemplate'], 'r') as template_file_fd:
            template = json.load(template_file_fd)
    except Exception as err:
        print_log("Error loading the ARM Template: {0}. Check your syntax".format(err))
        sys.exit(1)

    try:
        with open(os.environ['armParamsFile'], 'r') as armparams_file_fd:
            parameters = json.load(armparams_file_fd)
    except Exception as err:
        print_log("Error loading the ARM Parameters File: {0}. Check your syntax".format(err))
        sys.exit(1)


    deployment_properties = {
        'mode': DeploymentMode.incremental,
        'template': template,
        'parameters': parameters['parameters']
    }
    try:
        deployment_async_operation = client.deployments.create_or_update(
            my_resource_group,
            'azure-sample',
            deployment_properties
        )
        deployment_async_operation.wait()
    except CloudError as err:
        print_log("CloudError: {0}".format(err))
        sys.exit(1)
    except Exception as err:
        print_log("Exception: {0}".format(err))
        sys.exit(1)
    
    for item in client.resource_groups.list_resources(my_resource_group):
        print_log(item)
    
    ipAddr = ""
    for item in network_client.public_ip_addresses.list(my_resource_group):
        ipAddr = item.ip_address
        print_log("IP Address: {}".format(item.ip_address))

    result = {
        'hostName': "hostname",
        'ipAddress': ipAddr,
        'environment': {
            'myEnv': "testEnv"
        }
    }

    print_ext_service_result(json.dumps(result))
    #print("Done deploying!!\n\nYou can connect via: `ssh azureSample@{}.westus.cloudapp.azure.com`".format(deployer.dns_label_prefix))
    print("Done deploying!")
elif cmd == "stop" :
    # pass
    # Destroy the resource group which contains the deployment
    client.resource_groups.delete(my_resource_group)
    print("Resource Group {} deleted".format(my_resource_group))
elif cmd == "reload" :
    pass