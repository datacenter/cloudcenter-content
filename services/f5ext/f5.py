#!/usr/bin/env python
import os
import sys
import bigsuds

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


cmd = sys.argv[1]

# Gather up all the custom parameters
VS_ADDRESS = os.environ['vipAddress']
VS_PORT = os.environ['vsPort']
RS_PORT = os.environ['rsPort']
POOL_LB_METHOD = os.environ['lbMethod']
BIGIP_ADDRESS = os.environ['bigIPAddress']
VS_NAME = "cliqr_" + os.environ['parentJobId'] + "_vip"
POOL_NAME = "cliqr_" + os.environ['parentJobId'] + "_pool"
username = os.environ['bigIPusername']
password = os.environ['bigIPpassword']
iRules = os.getenv("f5ext_iRules", None)

# Create list of dependent service tiers
dependencies = os.environ["CliqrDependencies"].split(",")

# If there are no dependency tiers, then there won't be anything in the
# pool, so just exit.
if len(dependencies) == 0:
    print("There aren't any dependency tiers, so nothing to create."
          "Check your app topology.")
    sys.exit(0)

# Set the new server list from the CliQr environment
serverIps = []
for dep in dependencies:
    serverIps.extend(os.environ["CliqrTier_" + dep + "_IP"].split(","))

pool = 'pool' + os.environ['parentJobId']
vip = 'vip' + os.environ['parentJobId']
b = bigsuds.BIGIP(
    hostname=BIGIP_ADDRESS,
    username=username,
    password=password,
    port=8443  # TODO: Parametarize
)

if cmd == "start":
    members = []
    for member in serverIps:
        members.append({
            'address': member,
            'port': RS_PORT
        })

    b.LocalLB.Pool.create_v2([POOL_NAME], [POOL_LB_METHOD], [members])
    b.LocalLB.VirtualServer.create([{
        'name': VS_NAME,
        'address': VS_ADDRESS,
        'port': VS_PORT,
        'protocol': 'PROTOCOL_TCP'
    }],
        ['255.255.255.255'],
        [{
            'type': 'RESOURCE_TYPE_POOL',
            'default_pool_name': POOL_NAME
        }], [[{}]])
    if iRules:
        b.LocalLB.VirtualServer.add_rule([VS_NAME], [[iRules]])

elif cmd == "reload":
    # Get all the members in the current pool from API
    r = b.LocalLB.Pool.get_member(['/Common/' + POOL_NAME])[0]

    # addServers = [server for server in serverIps if server not in
    # currPool.keys() ]
    addServers = []
    for ip in serverIps:
        if not any(x['address'] == ip for x in r):
            addServers.append(ip)

    # For each server in the currPool, add it to addServers if it's
    # not in serverIps.
    removeServers = []
    for server in r:
        if server['address'] not in serverIps:
            removeServers.append(server)

    for member in addServers:
        b.LocalLB.Pool.add_member_v2(
            ['/Common/' + POOL_NAME],
            [[{'port': RS_PORT,
               'address': member}]]
        )

    b.LocalLB.Pool.remove_member(
        ['/Common/' + POOL_NAME],
        [removeServers]
    )
    for server in removeServers:
        b.LocalLB.NodeAddressV2.delete_node_address([server['address']])

elif cmd == "stop":
    r = b.LocalLB.Pool.get_member(['/Common/' + POOL_NAME])[0]
    currIpsInPool = []
    for server in r:
        currIpsInPool.append(server['address'])

    b.LocalLB.VirtualServer.delete_virtual_server(['/Common/' + VS_NAME])
    b.LocalLB.Pool.delete_pool(['/Common/' + POOL_NAME])
    b.LocalLB.NodeAddressV2.delete_node_address(currIpsInPool)
