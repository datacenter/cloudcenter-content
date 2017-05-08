#!/usr/bin/env python

from nsnitro import *
import sys
import os


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


# Gather up all the custom parameters
VS_ADDRESS = os.getenv('vipAddress')
VS_PORT = os.getenv('vsPort')
RS_PORT = os.getenv('rsPort')
POOL_LB_METHOD = os.getenv('lbMethod')
deviceIp = os.getenv('deviceIp')
deviceUser = os.getenv('deviceUser')
devicePass = os.getenv('devicePass')
parentJobId = os.getenv('parentJobId')
cliqr_dependencies = os.getenv('CliqrDependencies')

# Set object names unique to job ID
VS_NAME = "cliqr_{parentJobId}_vip".format(parentJobId = parentJobId)
POOL_NAME = "cliqr_{parentJobId}_pool".format(parentJobId = parentJobId)

# Create list of dependent service tiers
dependencies = cliqr_dependencies.split(",")

# Set the new server list from the CliQr environment
serverIps = os.getenv("CliqrTier_"+dependencies[0]+"_PUBLIC_IP").split(",")
serverNodes = os.getenv("CliqrTier_"+dependencies[0]+"_NODE_ID").split(",")
dep_members = zip(serverIps, serverNodes)

nitro = NSNitro(deviceIp, deviceUser, devicePass)
r = nitro.login()

print_log(r)

cmd = sys.argv[1]
if cmd == "start" :

    for member in dep_members:
        NSServer.add(nitro, NSServer({
            "name": member[1],
            "ipaddress": member[0]
        }))

    NSService.add(nitro, NSService({

    }))