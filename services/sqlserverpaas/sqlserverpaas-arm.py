#!/usr/bin/env python
import os.path
import sys
import pdb
import os.path
import json
import random
import pyodbc
import dns.resolver
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

# Dict that maps keys of CloudCenter's region names to values of Azure's region names.
# Used below to control where something is deployed
regionmap = {
    "us-west": "westus",
    "us-southcentral": "southcentralus",
    "us-east": "eastus"
}

# Set variable from service and custom parameters
client_id = os.environ['CliqrCloud_ClientId']
secret = os.environ['CliqrCloud_ClientKey']
tenant = os.environ['CliqrCloud_TenantId']
subscriptionId = os.environ['CliqrCloudAccountId']
azureRegion = regionmap[os.environ['region']]
rootPass = os.environ['cliqrDatabaseRootPass']
rootUser = os.environ['cliqrDatabaseRootUserName']
masterDB = "master"
serverName = "server-"+os.environ['currentTierJobId'].replace('_', '-') # Replase _ with - because _ not allowed in server name. Use current tier to ensure uniqueness when multiple are present in app profile.
my_resource_group = os.environ['parentJobName']+os.environ['parentJobId'] # the resource group for deployment. Set from job name/id to make it identifiable and unique per deployment.
port = "1433"
# my_subscription_id = os.environ.get('AZURE_SUBSCRIPTION_ID') # your Azure Subscription Id


print_log("Resource Group: {}".format(my_resource_group))

credentials = ServicePrincipalCredentials(
    client_id=client_id,
    secret=secret,
    tenant=tenant
)

print_log("Creating ARM client and network client")
client = ResourceManagementClient(credentials, subscriptionId)
network_client = NetworkManagementClient(credentials, subscriptionId)

if cmd == "start":
    print_log("Initiation service start.")

    print_log("Beginning the deployment...")

    client.resource_groups.create_or_update(
        my_resource_group,
        {
            'location': azureRegion
        }
    )
    try:
        print_log("Trying to open template downloaded to: template.json")
        with open('template.json', 'r') as template_file_fd:
            template = json.load(template_file_fd)
    except Exception as err:
        print_log("Error opening template: {0}.".format(err))
        sys.exit(1)

    print_log("SQL Server name set to: {0}.".format(serverName))

    parameters = {
        "parameters": {
            "serverAdminPassword": {
                "value": rootPass
            },
            "serverAdminUsername": {
                "value": rootUser
            },
            "server_name": {
                "value": serverName
            }
        }
    }

    deployment_properties = {
        'mode': DeploymentMode.incremental,
        'template': template,
        'parameters': parameters['parameters']
    }

    try:
        print_log("Trying to deploy database server to resource group {}.".format(my_resource_group))
        deployment_async_operation = client.deployments.create_or_update(
            my_resource_group,
            'azure-sample',
            deployment_properties
        )
        deployment_async_operation.wait()
    except Exception as err:
        print_log("Error deploying database: {0}.".format(err))
        sys.exit(1)

    if 'cliqrDBSetupScript' in os.environ and len(os.environ['cliqrDBSetupScript']) > 0:
        print_log("Specified DB Setup Script downloaded to: {}. Running it...".format(os.environ['cliqrDBSetupScript']))
        try:
            cnxn = pyodbc.connect(
                "Driver={driver};Server=tcp:{serverName}.database.windows.net,{port};Database={masterDB};Uid={rootUser}@{serverName};Pwd={rootPass};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;".format(
                    serverName=serverName,
                    masterDB=masterDB,
                    rootUser=rootUser,
                    rootPass=rootPass,
                    driver="ODBC Driver 13 for SQL Server",
                    port=port
                ),
                autocommit=True
            )
            cursor = cnxn.cursor()
            with open(os.environ['cliqrDBSetupScript'], 'r') as dbScript:
                cursor.execute(dbScript.read())
        except Exception as err:
            print_log("Error running DB Setup Scrip: {0}.".format(err))
            sys.exit(1)
    domainName = serverName+".database.windows.net"
    answer = dns.resolver.query(domainName)
    ipAddr = str(answer[0].to_text())
    result = {
        'hostName': domainName,
        'ipAddress': ipAddr,
        'environment': {
            'instanceName': "instanceName",
            'instanceType': "instanceType",
            'serviceType': "serviceType",
            'productType': "productType",
            'status': "status",
            'port': port,
            'version': "version"
        }
    }

    print_log(json.dumps(result))
    print_ext_service_result(json.dumps(result))

    print_log("Done deploying!")
elif cmd == "stop":
    # pass
    # Destroy the resource group which contains the deployment
    try:
        print_log("Trying to delete the resource group: {0}.".format(my_resource_group))
        client.resource_groups.delete(my_resource_group)
    except Exception as err:
        print_log("Error deleting the resource group: {0}.".format(err))
        sys.exit(1)
    print_log("Resource Group {} deleted".format(my_resource_group))
elif cmd == "reload":
    pass
