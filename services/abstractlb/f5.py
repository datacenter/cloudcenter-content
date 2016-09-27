#!/usr/bin/env python
import os
import sys
import requests
import json
import datetime
import bigsuds 
requests.packages.urllib3.disable_warnings()

def print_ext_service_result():
	#content="$@"
	print "CLIQR_EXTERNAL_SERVICE_RESULT_START"
	#print "$content"
	print "{\"hostName\": \"test\", \"ipAddress\": \"192.168.1.8\"}"
	print "CLIQR_EXTERNAL_SERVICE_RESULT_END"


def print_error():
	#content="$@"
	print "CLIQR_EXTERNAL_SERVICE_ERR_MSG_START"
	#print "$content"
	print "CLIQR_EXTERNAL_SERVICE_ERR_MSG_END"

cmd = sys.argv[1]

# Gather up all the custom parameters
VS_ADDRESS = os.environ['vipAddress']
VS_PORT = os.environ['vsPort']
RS_PORT = os.environ['rsPort']
POOL_LB_METHOD = os.environ['lbMethod']
BIGIP_ADDRESS = os.environ['bigIPAddress']
username = os.environ['bigIPusername']
password = os.environ['bigIPpassword']

#Set object names unique to job ID
VS_NAME = "cliqr_"+os.environ['parentJobId']+"_vip"
POOL_NAME = "cliqr_"+os.environ['parentJobId']+"_pool"

#Create list of dependent service tiers
dependencies = os.environ["CliqrDependencies"].split(",")

#Set the new server list from the CliQr environment
serverIps = os.environ["CliqrTier_"+dependencies[0]+"_PUBLIC_IP"].split(",")

b = bigsuds.BIGIP(hostname = BIGIP_ADDRESS, username=username, password=password)

if cmd == "start" :
	members = []
	for member in serverIps:
		members.append({
			'address': member,
			'port': RS_PORT
		})
	b.System.Session.set_active_folder('/Common')
	b.LocalLB.Pool.create_v2([POOL_NAME], [POOL_LB_METHOD], [members])

	b.System.Session.set_active_folder('/Common')
	b.LocalLB.VirtualServer.create([{
		'name': VS_NAME,
		'address': VS_ADDRESS,
		'port': VS_PORT,
		'protocol': 'PROTOCOL_TCP'
		}],
		['255.255.255.255'],
		[{
		'type': 'RESOURCE_TYPE_POOL',
		'default_pool_name' : POOL_NAME
		}],[[{}]])

elif cmd == "reload" :
	#Get all the members in the current pool from API
	r = b.LocalLB.Pool.get_member(['/Common/'+POOL_NAME])[0]

	#addServers = [server for server in serverIps if server not in currPool.keys() ]
	addServers = []
	for ip in serverIps:
		if not any(x['address'] == ip for x in r):
			addServers.append(ip)


	#For each server in the currPool, add it to addServers if it's not in serverIps
	#removeServers = [server for server in currPool.keys() if server not in serverIps ]
	removeServers = []
	for server in r:
		if server['address'] not in serverIps:
			removeServers.append(server)

	for member in addServers:
		b.LocalLB.Pool.add_member_v2(['/Common/'+POOL_NAME], [[{'port': RS_PORT, 'address': member}]])

	b.LocalLB.Pool.remove_member(['/Common/'+POOL_NAME], [removeServers])
	for server in removeServers:
		b.LocalLB.NodeAddressV2.delete_node_address([server['address']])

elif cmd == "stop" :
	r = b.LocalLB.Pool.get_member(['/Common/'+POOL_NAME])[0]
	currIpsInPool = []
	for server in r:
		currIpsInPool.append(server['address'])

	b.System.Session.set_active_folder('/Common')
	b.LocalLB.VirtualServer.delete_virtual_server(['/Common/'+VS_NAME])

	b.System.Session.set_active_folder('/Common')
	b.LocalLB.Pool.delete_pool(['/Common/'+POOL_NAME])
	
	b.System.Session.set_active_folder('/Common')
	b.LocalLB.NodeAddressV2.delete_node_address(currIpsInPool)

print_ext_service_result()