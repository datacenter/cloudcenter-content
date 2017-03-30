#!/usr/bin/env python
# import acos_client as acos
import sys
import os
from a10sdk.common.device_proxy import DeviceProxy
from a10sdk.core.slb.slb_virtual_server import VirtualServer
from a10sdk.core.slb.slb_virtual_server_port import Port
from a10sdk.core.slb.slb_service_group import ServiceGroup
from a10sdk.core.slb.slb_service_group_member import Member
from a10sdk.core.slb.slb_server import Server


cmd = sys.argv[1]

a10mgmtIP = os.getenv("a10_lb_ip_address")
a10mgmt_port = os.getenv("a10mgmt_port")
a10proto = os.getenv("a10proto")
a10mgmt_login = os.getenv("a10_username")
a10mgmt_passwd = os.getenv("a10_password")
a10_lb_method = os.getenv("a10_lb_method")
a10_vip_address = os.getenv("a10_vip_address")
a10_vs_port = os.getenv("a10_vs_port")
a10_rs_port = os.getenv("a10_rs_port")

# Create list of dependent service tiers
dependencies = os.environ["CliqrDependencies"].split(",")
# NOTE: THIS SCRIPT ONLY SUPPORTS THE FIRST DEPENDENT TIER!!!


# Set the new server list from the CliQr environment
serverIps = os.environ["CliqrTier_" + dependencies[0] + "_IP"].split(",")

pool = 'pool' + os.environ['parentJobId']
vip = 'vip' + os.environ['parentJobId']
# healthMonitor = 'hm'+os.environ['parentJobId']

dp = DeviceProxy(host=a10mgmtIP, port=a10mgmt_port, username=a10mgmt_login, password=a10mgmt_passwd, use_https=False)


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


if cmd == "start":
    # Make a list out of the IP addresses of the web server tier.
    print_log(serverIps)

    # Create pool and add to VIP.
    # c.slb.service_group.create(pool, c.slb.service_group.TCP, c.slb.service_group.ROUND_ROBIN)

    # Create and apply a health check for the pool
    # c.slb.hm.create(healthMonitor, c.slb.hm.HTTP, 5, 5, 5, 'GET', '/', '200', 80)

    # Apply a ping health-check to pool
    # c.slb.service_group.update(pool, health_monitor=ping)

    # Add each web server IP as a real server, then add it to the pool.
    for server_ip in serverIps:
        serverName = 's' + server_ip
        # c.slb.server.create(serverName, server_ip)
        # c.slb.service_group.member.create(pool, serverName, 80)

        rs = Server(name=serverName, host=server_ip, DeviceProxy=dp)
        rs.create()

        port_name = "http_port"
        rp = Port(port_number=a10_rs_port, protocol="tcp", DeviceProxy=dp)
        rp.create(name=port_name)

    # Create a new service group
    sg = ServiceGroup(name=pool, protocol="tcp", DeviceProxy=dp)
    sg.create()

    # Create new VIP with new sg
    vs = VirtualServer(name="NEW_PYTHON_VIP_01", ip_address="1.1.1.1", DeviceProxy=dp)
    vs.create()

    # Create a VIP
    # c.slb.virtual_server.create(vip, a10mgmtIP)
    # Add a vport to the new VIP
    vs_port = Port(protocol="http", port_number=a10_vs_port, service_group="sg_NEW_PYTHON_SERVICE_GROUP", DeviceProxy=dp)
    vs_port.create(name="NEW_PYTHON_VIP_01")


elif cmd == "update":
    # All these next ten lines just to get the current running LB pool

    # Initialize an empty list as the current pool
    currPool = {}
    # Get all the members in the current pool from API
    r = c.slb.service_group.get(pool)

    # Add each member's IP address to the current pool list.
    for member in r['service_group']['member_list']:
        # Get a reference to this server.
        s = c.slb.server.get(member['server'])

        ip = str(s['server']['host'])
        name = str(s['server']['name'])

        # Convert the server's IP (host) to str, then add to current pool list.
        currPool[ip] = name

    ################

    # For each server in the new serverIps, add it to addServers if it's not in the current pool
    addServers = [server_ip for server_ip in serverIps if server_ip not in currPool.keys()]

    # For each server in the currPool, add it to removeServers if it's not in serverIps
    removeServers = [server_ip for server_ip in currPool.keys() if server_ip not in serverIps]

    for server_ip in addServers:
        serverName = 's' + server_ip
        c.slb.server.create(serverName, server_ip)
        c.slb.service_group.member.create(pool, serverName, 80)

    for server_ip in removeServers:
        c.slb.server.delete(currPool[server_ip])

elif cmd == "stop":
    c.slb.virtual_server.delete(vip)
    c.slb.service_group.delete(pool)

    for server_ip in serverIps:
        serverName = 's' + server_ip
        c.slb.server.delete(serverName)
