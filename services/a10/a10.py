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

def set_cliqr_envars():
    fname = r'/tftpboot/cliqr_envs.txt'
    with open(fname, 'r') as f:
        content = f.readlines()
    content = [x.strip() for x in content]
    env_variables = []
    for item in content:
        env_variables.append(item.split("="))
    for env, value in env_variables:
        os.environ[env] = value
    return True

DEBUG = 'False'
if DEBUG == 'True':
    set_cliqr_envars()
    sys.argv[0] = 'start'   #start, update, stop
    cmd = sys.argv[0]
    print 'Debugging mode using file of static variables'
elif True:
    cmd = sys.argv[1]

A10_MGMT_IP = os.getenv("a10_lb_ip_address")
A10_MGMT_PORT = os.getenv("a10_mgmt_port")
A10_MGMT_USER = os.getenv("a10_username")
A10_MGMT_PASSWD = os.getenv("a10_password")
A10_LB_METHOD = os.getenv("a10_lb_method")   # least-connection, round-robin, etc. Static list already within CloudCenter.
A10_VIP_IP = os.getenv("a10_vip_address")    # VIP service IP, provided by CloudCenter
A10_SERVICE_PORT = os.getenv("a10_vs_port")  # A10 virtual server listener port (aka vport)
A10_REAL_SERVER_PORT = os.getenv("a10_rs_port") # A10 real server listener port

# TODO: Make this an environmental variable. Option are http, https, tcp, etc.
A10_SERVICE_PROTOCOL = os.getenv("a10_vs_protocol", "http")

# TODO: Do we want to ask for tcp or udp? Not sure of udp needed for customers.
A10_REAL_SERVER_PROTOCOL = os.getenv("a10_rp_protocol", "tcp")  # A10_REAL_PROTOCOL (tcp or udp are only choices)

# TODO: Do we want to allow list for available port templates
#A10_PORT_TEMPLATE = os.getenv("a10_port_template") #List from the ADC to make a drop down menu to apply to port

# TODO: Add health checks for real servers
#A10_HEALTH_CHECK = os.getenv("a10_health_check") # Can pull a list from the ADC to make a drop down menu to apply to port


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
    # Create list of dependent service tiers "apache, tomcat, mysql"
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
    print_log(A10_MGMT_IP)
    print_log("Failed to login to A10 API. Check IP, username and password.")
    print_log(err)
    exit(1)

if cmd == "start":
    # Create Service Group to be used and add members
    try:
        sg = ServiceGroup(name=SERVICE_GROUP_NAME, protocol=A10_REAL_SERVER_PROTOCOL, DeviceProxy=dp)
        sg.create()
        print_log("Creating service-group: {}".format(sg.name))
        if sg.ERROR_MSG != "":
            print_log("Failed to create real server.")
            print_log(sg.ERROR_MSG)

    except Exception as err:
        print_log("Exception Occurred: Failed to create service group.")
        print_log(err)

    # Get list of real server IPs in form ['1.2.3.4', '1.2.3.5'], provided from CloudCenter
    CLIQR_SERVER_IP_LIST = __get_reals()

    for rs_ip in CLIQR_SERVER_IP_LIST:
        try:
            server_name = "svr_" + rs_ip
            rs = Server(name=server_name, host=rs_ip, DeviceProxy=dp)
            rs.create()
            print_log("Adding real server: {}".format(rs.name))
            if rs.ERROR_MSG != "":
                print_log("Failed to create real server.")
                print_log(rs.ERROR_MSG)

        except Exception as err:
            print_log("Exception Occurred: Failed to create service group.")
            print_log(err)

        # Add the real port listener with the appropriate health check and port template (if needed).
        #TODO: Add logic to create health check and port template. Will be in next rev.

        rp = ServerPort(port_number=A10_REAL_SERVER_PORT, protocol=A10_REAL_SERVER_PROTOCOL, DeviceProxy=dp)
        rp.create(name=server_name)
        if rp.ERROR_MSG != "":
            print_log("Failed to create real port.")
            print_log(rp.ERROR_MSG)
            exit(1)

        # Add new member to new service group
        # a10_url must use static service-group. a10sdk being updated to fix bug - Dated 28MAR2017 github issue #7.
        a10_url = "/axapi/v3/slb/service-group/" + SERVICE_GROUP_NAME + "/member/{name}+{port}"
        sg_mem = Member(name=server_name, port=A10_REAL_SERVER_PORT, DeviceProxy=dp).update(name=SERVICE_GROUP_NAME)

    # Create new VIP using the newly created service_group
    vs = VirtualServer(name=A10_VIP, ip_address=A10_VIP_IP, DeviceProxy=dp)
    vs.create()
    print_log("Creating service vip {}".format(vs.name))
    if vs.ERROR_MSG != "":
        print_log ("A10_VIP_IP: ")
        print_log("Failed to create virtual server.")
        print_log(vs.ERROR_MSG)
        exit(1)

    # Add a vport to the new VIP with the new service_group
    # Add health monitor or other templates here. Enabling snat_on_vip.
    vs_port = vPort(protocol=A10_SERVICE_PROTOCOL, port_number=A10_SERVICE_PORT, service_group=SERVICE_GROUP_NAME,
                    snat_on_vip=1, DeviceProxy=dp)

    vs_port.create(name=A10_VIP)
    print_log("Adding virtual port for vip service: {}".format(rs.name))

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

    # Populate a list of real servers currently configured in the VIP service_group
    VIP_SG_SLB_SERVER_IP = []
    for item in sg_ml:
        server = Server(DeviceProxy=dp).get(name=item.name).host  # IP Address of server in current pool.
        VIP_SG_SLB_SERVER_IP.append(server)
    Cliqr_ServerIPs = __get_reals()  # List of IPs only.
    # Determine new servers (if any) to add to the service_group
    Servers_To_Add = set(Cliqr_ServerIPs) - set(VIP_SG_SLB_SERVER_IP)
    print_log("Servers_To_Add: {}".format(Servers_To_Add))
    for rs_ip in Servers_To_Add:
        # Just put an 'svr' in front of the IP to get the name.
        rs = Server(name="svr_" + rs_ip, host=rs_ip, DeviceProxy=dp)
        rs.create()
        if rs.ERROR_MSG != "":
            print_log("Failed to add server. Check to see if server exists")
            print_log(rs.ERROR_MSG)

        # TODO: Add health check and port template options for the real server listener port
        # TJ - Need to test none use case
        try:
            rp = ServerPort(port_number=A10_REAL_SERVER_PORT, protocol=A10_REAL_SERVER_PROTOCOL, DeviceProxy=dp)
            print "rs_ip: " , rs_ip
            rp.create(name='svr_' + rs_ip)
            if rp.ERROR_MSG != "":
                print_log("Failed to add server listener port. Check to see if port already exists")
                print_log(rp.ERROR_MSG)
        except Exception as err:
            print_log("Exception Occurred: Failed to update server port.")
            print_log(err)

        try:
            a10_url = "/axapi/v3/slb/service-group/" + SERVICE_GROUP_NAME + "/member/{name}+{port}"
            sg_mem = Member(name='svr_' + rs_ip, port=A10_SERVICE_PORT, DeviceProxy=dp).update(name=SERVICE_GROUP_NAME)
            if sg_mem.ERROR_MSG != "":
                print_log("Failed to add server to the service-group. Check to see if server is already a member or if service-group exists")
                print_log(sg_mem.ERROR_MSG)
        except Exception as err:
            print_log("Exception Occurred: Failed to update service group.")
            print_log(err)

    # Remove server from service_group
    Servers_To_Remove = set(VIP_SG_SLB_SERVER_IP) - set(Cliqr_ServerIPs)
    print_log("Servers_To_Remove: {}".format(Servers_To_Remove))

    for rs_ip in Servers_To_Remove:
        try:
            server_name = "svr_" + rs_ip
            a10_url = "/axapi/v3/slb/service-group/" + vp.service_group + "/member/{name}+{port}"
            sg_mem = Member(name=server_name, port=A10_SERVICE_PORT, a10_url=a10_url,
                                          DeviceProxy=dp).delete(name=server_name, port=A10_SERVICE_PORT)
            if sg_mem.ERROR_MSG != "":
                print_log(
                    "Failed to remove server from the service-group. Check to see if server is a member or if service-group exists")
                print_log(sg_mem.ERROR_MSG)

            # Delete the server
            rs = Server(name=server_name, DeviceProxy=dp).delete(name=server_name)
            print_log("removing member: {}".format(rs.name))
            if rs.ERROR_MSG != "":
                print_log("Failed to remove the servers. Check to see if server(s) exist(s)")
                print_log(rs.ERROR_MSG)
        except Exception as err:
            print_log("Exception Occurred: Failed to remove servers from the service group.")
            print_log(err)


elif cmd == "stop":
    # Get members of service_group before deleting the service-group
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, protocol=A10_REAL_SERVER_PROTOCOL, DeviceProxy=dp).get(name=SERVICE_GROUP_NAME)
    if sg.ERROR_MSG != "":
        print_log("Failed to determine service-group for service vip.")
        print_log(sg.ERROR_MSG)
        #exit(1) - Don't exit, we want to finish clean-up

    # Delete the Virtual Server
    vs = VirtualServer(name=A10_VIP, ip_address=A10_VIP_IP, DeviceProxy=dp).delete(name=A10_VIP)
    print_log("removing service vip: {}".format(vs.name))
    if vs.ERROR_MSG != "":
        print_log("Failed to remove the service vip. Check if vip exists")
        print_log(vs.ERROR_MSG)
        #exit(1) - Don't exit, we want to finish clean-up

    # Delete the servers
    for member in sg.member_list:
        rs = Server(name=member.name, DeviceProxy=dp).delete(name=member.name)
        print_log("removing member: {}".format(member.name))
        if rs.ERROR_MSG != "":
            print_log("Failed to remove the servers. Check to see if server(s) exist(s)")
            print_log(rs.ERROR_MSG)
            #exit(1) - Don't exit, we want to finish clean-up

    # Delete the Service Group
    sg = ServiceGroup(name=SERVICE_GROUP_NAME, DeviceProxy=dp).delete(name=SERVICE_GROUP_NAME)
    print_log("removing service-group: {}".format(sg.name))
    if sg.ERROR_MSG != "":
        print_log("Failed to remove the service-group for service vip. Check to see if service-group exists")
        print_log(sg.ERROR_MSG)
        #exit(1) - Don't exit, we want to finish clean-up
else:
    print_log("Invalid command line argument.")

dp.logoff()
