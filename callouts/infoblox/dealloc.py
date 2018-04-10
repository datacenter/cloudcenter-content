#!/home/cliqruser/callouts/bin/python

import argparse
import logging
import requests
import os
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
    format="DEALLOC:%(levelname)s:{job_name}:{vmname}:%(message)s".format(
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
""" End Infoblox Settings"""

ip_addr = os.getenv('nicIP_0')
print(ip_addr)

ib_api_endpoint = "https://{}/wapi/v{}".format(
    ib_hostname, wapi_version)


s = requests.Session()

url = "{}/ipv4address".format(ib_api_endpoint)
print(url)
querystring = {"ip_address": ip_addr}

headers = {}

response = s.request("GET", url, headers=headers, params=querystring,
                     verify=False, auth=(ib_user, ib_pass))

print(response.text)
# Delete every object associated to this IP address.
for obj in response.json()[0]['objects']:
    url = "{}/{}".format(ib_api_endpoint, obj)
    s.request("DELETE", url, verify=False, auth=(ib_user, ib_pass))
