#!/usr/bin/env python
import os

# Provided inputs, among many others. See /usr/local/osmosix/callout/<ipam folder>/logs/<files> for more info.
vpcId = os.getenv("vpcId", None)
subnetId = os.getenv("subnetId", None)
networkId = os.getenv("networkId", None)
networkName = os.getenv("networkName", None)
nicCount = os.getenv("nicCount")

custSpec = None  # VMware customization spec to use if you want.
useDhcp = False  # VMware customization spec to use if you want.
joinDomain = False  # Or true if you want to join a Windows Domain. Then put domain admin creds below.

# OpenStack Specific
print("portId=")

# VMWare Specific
if custSpec:
    print("custSpec="+custSpec)
else:
    # Windows Specific
    if joinDomain:
        print("domainAdminName=")
        print("domainAdminPassword=")
    else:
        print("workgroup=workgroup")

    print("deleteAccounts=false")
    print("timeZoneId=004")
    print("organization=CliQr")
    print("productKey=D2N9P-3P6X9-2R39C-7RTCD-MDVJX")
    # print("licenseAutoMode=")
    # print("licenseAutoModeUsers=")
    print("setAdminPassword=p@ssw0rd")
    # print("dynamicPropertyName=")
    # print("dynamicPropertyValue=")



print("DnsSuffixList=")
print("nicDnsServerList=")
print("domainName=")
print("hwClockUTC=")
print("timeZone=")
print("osHostname=")

# Indexed to each NIC
for i in range(0..nicCount):
    print("nicUseDhcp_{}={}".format(i, useDhcp))
    if not useDhcp:
        print("nicIP_{}=192.100.0.81".format(i))
        print("nicNetmask_{}=255.255.255.0".format(i))
        print("DnsServerList_{}=171.70.168.183".format(i))
        print("nicGateway_{}=192.100.0.2".format(i))



