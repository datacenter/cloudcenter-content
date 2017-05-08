# #!/usr/bin/env python
#
# Cliqr script to instantiate A10 block
#
#Date: 29MAR2017
# Author:
#     Michael Davis, micdavi3@cisco.com
#     Terry Jones, tjones@a10networks.com
#

import sys
import os
from a10sdk.common.device_proxy import DeviceProxy
from a10sdk.core.slb.slb_virtual_server import VirtualServer
from a10sdk.core.slb.slb_virtual_server_port import Port
from a10sdk.core.slb.slb_service_group import ServiceGroup
from a10sdk.core.slb.slb_service_group_member import Member
from a10sdk.core.slb.slb_server import Server

#Update with system variables
A10_MGMT_IP = "192.168.0.153"     # A10_MGMT_IP=os.environ["A10_MGMT_IP"]
A10_MGMT_PORT = "80"             # A10_MGMT_PORT=os.environ["A10_MGMT_PORT"]
A10_MGMT_USER = "admin"         # A10_MGMT_USER=os.environ["A10_MGMT_USER"]
A10_MGMT_PASSWD = "a10"          # A10_MGMT_PASSWD=os.environ["A10_MGMT_PASSWD"]

#Create list of dependent service tiers
#TJ - What does the response output look like? List of ...?
#dependencies = os.environ["CliqrDependencies"].split(",")
###NOTE: THIS SCRIPT ONLY SUPPORTS THE FIRST DEPENDENT TIER!!!

#Set the new server list from the CliQr environment
#Cliqr_ServerIPs = os.environ["CliqrTier_"+dependencies[0]+"_IP"].split(",")
Cliqr_ServerIPs = ["10.1.31.1", "10.1.31.2", "10.1.31.14", "10.1.31.32", "10.1.31.33", "10.1.31.34"]

#Static variable assignments - Import variables from Cliqr
A10_VIP = "WWW_VIP2"           # A10_VIP = 'vip'+os.environ["parentJobId"]
A10_VIP_IP = "1.1.1.19"        # A10_VIP_IP = os.environ["virtual_server_ip"]
A10_SERVICE_PROTOCOL = "http"  # A10_SERVICE_PROTOCOL = os.environ["virtual_service_protocol"]
A10_SERVICE_PORT = "80"        # A10_SERVICE_PORT = os.environ["virtual_service_port"]
A10_REAL_SERVER_PORT = "80"    # A10_REAL_SERVER_PORT = os.evviron["virtual_service_port"]
NEW_REAL_SERVER_NAMES = []     # List from Cliqr? List of Server names for real servers being add to service group
VIP_SG_SLB_SERVER_IP = []        # List from Cliqr? List of IP's for real servers being added to service group
A10_REAL_PROTOCOL = "tcp"      # A10_REAL_PROTOCOL (tcp or udp only)
HEALTH_CHECK = "HM-HTTP"       # Can pull a list from the ADC to make a drop down menu to apply to port
PORT_TEMPLATE = "GRACEFUL_SHUTDOWN_10MIN"  #Can pull a list from the ADC to make a drop down menu to apply to port
SERVICE_GROUP_NAME="sg_New"    #We can auto generate a name
VIP_SG_SLB_SERVER_IP_W_IPS= []       #A list of lists containing Servers and IP's.

#Get method from system
#cmd = sys.argv[1]
cmd = raw_input("Enter start, update or stop\n")
print "You entered ", cmd

if cmd == "start":

    '''
    This section of code will instantiate a new VIP service. All input will be pulled from Cliqr lists
    '''
    #Need to update to add cert to allow for https call
    dp = DeviceProxy(host=A10_MGMT_IP, port=A10_MGMT_PORT, username=A10_MGMT_USER, password=A10_MGMT_PASSWD,
                     use_https=False)

    #Can delete and replace with Cliqr provided list. List name is VIP_SG_SLB_SERVER_IP_W_IPS. Need to ensure how list is
    #presented by Cliqr matches planned list (2d list - [ [ A,ip1], [B,ip2] ] ) else code needs to be updated to
    #accomodate the type of struct provided.
    
    for i in range(1,6):
        for j in range (0,1):
            new=[]
            new.append("s_NEW_PYTHON_SRVR0"+str(i))
            NEW_REAL_SERVER_NAMES.append("s_NEW_PYTHON_SRVR0"+str(i))
            new.append("10.1.31.3"+str(i))
        VIP_SG_SLB_SERVER_IP_W_IPS.append(new)


    #Get list of Real Servers already configured on the ADC
    ADC_REAL_SERVERS = Server(DeviceProxy=dp).get()

    #Create Service Group to be used and add members
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, protocol=A10_REAL_PROTOCOL, DeviceProxy=dp)
    sg.create()

    for item in NEW_REAL_SERVER_NAMES:
        if item not in ADC_REAL_SERVERS:
            #Add new servers from Cliqr list to the ADC (slb servers)
            for lst in VIP_SG_SLB_SERVER_IP_W_IPS:
                if item == lst[0]:
                    rs = Server(name=item, host=lst[1], DeviceProxy=dp)
                    rs.create()

            #Add the real port listener with the appropriate health check and port template (if needed).
            #TJ - Need to test none use case
            rp = Port(port_number=A10_REAL_SERVER_PORT, protocol=A10_REAL_PROTOCOL, health_check=HEALTH_CHECK,
                      template_port=PORT_TEMPLATE, DeviceProxy=dp)
            rp.create(name=item)

            #Add new member to new service group
            #a10_url must use static service-group. a10sdk being updated to fix issue - Dated 28MAR2017 issue #7.
            a10_url = "/axapi/v3/slb/service-group/" + SERVICE_GROUP_NAME + "/member/{name}+{port}"
            sg_mem = Member(name=item, port=A10_REAL_SERVER_PORT, DeviceProxy=dp).update(name=SERVICE_GROUP_NAME)

    #Create new VIP using the newly created service_group
    vs = VirtualServer(name=A10_VIP, ip_address=A10_VIP_IP, DeviceProxy=dp)
    vs.create()

    #Add a vport to the new VIP with the new service_group
    #We can easily add health monitor or other templates here. Enabling snat_on_vip. Snat pool not available
    #Entering fix issue on github for a10sdk - 29MAR2017

    vs_port = Port(protocol=A10_SERVICE_PROTOCOL, port_number=A10_SERVICE_PORT, service_group=SERVICE_GROUP_NAME,
                   snat_on_vip=1, DeviceProxy=dp)
    vs_port.create(name=A10_VIP)

    dp.logoff()

elif cmd == "update":
    '''
    This section is meant to read in the list of servers configured on Cliqr and ensure the A10 ADC add/removes the
    real servers to match. 
    '''

    #Need to update to add cert to allow for https call
    dp = DeviceProxy(host=A10_MGMT_IP, port=A10_MGMT_PORT, username=A10_MGMT_USER, password=A10_MGMT_PASSWD,
                     use_https=False)

    #Get the service_group member_list for the virtual server requested
    vp = Port(DeviceProxy=dp).get(name=A10_VIP, port_number=A10_SERVICE_PORT, protocol=A10_SERVICE_PROTOCOL)
    sg_ml = ServiceGroup(DeviceProxy=dp).get(name=vp.service_group).member_list

    #Populate list of all servers available
    ADC_SLB_SERVERS = Server(DeviceProxy=dp).get()

    #Populate lists of currently configured servers and servers with IPs with the associated VIP service_group
    for item in sg_ml:
        server = Server(DeviceProxy=dp).get(name=item.name).host
        i = 1
        for i in range(0, 1):
            new_list = []
            new_list.append(server)
            new_list.append(item.name)
            VIP_SG_SLB_SERVER_IP.append(server)
            i -= 1
        VIP_SG_SLB_SERVER_IP_W_IPS.append(new_list)

    #Add new servers to the service_group
    Servers_To_Add = set(Cliqr_ServerIPs) - set(VIP_SG_SLB_SERVER_IP)
    print "Servers_To_Add", Servers_To_Add
    for svr in Servers_To_Add:
        for item in ADC_SLB_SERVERS:
            print "item.host     :", item.host, "svr   :", svr
            if item.host == svr:
                print "match!!", item.host, "==", svr
                sg_mem = Member(name=item.name, port=A10_SERVICE_PORT, DeviceProxy=dp).update(name=vp.service_group)

    #Remove server from service_group
    Servers_To_Remove = set(VIP_SG_SLB_SERVER_IP) - set(Cliqr_ServerIPs)
    for index in VIP_SG_SLB_SERVER_IP_W_IPS:
        for svr in Servers_To_Remove:
            if index[0] == svr:
                a10_url = "/axapi/v3/slb/service-group/" + vp.service_group + "/member/{name}+{port}"
                service_group_member = Member(name=index[1], port=A10_SERVICE_PORT, a10_url=a10_url,
                                              DeviceProxy=dp).delete(name=index[1], port=A10_SERVICE_PORT)


    dp.logoff()

elif cmd == "stop":

    #Need to update to add cert to allow for https call
    dp = DeviceProxy(host=A10_MGMT_IP, port=A10_MGMT_PORT, username=A10_MGMT_USER, password=A10_MGMT_PASSWD,
                     use_https=False)

    #Get members of service_group before deleting it
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, protocol=A10_REAL_PROTOCOL, DeviceProxy=dp).get(name=SERVICE_GROUP_NAME)

    #Delete the Virtual Server
    vs = VirtualServer(name=A10_VIP, ip_address=A10_VIP_IP, DeviceProxy=dp).delete(name=A10_VIP)

    #Delete the servers
    for member in sg.member_list:
        rs = Server(name=member.name, DeviceProxy=dp).delete(name=member.name)
        print "member: ", member.name

    #Delete the Service Group
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, DeviceProxy=dp).delete(name=SERVICE_GROUP_NAME)

    dp.logoff()

elif True:
    print "Mis-type"
