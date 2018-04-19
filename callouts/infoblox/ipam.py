#!/home/cliqruser/callouts/bin/python

"""
This script is designed for use with CloudCenter callouts.
It is written with VMware in mind, but could also be modified for use
with OpenStack. In particular, this script uses VMware Customization
Specs as one of the available options.

You MUST setup two additional extensible attributes on each network in
Infoblox:
networkId - This must exactly match the networkId passed into this
script from CloudCenter. Check the logs for details.
Gateway - This is the gateway that you use for the network.
"""

import argparse
import logging
import requests
import os
import json
import sys
import netaddr
parser = argparse.ArgumentParser()
log_choices = {
    'critical': logging.CRITICAL,
    'error': logging.ERROR,
    'warning': logging.WARNING,
    'info': logging.INFO,
    'debug': logging.DEBUG
}
parser.add_argument("-l", "--level", help="Set logging level.",
                    choices=log_choices, default='info')

args = parser.parse_args()
parser.parse_args()

log_file = '/usr/local/cliqr/callout/callout.log'
logging.basicConfig(
    filename=log_file,
    format="IPAM:%(levelname)s:{job_name}:{vmname}:%(message)s".format(
        job_name=os.getenv('eNV_parentJobName'),
        vmname=os.getenv('vmName')
    ),
    level=log_choices[args.level]
)
logging.captureWarnings(True)
print("Log file at: {}".format(log_file))

""" Infoblox Settings"""
# Version of Infolbox WAPI to use. Must be >= 1.3.
wapi_version = "2.6"
ib_hostname = "172.16.201.201"
ib_user = "admin"
ib_pass = "infoblox"

""" Settings"""
# Exclude these networks from ipam. Must match the networkId
# env var passed in.
exclude_from_ipam = []  # Ex: ['apps-201', 'apps-202']

domain = "my.domain.com"  # Must match domain configured in Infoblox DNS
dns_server_list = "172.16.1.90,172.16.1.91"
dns_suffix_list = "auslab.cisco.com"
linux_time_zone = "America/Chicago"

# Customization Specs
# Must match names of customization specs in VMWare
linux_cust_spec = None
win2012_cust_spec = None
win2016_cust_spec = None

""" End Settings """


# Pulling in information from env vars
os_type = os.getenv("eNV_osName")
logging.info("eNV_osName: {}".format(os_type))

nic_index = os.getenv("nicIndex")
logging.info("nicIndex: {}".format(nic_index))

hostname = os.getenv('vmName')
logging.info("vmName: {}".format(hostname))

network_id = os.getenv('networkId')
logging.info("networkId: {}".format(network_id))

image_name = os.getenv("eNV_imageName")
logging.info("eNV_imageName: {}".format(image_name))

if image_name == "Windows Server 2016":
    windows_cust_spec = win2016_cust_spec
elif image_name == "Windows Server 2012":
    windows_cust_spec = win2012_cust_spec

if os_type == "Windows" and not windows_cust_spec:
    logging.error("A customization spec is required for Windows"
                  "deployments.")
    exit(1)

if network_id in exclude_from_ipam:
    use_dhcp = True
else:
    use_dhcp = False

logging.info("use_dhcp: {}".format(use_dhcp))

s = requests.Session()

ib_api_endpoint = "https://{}/wapi/v{}".format(ib_hostname, wapi_version)

def get_ip_addr(ref):
    url = "{}/{}".format(ib_api_endpoint, ref)
    logging.debug(url)
    try:
        response = s.request("GET", url, verify=False, auth=(ib_user, ib_pass))
        logging.debug("Response: {}".format(response.text))
    except Exception as err:
        logging.error("Couldn't create host record: {0}.".format(err))
        sys.exit(1)

    return response.json()['ipv4addrs'][0]['ipv4addr']


def allocate_ip():
    # Get network reference
    url = "{}/network".format(ib_api_endpoint)
    querystring = {
        "*networkId": network_id,
        "_return_fields": "extattrs,network"
    }
    headers = {}
    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=(ib_user, ib_pass))
    if len(response.json()) != 1:
        logging.error("Must have exactly one network in Infoblox with "
                      "extensible attribute networkId matching network "
                      "{}. Found {} instead.".format(
                        network_id, len(response.json())
                        ))
        exit(1)
    gateway = response.json()[0]['extattrs']['Gateway']['value']
    subnet = response.json()[0]['network']
    netmask = str(netaddr.IPNetwork(subnet).netmask)

    # Create Host Record
    url = "{}/record:host".format(ib_api_endpoint)
    fqdn = "{hostname}nic{idx}.{domain}".format(hostname=hostname, idx=nic_index, domain=domain)
    payload = {
        "ipv4addrs": [
            {
                "ipv4addr": "func:nextavailableip:{subnet}".format(subnet=subnet)
            }
        ],
        "name": fqdn,
        "configure_for_dns": True
    }
    headers = {'content-type': "application/json"}
    try:
        response = s.request("POST", url, data=json.dumps(payload), headers=headers, verify=False,
                             auth=(ib_user, ib_pass))
        logging.debug("Response: {}".format(response.text))
        logging.debug(response.status_code)
        response.raise_for_status()
        host_ref = response.json()
    except Exception as err:
        logging.debug("Response: {}".format(response.text))
        logging.error("Couldn't create host record: {0}.".format(err))
        sys.exit(1)

    new_ip = get_ip_addr(host_ref)
    logging.info("Allocated IP: {}".format(new_ip))

    return {
        "ip": new_ip,
        "netmask": netmask,
        "gateway": gateway
    }


# Echo key/values back to CloudCenter for VM creation
print("nicCount=1")
print("osHostname="+hostname)

print("nicUseDhcp_0={}".format(use_dhcp))
if not use_dhcp:
    ip = allocate_ip()
    print("DnsServerList="+dns_server_list)
    print("DnsSuffixList={}".format(dns_suffix_list))
    print("nicIP_0={}".format(ip['ip']))
    print("nicNetmask_0={}".format(ip['netmask']))
    print("nicGateway_0={}".format(ip['gateway']))
    print("nicDnsServerList_0={}".format(dns_server_list))  # Optional

# VMWare Specific
if os_type == "Windows":
    logging.info("Using Customization Spec: {}".
                 format(windows_cust_spec))
    print("custSpec=" + windows_cust_spec)
elif os_type == "Linux":
    if linux_cust_spec:
        print("custSpec=" + linux_cust_spec)
    else:
        print("domainName={}".format(domain))
        print("hwClockUTC=true")
        print("timeZone={}".format(linux_time_zone))
else:
    print("Unrecognized OS Type")
    sys.exit(1)
