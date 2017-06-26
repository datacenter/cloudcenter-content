#!/usr/bin/env python
import sys
import os
from a10sdk.common.device_proxy import DeviceProxy
from a10sdk.core.slb.slb_virtual_server import VirtualServer
from a10sdk.core.slb.slb_server_port import Port as ServerPort
from a10sdk.core.slb.slb_virtual_server_port import Port as vPort
from a10sdk.core.slb.slb_service_group import ServiceGroup
from a10sdk.core.slb.slb_service_group_member import Member
from a10sdk.core.slb.slb_server import Server

cmd = sys.argv[1]

A10_MGMT_IP = os.getenv("a10_lb_ip_address")
A10_MGMT_PORT = os.getenv("a10mgmt_port", "8080")
# A10_MGMT_PROTOCOL = os.getenv("a10proto")
A10_MGMT_USER = os.getenv("a10_username", "admin")
A10_MGMT_PASSWD = os.getenv("a10_password", "a10")
a10_lb_method = os.getenv("a10_lb_method")
A10_VIP_IP = os.getenv("a10_vip_address") # Need to figure out where to get this IP from.
A10_SERVICE_PORT = os.getenv("a10_vs_port")
A10_REAL_SERVER_PORT = os.getenv("a10_rs_port", "80")
PORT_TEMPLATE = "GRACEFUL_SHUTDOWN_10MIN"  # Can pull a list from the ADC to make a drop down menu to apply to port
A10_SERVICE_PROTOCOL = "http"  # A10_SERVICE_PROTOCOL = os.environ["virtual_service_protocol"]
A10_REAL_PROTOCOL = "tcp"      # A10_REAL_PROTOCOL (tcp or udp only)
HEALTH_CHECK = "HM-HTTP"       # Can pull a list from the ADC to make a drop down menu to apply to port


def print_log(msg):
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_END")


def print_error(msg):
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_END")


def print_ext_service_result(msg):
    print("CLIQR_EXTERNAL_SERVICE_RESULT_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_RESULT_END")


def __get_reals():
    # Create list of dependent service tiers
    dependencies = os.environ["CliqrDependencies"].split(",")
    # NOTE: THIS SCRIPT ONLY SUPPORTS THE FIRST DEPENDENT TIER!!!
    dep_tier_count = len(dependencies)
    if dep_tier_count != 1:
        raise Exception("This service supports exactly one dependent tier. You have {}: {}".format(dep_tier_count,
                                                                                                   dependencies))
    # Set the new server list from the CliQr environment
    # Return list like ['1.2.3.4', '1.2.3.5']
    return os.environ["CliqrTier_" + dependencies[0] + "_IP"].split(",")

# TODO: Figure out more unique way to get pool and vip names.
SERVICE_GROUP_NAME = 'pool' + os.environ['parentJobId']
A10_VIP = 'vip' + os.environ['parentJobId']

# Need to update to add cert to allow for https call
try:
    dp = DeviceProxy(host=A10_MGMT_IP, port=A10_MGMT_PORT, username=A10_MGMT_USER, password=A10_MGMT_PASSWD,
                     use_https=False)
except Exception as err:
    print_log("Failed to login to A10 API. Check IP, username and password.")
    print_log(err)
    exit(1)

if cmd == "start":

    '''
    This section of code will instantiate a new VIP service. All input will be pulled from Cliqr lists
    '''
    # Need to update to add cert to allow for https call
    # dp = DeviceProxy(host=A10_MGMT_IP, port=A10_MGMT_PORT, username=A10_MGMT_USER, password=A10_MGMT_PASSWD,
    #                  use_https=False)

    # Can delete and replace with Cliqr provided list. List name is VIP_SG_SLB_SERVER_IP_W_IPS. Need to ensure
    # how list is presented by Cliqr matches planned list (2d list - [ [ A,ip1], [B,ip2] ] ) else code needs to be
    # updated to accomodate the type of struct provided.

    # for i in range(1,6):
    #     for j in range (0,1):
    #         new=[]
    #         new.append("s_NEW_PYTHON_SRVR0"+str(i))
    #         NEW_REAL_SERVER_NAMES.append("s_NEW_PYTHON_SRVR0"+str(i))
    #         new.append("10.1.31.3"+str(i))
    #     VIP_SG_SLB_SERVER_IP_W_IPS.append(new)

    # Create Service Group to be used and add members
    try:
        sg = ServiceGroup(name=SERVICE_GROUP_NAME, protocol=A10_REAL_PROTOCOL, DeviceProxy=dp)
        sg.create()
    except Exception as err:
        print_log("Failed to create service group. Check IP, username and password.")
        print_log(err)
        exit(1)


    # Get list of Real Servers already configured on the ADC
    # ADC_REAL_SERVERS = Server(DeviceProxy=dp).get()
    # for item in NEW_REAL_SERVER_NAMES:
    #     if item not in ADC_REAL_SERVERS:
    #         # Add new servers from Cliqr list to the ADC (slb servers)
    #         for lst in VIP_SG_SLB_SERVER_IP_W_IPS:
    #             if item == lst[0]:
    #                 rs = Server(name=item, host=lst[1], DeviceProxy=dp)
    #                 rs.create()
    #

    # Just a simple list of IPs like ['1.2.3.4', '1,2,3,5']
    VIP_SG_SLB_SERVER_IP_W_IPS = __get_reals()
    for rs_ip in VIP_SG_SLB_SERVER_IP_W_IPS:
        server_name = "s"+rs_ip
        # Just put an 's' in front of the IP to get the name.
        rs = Server(name=server_name, host=rs_ip, DeviceProxy=dp)
        rs.create()
        if rs.ERROR_MSG != "":
            print_log("Failed to create real server.")
            print_log(rs.ERROR_MSG)
            exit(1)

        # Add the real port listener with the appropriate health check and port template (if needed).
        # TJ - Need to test none use case
        # TODO: Add logic to create health check and port template.
        # rp = ServerPort(port_number=A10_REAL_SERVER_PORT, protocol=A10_REAL_PROTOCOL, health_check=HEALTH_CHECK,
        #                 template_port=PORT_TEMPLATE, DeviceProxy=dp)
        rp = ServerPort(port_number=A10_REAL_SERVER_PORT, protocol=A10_REAL_PROTOCOL, DeviceProxy=dp)
        rp.create(name=server_name)
        if rp.ERROR_MSG != "":
            print_log("Failed to create real port.")
            print_log(rp.ERROR_MSG)
            exit(1)

        # Add new member to new service group
        # a10_url must use static service-group. a10sdk being updated to fix issue - Dated 28MAR2017 issue #7.
        a10_url = "/axapi/v3/slb/service-group/" + SERVICE_GROUP_NAME + "/member/{name}+{port}"
        sg_mem = Member(name=server_name, port=A10_REAL_SERVER_PORT, DeviceProxy=dp).update(name=SERVICE_GROUP_NAME)

    # Create new VIP using the newly created service_group
    vs = VirtualServer(name=A10_VIP, ip_address=A10_VIP_IP, DeviceProxy=dp)
    vs.create()
    if vs.ERROR_MSG != "":
        print_log("Failed to create virtual server.")
        print_log(vs.ERROR_MSG)
        exit(1)

    # Add a vport to the new VIP with the new service_group
    # We can easily add health monitor or other templates here. Enabling snat_on_vip. Snat pool not available
    # Entering fix issue on github for a10sdk - 29MAR2017

    vs_port = vPort(protocol=A10_SERVICE_PROTOCOL, port_number=A10_SERVICE_PORT, service_group=SERVICE_GROUP_NAME,
                   snat_on_vip=1, DeviceProxy=dp)
    vs_port.create(name=A10_VIP)
    if vs_port.ERROR_MSG != "":
        print_log("Failed to create virtual port.")
        print_log(vs_port.ERROR_MSG)
        exit(1)


elif cmd == "update":
    '''
    This section is meant to read in the list of servers configured on Cliqr and ensure the A10 ADC add/removes the
    real servers to match. 
    '''

    # Get the service_group member_list for the virtual server requested
    vp = vPort(DeviceProxy=dp).get(name=A10_VIP, port_number=A10_SERVICE_PORT, protocol=A10_SERVICE_PROTOCOL)
    sg_ml = ServiceGroup(DeviceProxy=dp).get(name=vp.service_group).member_list

    # Populate list of all servers available
    ADC_SLB_SERVERS = Server(DeviceProxy=dp).get()

    # Populate lists of currently configured servers and servers with IPs with the associated VIP service_group
    VIP_SG_SLB_SERVER_IP = []
    for item in sg_ml:
        server = Server(DeviceProxy=dp).get(name=item.name).host  # IP Address of server in current pool.
        VIP_SG_SLB_SERVER_IP.append(server)
        # i = 1
        # for i in range(0, 1):
        #     new_list = []
        #     new_list.append(server)
        #     new_list.append(item.name)
        #     VIP_SG_SLB_SERVER_IP.append(server)
        #     i -= 1
        # VIP_SG_SLB_SERVER_IP_W_IPS.append(new_list)  # List of servers in the current pool.

    Cliqr_ServerIPs = __get_reals()  # List of IPs only.
    # Add new servers to the service_group
    Servers_To_Add = set(Cliqr_ServerIPs) - set(VIP_SG_SLB_SERVER_IP)
    print_log("Servers_To_Add: {}".format(Servers_To_Add))
    for rs_ip in Servers_To_Add:
        # Just put an 's' in front of the IP to get the name.
        rs = Server(name="s"+rs_ip, host=rs_ip, DeviceProxy=dp)
        rs.create()

        # Add the real port listener with the appropriate health check and port template (if needed).
        # TJ - Need to test none use case
        rp = ServerPort(port_number=A10_REAL_SERVER_PORT, protocol=A10_REAL_PROTOCOL, health_check=HEALTH_CHECK,
                  template_port=PORT_TEMPLATE, DeviceProxy=dp)
        rp.create(name=rs_ip)
        sg_mem = Member(name="s"+rs_ip, port=A10_SERVICE_PORT, DeviceProxy=dp).update(name=vp.service_group)

        # for item in ADC_SLB_SERVERS:
        #     print_log("item.host: {}, svr: {}".format(item.host, svr))
        #     if item.host == svr:
        #         print_log("match!! {} == {}".format(item.host, svr))

    # Remove server from service_group
    Servers_To_Remove = set(VIP_SG_SLB_SERVER_IP) - set(Cliqr_ServerIPs)
    print_log("Servers_To_Remove: {}".format(Servers_To_Remove))

    for rs_ip in Servers_To_Remove:
        name = "s"+rs_ip
        a10_url = "/axapi/v3/slb/service-group/" + vp.service_group + "/member/{name}+{port}"
        service_group_member = Member(name=name, port=A10_SERVICE_PORT, a10_url=a10_url,
                                      DeviceProxy=dp).delete(name=name, port=A10_SERVICE_PORT)
        # TODO: Add code to remove the server from the LB, not just the service group.

    # for index in VIP_SG_SLB_SERVER_IP_W_IPS:
    #     for svr in Servers_To_Remove:
    #         if index[0] == svr:




elif cmd == "stop":
    # Get members of service_group before deleting it
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, protocol=A10_REAL_PROTOCOL, DeviceProxy=dp).get(name=SERVICE_GROUP_NAME)

    # Delete the Virtual Server
    vs = VirtualServer(name=A10_VIP, ip_address=A10_VIP_IP, DeviceProxy=dp).delete(name=A10_VIP)

    # Delete the servers
    for member in sg.member_list:
        rs = Server(name=member.name, DeviceProxy=dp).delete(name=member.name)
        print_log("member: {}".format(member.name))

    # Delete the Service Group
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, DeviceProxy=dp).delete(name=SERVICE_GROUP_NAME)


else:
    print_log("Invalid command line argument.")

dp.logoff()

