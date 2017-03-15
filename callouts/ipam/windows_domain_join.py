# Variables used to detect OS for printing OS specific IPAM options and key injection.
osn = os.environ['eNV_osName']  # uses CloudCenter environment variable to detect OS Type (linux or windows)
winver = os.environ['eNV_imageName']  # detects image name to get windows version so we can inject proper temp windows key

# These variables need to be set to the proper values. IP would need additional logic to get it from somewhere
# unless you're using DHCP.
dns_server = ""
gateway = ""
netmask = ""
hostname = ""
domain = ""
ip = ""


# This is the print(section of the IPAM Callout script after Infoblox/IP list logic.
print("nicCount=1")
print("nicIP_0="+ip)
print("nicDnsServerList_0="+dns_server)
print("nicGateway_0="+gateway)
print("nicNetmask_0="+netmask)
print("osHostname="+hostname)
print("DnsServerList="+dns_server)
print("DnsSuffixList=domain.com")

if osn == "Linux":
    print("domainName="+domain)
    print("timeZone=US/Central")
    print("hwClockUTC=true")

elif winver == "Windows Server 2012":
    print("timeZoneId=20")
    print("fullName=administrator")
    print("organization=MyCompany")
    print("setAdminPassword=Password")
    print("productKey=D2N9P-3P6X9-2R39C-7RTCD-MDVJX")  # This is Windows Temp license key.https://technet.microsoft.com/en-us/library/jj612867(v=ws.11).aspx
    print("changeSid=true")  # Required to launch Windows in vmware
    print("domainName=mydomain.com")  # Required to join Windows to domain
    print("domainAdminName=ADACCOUNT")  # Required to join Windows to domain - this is the user that had proper permissions
    print("domainAdminPassword=Password")  # Required to join Windows to domain

elif winver == "Windows Server 2008":
    print("timeZoneId=20")
    print("fullName=administrator")
    print("organization=MyCompany")
    print("setAdminPassword=Password")
    print("productKey=YC6KT-GKW9T-YTKYR-T4X34-R7VHC")  # This is Windows Temp license key.https://technet.microsoft.com/en-us/library/jj612867(v=ws.11).aspx
    print("changeSid=true")  # Required to launch Windows in vmware
    print("domainName=mydomain.com")  # Required to join Windows to domain
    print("domainAdminName=ADACCOUNT")  # Required to join Windows to domain - this is the user that had proper permissions
    print("domainAdminPassword=Password")  # Required to join Windows to domain