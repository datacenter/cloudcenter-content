#
# Cliqr script to instantiate A10 block
#
#Date: 18MAR2017
# Author:
#     Michael Davis, micdavi3@cisco.com 
#     Terry Jones, tjones@a10networks.com
#

'''
 This script was written to handle the update method of Cliqr. The script will take in the information for the 
  current VIP in service and will add/remove servers from the service_group.

 For any servers being removed, the server needs to bleed off the current connections before being removed.
'''

#*********************************************************************************************************
#UPDATE
#*********************************************************************************************************

#a10sdk classes
from a10sdk.common.device_proxy import DeviceProxy
from a10sdk.core.slb.slb_virtual_server_port import Port
from a10sdk.core.slb.slb_service_group import ServiceGroup
from a10sdk.core.slb.slb_service_group_member import Member
from a10sdk.core.slb.slb_server import Server

#Update with system variables
a10mgmtIP = "192.168.0.153"     # a10mgmtIP=os.environ["a10mgmtIP"]
a10mgmt_port = "80"             # a10mgmt_port=os.environ["a10mgmt_port"]
a10mgmt_login = "admin"         # a10mgmt_login=os.environ["a10mgmt_login"]
a10mgmt_passwd = "a10"          # a10mgmt_passwd=os.environ["a10mgmt_passwd"]

#Need to update to add cert to allow for https call
dp = DeviceProxy(host=a10mgmtIP, port=a10mgmt_port, username=a10mgmt_login, password=a10mgmt_passwd, use_https=False)
print "Session id: ", dp.session_id

#List of servers that are currently configured on Cliqr
Cliqr_ServerIPs = ["10.1.31.2", "10.1.31.13", "10.1.31.14", "10.1.31.15", "10.1.31.20", "10.1.31.21"]
#Cliqr_serverIPs = os.environ["CliqrTier_"+dependencies[0]+"_IP"].split(",")

#Temporary static variable assignments - Import variables from Cliqr
A10_VIP = "WWW_VIP"            # A10_VIP = 'vip'+os.environ["parentJobId"]
A10_Service_Port = "80"        # A10_Service_Port = os.environ["virtual_service_port"]
A10_Service_Protocol = "http"  # A10_Service_Protocol = os.environ["virtual_service_protocol"]

#Get the service_group member_list for the virtual server requested
vp = Port(DeviceProxy=dp).get(name=A10_VIP, port_number=A10_Service_Port, protocol=A10_Service_Protocol)
sg_ml = ServiceGroup(DeviceProxy=dp).get(name=vp.service_group).member_list

#Initalize lists for currently configured servers in the service group on the A10 ADC
List_of_Server_and_IPs = []
List_of_ServerIPs = []

#Populate list of all servers available
List_of_RealServers = Server(DeviceProxy=dp).get()

#Populate  lists of currently configured servers and servers with IPs with the associated VIP
for item in sg_ml:
    server = Server(DeviceProxy=dp).get(name=item.name).host
    i=1
    for i in range(0, 1):
        new=[]
        new.append(server)
        new.append(item.name)
        List_of_ServerIPs.append(server)
        i -= 1
    List_of_Server_and_IPs.append(new)

#Add new servers to the service_group
Servers_To_Add = set(Cliqr_ServerIPs) - set(List_of_ServerIPs)

for index in List_of_Server_and_IPs:
    print "index", index
    for svr in Servers_To_Add:
        for item in List_of_RealServers:
            if item.host == svr:
                print "Server to add: ", item.name
                sg_mem = Member(name=item.name, port=A10_Service_Port, DeviceProxy=dp).update(name=vp.service_group)

#Remove server from service_group
Servers_To_Remove = set(List_of_ServerIPs) - set(Cliqr_ServerIPs)

for index in List_of_Server_and_IPs:
    for svr in Servers_To_Remove:
        if index[0] == svr:
            print "Server to remove: ", index[1]
            a10_url = "/axapi/v3/slb/service-group/" + vp.service_group + "/member/{name}+{port}"
            service_group_member = Member(name=index[1], port=A10_Service_Port, a10_url=a10_url, DeviceProxy=dp)
            service_group_member.delete(name=index[1], port=A10_Service_Port)
               
#Logoff the AxAPI session (required...else admin sessions may fill causing service interruption)

dp.logoff()

print "The End\n"
