#!/usr/bin/env python
import os.path
import sys
import pdb
import os.path
import json
import random
#from haikunator import Haikunator
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.resource.resources.models import DeploymentMode
from azure.mgmt.network import NetworkManagementClient

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

my_subscription_id = os.environ.get('AZURE_SUBSCRIPTION_ID') # your Azure Subscription Id
my_resource_group = os.environ['parentJobName']+os.environ['parentJobId'] # the resource group for deployment
print("Resource Group: {}".format(my_resource_group))
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


    print("Beginning the deployment... \n\n")

    # Dict that maps keys of CloudCenter's region names to values of Azure's region names.
    # Used below to control where something is deployed
    regionmap = {
        "us-west" : "westus",
        "us-southcentral" : "southcentralus",
        "us-east" : "eastus"
    }
    client.resource_groups.create_or_update(
        my_resource_group,
        {
            'location': regionmap[os.environ['region']]
        }
    )

    with open('template.json', 'r') as template_file_fd:
        template = json.load(template_file_fd)

    # with open('parameters.json', 'r') as armparams_file_fd:
    #     parameters = json.load(armparams_file_fd)
    serverName = "server-"+os.environ['parentJobName'].replace('_', '-')
    parameters = {
        "parameters": {
            "serverAdminPassword": {
                "value": os.environ['dbSAPassword']
            },
            "serverAdminUsername": {
                "value": os.environ['cliqrDatabaseRootUserName']
            },
            "server_name": {
                "value": serverName
            },
            "databases_name": {
                "value": os.environ['dbName']
            }
        }
    }

    deployment_properties = {
        'mode': DeploymentMode.incremental,
        'template': template,
        'parameters': parameters['parameters']
    }

    deployment_async_operation = client.deployments.create_or_update(
        my_resource_group,
        'azure-sample',
        deployment_properties
    )
    deployment_async_operation.wait()

    result = {
        'hostName': serverName+"database.windows.net",
        'ipAddress': serverName+"database.windows.net",
        'environment': {
            'instanceName': "instanceName",
            'instanceType': "instanceType",
            'serviceType': "serviceType",
            'productType': "productType",
            'status': "status",
            'port': "port",
            'version': "version"
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