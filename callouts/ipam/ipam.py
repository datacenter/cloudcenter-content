#!/usr/bin/env python
import os

# Provided inputs, among many others. See /usr/local/osmosix/callout/<ipam folder>/logs/<files> for more info.
vpcId = os.genenv("vpcId", None)
subnetId = os.genenv("subnetId", None)
networkId = os.genenv("networkId", None)
networkName = os.genenv("networkName", None)


# OpenStack Specific
print("portId=")

# VMWare Specific
print("custSpec=")


print("DnsServerList=")
print("DnsSuffixList=")
print("nicIP=")
print("nicDnsServerList=")
print("nicGateway=")
print("nicNetmask=")
print("nicUseDhcp=")
print("domainName=")
print("hwClockUTC=")
print("timeZone=")
print("osHostname=")


# Windows Specific
print("domainAdminName=")
print("domainAdminPassword=")
print("workgroup=")
print("deleteAccounts=")
print("timeZoneId=")
print("organization=")
print("productKey=")
print("licenseAutoMode=")
print("licenseAutoModeUsers=")
print("setAdminPassword=")
print("dynamicPropertyName=")
print("dynamicPropertyValue=")


