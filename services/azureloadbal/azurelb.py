#!/usr/bin/env python
import os.path
import sys
import os
import json
import random
import re
import string
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.storage import StorageManagementClient
from azure.mgmt.compute import ComputeManagementClient
from haikunator import Haikunator
from azure.mgmt.resource.resources.models import DeploymentMode
from requests import Request, Session
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.network import NetworkManagementClient

haikunator = Haikunator()

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
    "us-west" : "westus",
    "us-southcentral" : "southcentralus",
    "us-east" : "eastus"
}

# Set variable from service and custom parameters
client_id = os.environ['CliqrCloud_ClientId']
secret = os.environ['CliqrCloud_ClientKey']
tenant = os.environ['CliqrCloud_TenantId']
account = os.environ['CliqrCloudAccountId']
azureRegion = regionmap[os.environ['region']]

# Resource Group
GROUP_NAME = os.environ['CliqrTier_AppCluster_Cloud_Setting_ResourceGroup']
# Network
VNET_NAME = os.environ['CliqrTier_AppCluster_Cloud_Setting_VirtualNetwork'].split()[1]
SUBNET_NAME = os.environ['CliqrTier_AppCluster_Cloud_Setting_subnetId']
DOMAIN_LABEL_NAME = os.environ['parentJobName']
PUBLIC_IP_NAME = os.environ['parentJobName']+'-publicip'
HEALTH_PROBE_FILE = os.environ['health_probe_file']
#App Cluster - load balanced nodes
APP_CLUSTER_NODES = os.environ['CliqrTier_AppCluster_NODE_ID']
#Subscription
subscription_id = os.environ['CliqrCloudAccountId']

# Load balancer
LB_NAME = os.environ['parentJobName']+'-loadbalancer'
FIP_NAME = os.environ['parentJobName']+'-frontendipname'
ADDRESS_POOL_NAME = os.environ['parentJobName']+'-addr-pool'
PROBE_NAME_80 = os.environ['parentJobName']+'-probe-80'
PROBE_NAME_443 = os.environ['parentJobName']+'-probe-443'
LB_RULE_NAME_80 = os.environ['parentJobName']+'-lb-rule-80'
LB_RULE_NAME_443 = os.environ['parentJobName']+'-lb-rule-443'


credentials = ServicePrincipalCredentials(
    client_id = client_id,
    secret = secret,
    tenant = tenant
)


print_log("Creating ARM client and network client")

network_client = NetworkManagementClient(credentials, subscription_id)
resource_client = ResourceManagementClient(credentials, subscription_id)
compute_client = ComputeManagementClient(credentials, subscription_id)
storage_client = StorageManagementClient(credentials, subscription_id)

#Functions
def construct_fip_id(account):
    return ('/subscriptions/{}'
            '/resourceGroups/{}'
            '/providers/Microsoft.Network'
            '/loadBalancers/{}'
            '/frontendIPConfigurations/{}').format(
                account, GROUP_NAME, LB_NAME, FIP_NAME
            )

def construct_bap_id(account):
    """Build the future BackEndId based on components name.
    """
    return ('/subscriptions/{}'
            '/resourceGroups/{}'
            '/providers/Microsoft.Network'
            '/loadBalancers/{}'
            '/backendAddressPools/{}').format(
                account, GROUP_NAME, LB_NAME, ADDRESS_POOL_NAME
            )

def construct_probe_id(account):
    """Build the future ProbeId based on components name.
    """
    return ('/subscriptions/{}'
            '/resourceGroups/{}'
            '/providers/Microsoft.Network'
            '/loadBalancers/{}'
            '/probes/{}').format(
                account, GROUP_NAME, LB_NAME, PROBE_NAME_80
            )
def create_nic_parameters(subnet_id, address_pool_id):
   """Create the NIC parameters structure.
   """
   return {
       'location': azureRegion,
       'ip_configurations': [{
           'name': IP_CONFIG_NAME,
           'subnet': {
               'id': subnet_id
           },
           'load_balancer_backend_address_pools': [{
               'id': address_pool_id
           }]
       }]
   }



if cmd == "start" :
    print_log("Initiation service start.")

    print_log("Beginning Load Balancer Component Creation...")

    # Create PublicIP
    print_log("Create Public IP")
    public_ip_parameters = {
        'location': azureRegion,
        'public_ip_allocation_method': 'static',
        'dns_settings': {
            'domain_name_label': DOMAIN_LABEL_NAME
        },
        'idle_timeout_in_minutes': 4
    }
    async_publicip_creation = network_client.public_ip_addresses.create_or_update(
        GROUP_NAME,
        PUBLIC_IP_NAME,
        public_ip_parameters
    )
    public_ip_info = async_publicip_creation.result()
    print_log("Created Public IP: " + str(public_ip_info))


    # Building a FrontEndIpPool
    print_log("Create FrontEndIpPool configuration")
    frontend_ip_configurations = [{
        'name': FIP_NAME,
        'private_ip_allocation_method': 'Dynamic',
        'public_ip_address': {
            'id': public_ip_info.id
        }
    }]
    print_log("Created FrontEndIpPool configuration: " + str(public_ip_info.id))


    # Building a BackEnd address pool
    print_log("Create BackEndAddressPool configuration")
    backend_address_pools = [{
        'name': ADDRESS_POOL_NAME
    }]
    print_log("Created BackEndIpPool configuration: " + str(backend_address_pools))

   # Building a HealthProbe
    print_log('Create HealthProbe configuration')
    probes = [{
        'name': PROBE_NAME_80,
        'protocol': 'Http',
        'port': 80,
        'interval_in_seconds': 60,
        'number_of_probes': 60,
        'request_path': HEALTH_PROBE_FILE
    }]


    # Building a LoadBalancer rule
    print_log('Create LoadBalancerRule configuration')
    load_balancing_rules = [{
        'name': LB_RULE_NAME_80,
        'protocol': 'tcp',
        'frontend_port': 80,
        'backend_port': 80,
        'idle_timeout_in_minutes': 4,
        'enable_floating_ip': False,
        'load_distribution': 'Default',
        'frontend_ip_configuration': {
            'id': construct_fip_id(account)
        },
        'backend_address_pool': {
            'id': construct_bap_id(account)
        },
        'probe': {
            'id': construct_probe_id(account)
        }
    }]
  

    # Creating Load Balancer
    print_log("Creating Load Balancer")
    lb_async_creation = network_client.load_balancers.create_or_update(
        GROUP_NAME,
        LB_NAME,
        {
            'location': azureRegion,
            'frontend_ip_configurations': frontend_ip_configurations,
            'backend_address_pools': backend_address_pools,
            'probes': probes,
            'load_balancing_rules': load_balancing_rules,
        }
    )
   
    lb_info = lb_async_creation.result()
    # print_log("Load Balancer Results: " + str(lb_info))
    print_log("Created Load Balancer:")

    # Associating NIC to BackEnd Pool
    print_log("Associating VM NICs to BackEnd Pool")

    # print_log("Testing subnetid :" + SUBNET_NAME)
    # print_log("Testing group name :" + GROUP_NAME)
    # print_log("Testing vnet name :" + VNET_NAME)

    print_log("Get subnet Info")
    async_subnet_get = network_client.subnets.get(
        GROUP_NAME,
        VNET_NAME,
        SUBNET_NAME,
    )


    async_subnet_creation = network_client.subnets.create_or_update(
        GROUP_NAME,
        VNET_NAME,
        SUBNET_NAME,
        {'address_prefix': async_subnet_get.address_prefix}
    )
    subnet_info = async_subnet_creation.result()

    # Iterate through the cluster nodes and add each nic to the backend pool
    get_nodes = APP_CLUSTER_NODES.split(",")
    for node in get_nodes:
        IP_CONFIG_NAME = node + '-ipconfig-0'
        VMS_INFO = {
                1: {
                        'name': node,
                        'nic_name': node + '-nic-0'
                    },
                }
        back_end_address_pool_id = lb_info.backend_address_pools[0].id
        async_nic1_creation = network_client.network_interfaces.create_or_update(
                GROUP_NAME,
                VMS_INFO[1]['nic_name'],
                create_nic_parameters(async_subnet_get.id, back_end_address_pool_id)
                #create_nic_parameters(subnet_info.id, back_end_address_pool_id)
                )

    nic1_info = async_nic1_creation.result()

    print_log("Finished Creating Load Balancer Components")

    print_log("LoadBalancer DNS Name: " + DOMAIN_LABEL_NAME + "." + azureRegion + ".cloudapp.azure.com")

elif cmd == "update" :
# update backend pool with new nic's
    # Updating Load Balancer
    print_log("Updating Load Balancer")

    async_subnet_get = network_client.subnets.get(
        GROUP_NAME,
        VNET_NAME,
        SUBNET_NAME,
    )

    lb_info = network_client.load_balancers.get(
        GROUP_NAME,
        LB_NAME,
    )
   
    # lb_info = lb_async_creation.result()

    #Iterate through the cluster nodes and add each nic to the backend pool
    get_nodes = APP_CLUSTER_NODES.split(",")
    for node in get_nodes:
            IP_CONFIG_NAME = node + '-ipconfig-0'
            VMS_INFO = {
                    1: {
                            'name': node,
                            'nic_name': node + '-nic-0'
                        },
                    }
            back_end_address_pool_id = lb_info.backend_address_pools[0].id
            async_nic1_creation = network_client.network_interfaces.create_or_update(
                    GROUP_NAME,
                    VMS_INFO[1]['nic_name'],
            # create_nic_parameters(subnet_info.id, back_end_address_pool_id)
                    create_nic_parameters(async_subnet_get.id, back_end_address_pool_id)
                    )
            nic1_info = async_nic1_creation.result()

    print_log("Finished updating Load Balancer Components")


elif cmd == "stop" :

    # Destroy the load balancer components

    # Deleting Load Balancer
    print_log("Deleting Load Balancer")
    lb_async_creation = network_client.load_balancers.delete(
        GROUP_NAME,
        LB_NAME,
    )
    lb_info = lb_async_creation.result()
    print_log("Deleted Load Balancer: " + str(lb_info))

    # Delete PublicIP
    print_log("Deleting Public IP")
    public_ip_parameters = {
        'location': azureRegion,
        'public_ip_allocation_method': 'static',
        'dns_settings': {
            'domain_name_label': DOMAIN_LABEL_NAME
        },
        'idle_timeout_in_minutes': 4
    }
    async_publicip_deletion = network_client.public_ip_addresses.delete(
        GROUP_NAME,
        PUBLIC_IP_NAME,
    )
    pubip_info = async_publicip_deletion.result()
    print_log("Deleted Public IP: " + str(pubip_info))


elif cmd == "reload" :
    pass