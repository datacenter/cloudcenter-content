#!/usr/bin/env python

from nsnitro import *
import os

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

#Set object names unique to job ID
VS_NAME = "cliqr_{parentJobId}_vip".format(parentJobId = parentJobId)
POOL_NAME = "cliqr_{parentJobId}_pool".format(parentJobId = parentJobId)

#Create list of dependent service tiers
dependencies = cliqr_dependencies.split(",")

#Set the new server list from the CliQr environment
serverIps = os.getenv["CliqrTier_"+dependencies[0]+"_PUBLIC_IP"].split(",")
serverNodes = os.getenv["CliqrTier_"+dependencies[0]+"_NODE_ID"].split(",")
dep_members = zip(serverIps, serverNodes)

nitro = NSNitro(deviceIp, deviceUser, devicePass)
r = nitro.login()

print r

if cmd == "start" :

    for member in dep_members:
        NSServer.add(nitro, NSServer({
            "name": member[1],
            "ipaddress": member[0]
        }))

    NSService.add(nitro, NSService({

    }))