#!/usr/bin/env python

# More verbose

import requests
import os
import json
requests.packages.urllib3.disable_warnings()

hostname = os.getenv('vmName')
domain = "cliqrdemo"
fqdn = hostname + "." + domain
network = os.getenv('networkName')
netmask = "255.255.255.0"
gateway = "10.110.5.1"
dns_server_list = "10.100.1.15,8.8.8.8"

#Get network reference
url = "https://10.110.5.254/wapi/v1.0/network"
querystring = {"*VLAN": network}
headers = {}
response = requests.request("GET", url, headers=headers, params=querystring, verify=False, auth=('admin', 'infoblox'))
netRef = response.json()[0]['_ref']


#Get next available IP address
url = "https://10.110.5.254/wapi/v1.0/"+netRef
querystring = {
    "_function":"next_available_ip",
    "num":"1"
}
headers = {}
response = requests.request("POST", url, headers=headers, params=querystring, verify=False, auth=('admin', 'infoblox'))
ip = response.json()['ips'][0]

#Create Host Record
url = "https://10.110.5.254/wapi/v1.0/record:host"
payload = {
    "ipv4addrs":[
        {
            "ipv4addr":ip
        }
    ],
    "name": fqdn,
    "configure_for_dns": True
}
headers = {'content-type': "application/json"}
response = requests.request("POST", url, data=json.dumps(payload), headers=headers, verify=False, auth=('admin', 'infoblox'))

#Echo key/values back to CloudCenter for VM creation
print "nicCount=1"
print "nicIP_0=" + ip
print "nicUseDhcp_0=false"
print "DnsServerList="+dns_server_list
print "nicGateway_0="+gateway
print "nicNetmask_0="+netmask
print "domainName="+domain
print "hwClockUTC=true"
print "timeZone=Canada/Eastern"
print "osHostname="+hostname
print "infobloxRef="+response.json()
