#!/usr/bin/env python
import os.path
import sys
import pdb
import os.path
import json
from haikunator import Haikunator
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.resource.resources.models import DeploymentMode

cmd = sys.argv[1]

my_subscription_id = os.environ.get('AZURE_SUBSCRIPTION_ID')   # your Azure Subscription Id
my_resource_group = os.environ['resourceGroupName']            # the resource group for deployment
my_pub_ssh_key_path = '~/.ssh/id_rsa.pub'   # the path to your rsa public key file

deployer = Deployer(my_subscription_id, my_resource_group, my_pub_ssh_key_path)

if cmd == "start" :
    credentials = ServicePrincipalCredentials(
        client_id=os.environ['CliqrCloud_ClientId'],
        secret=os.environ['CliqrCloud_ClientKey'],
        tenant=os.environ['CliqrCloud_TenantId']
    )


    msg = "\nInitializing the Deployer class with subscription id: {}, resource group: {}" \
        "\nand public key located at: {}...\n\n"
    msg = msg.format(my_subscription_id, my_resource_group, my_pub_ssh_key_path)
    print(msg)

    client = ResourceManagementClient(credentials, os.environ['CliqrCloudAccountId'])

    print("Beginning the deployment... \n\n")
    
    # Dict that maps keys of CloudCenter's region names to values of Azures region names.
    # Used below to control where something is deployed
    regionmap = {
        "us-west" : "westus",
        "us-southcentral" : "southcentralus"
    }
    client.resource_groups.create_or_update(
        my_resource_group,
        {
            'location': regionmap[os.environ['region']]
        }
    )

    template_path = os.environ['armTemplate']

    parameters = {
        'AppSettingClientID': os.environ['CliqrCloud_ClientId'],
        'AppSettingClientSecret': os.environ['CliqrCloud_ClientKey']
    }
    parameters = {k: {'value': v} for k, v in parameters.items()}

    deployment_properties = {
        'mode': DeploymentMode.incremental,
        'template': template,
        'parameters': parameters
    }

    deployment_async_operation = client.deployments.create_or_update(
        my_resource_group,
        'azure-sample',
        deployment_properties
    )
    deployment_async_operation.wait()

    print("Done deploying!!\n\nYou can connect via: `ssh azureSample@{}.westus.cloudapp.azure.com`".format(deployer.dns_label_prefix))
elif cmd == "stop" :
    # pass
    # Destroy the resource group which contains the deployment
    deployer.destroy()
elif cmd == "reload" :
    pass