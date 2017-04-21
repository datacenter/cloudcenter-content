#!/usr/bin/env python
# For use with newer version of the WAPI that include the next_available function in the create_host method.
# Known NOT to work with 1.0 of the WAPI

import infoblox  # Use this 3rd party library for convenience.
import os
import requests

requests.packages.urllib3.disable_warnings()


# Assign command line arguments to named variables
hostname = os.environ['vmName']  # The VM name should come from CloudCenter. Use the name of the VM as the OS hostname
domain = "test.com"
fqdn = "{}.{}".format(hostname, domain)
network = "10.110.1.0/24"
netmask = "255.255.255.0"
gateway = "10.110.1.1"
dns_server = "10.100.1.15"

# Setup connection object for Infoblox
iba_api = infoblox.Infoblox('10.110.1.45', 'admin', 'infoblox', '1.6', 'default', 'default', False)

try:
    # Create new host record with supplied network and fqdn arguments
    ip = iba_api.create_host_record(network, fqdn)
    print "nicCount=1"
    print "nicIP_0=" + ip
    print "DnsServerList="+dns_server
    print "nicGateway_0="+gateway
    print "nicNetmask_0="+netmask
    print "domainName="+domain
    print "hwClockUTC=true"
    print "timeZone=Canada/Eastern"
    print "osHostname="+hostname
except Exception as e:
    print e
