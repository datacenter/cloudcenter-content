#!/usr/bin/env python
import os
import json

# Provided inputs, among many others. See /usr/local/osmosix/callout/<ipam folder>/logs/<files> for more info.
vpcId = os.getenv("vpcId", None)
subnetId = os.getenv("subnetId", None)
networkId = os.getenv("networkId", None)
networkName = os.getenv("networkName", None)
os_type = os.getenv("vmOSName")
nicCount = int(os.getenv("numNICs"))
# nic_info = json.loads(os.getenv("nicInfo"))

useDhcp = False  # VMware customization spec to use if you want.

# OpenStack Specific

# VMWare Specific
if os_type is "Windows":
    custSpec = None  # VMware customization spec to use if you want.
    if custSpec:
        print("custSpec="+custSpec)
    else:
        joinDomain = False  # Or true if you want to join a Windows Domain. Then put domain admin creds below.
        # OpenStack specific
        print("portId=asdf")
        # Windows Specific
        print("domainAdminName=asdf")
        print("domainAdminPassword=afd")
        print("workgroup=workgroup")
        print("organization=CliQr")
        print("productKey=D2N9P-3P6X9-2R39C-7RTCD-MDVJX")
        # print("licenseAutoMode=")
        # print("licenseAutoModeUsers=")
        print("setAdminPassword=p@ssw0rd")
        # print("dynamicPropertyName=")
        # print("dynamicPropertyValue=")
        # print("changeSid=true")
        print("deleteAccounts=false")
        print("timeZoneId=004")
elif os_type is "Linux":
    if custSpec:
        pass
    else:
        print("DnsSuffixList=cisco.com")
        print("nicDnsServerList=asdf")
        print("domainName=sacliqr.local")
        print("hwClockUTC=true")
        print("timeZone=America/Los_Angeles")
        print("osHostname=asdf")
else:
    print("Unrecognized OS Type")
    exit(1)

# Indexed to each NIC
# Mock Up. In real life you have to get a valid IP from somewhere, or use DHCP.
for i in range(0, nicCount):
    print("nicUseDhcp_{}={}".format(i, useDhcp))
    if not useDhcp:
        print("nicIP_{nicNo}=192.100.0.9{nicNo}".format(nicNo=i))
        print("nicNetmask_{}=255.255.255.0".format(i))
        print("DnsServerList_{}=171.70.168.183".format(i))
        print("nicGateway_{}=192.100.0.2".format(i))



