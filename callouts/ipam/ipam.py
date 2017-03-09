#!/usr/bin/env python
import os

# Provided inputs, among many others. See /usr/local/osmosix/callout/<ipam folder>/logs/<files> for more info.
vpc_id = os.getenv("vpcId", None)
subnet_id = os.getenv("subnetId", None)
network_id = os.getenv("networkId", None)
network_name = os.getenv("networkName", None)
os_type = os.getenv("vmOSName")
nic_count = int(os.getenv("numNICs"))

if subnet_id == "mdavis-200-no-dhcp (DVS-LAB164)":
    use_dhcp = False  # VMware customization spec to use if you want.
else:
    use_dhcp = True  # VMware customization spec to use if you want.

windows_cust_spec = None
linux_cust_spec = None

# OpenStack Specific

# VMWare Specific
if os_type == "Windows":
    if windows_cust_spec:
        print("custSpec=" + windows_cust_spec)
    else:
        joinDomain = False  # Or true if you want to join a Windows Domain. Then put domain admin creds below.
        print("portId=asdf")  # OpenStack specific
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
elif os_type == "Linux":
    if linux_cust_spec:
        print("custSpec=" + linux_cust_spec)
    else:
        print("DnsSuffixList=cisco.com")
        print("domainName=mdavis.local")
        print("hwClockUTC=true")
        print("timeZone=America/Los_Angeles")
        print("osHostname=asdf")
else:
    print("Unrecognized OS Type")
    exit(1)


print("DnsServerList=192.100.0.84")  # Optional
print("DnsSuffixList=mdavis.local")  # Optional
print("nicCount=" + str(nic_count))  # Required

# For IP settings, this script will be run for each NIC.
# Always use _0 as output for the output of nic-specific settings.

print("nicUseDhcp_0={}".format(use_dhcp))
if not use_dhcp:
    # Mock Up. In real life you have to get a valid IP from somewhere, or use DHCP.
    print("nicIP_0=192.100.0.90")
    print("nicNetmask_0=255.255.0.0")
    print("nicGateway_0=192.100.0.2")
    print("nicDnsServerList_0=192.100.0.84")  # Optional
