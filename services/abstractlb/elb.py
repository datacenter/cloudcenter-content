#!/usr/bin/env python
import os
import sys
import requests
import json
import datetime
import boto3 
requests.packages.urllib3.disable_warnings()

cmd = sys.argv[1]

# Gather up all the custom parameters
VS_PORT = int(os.environ['vsPort'])
RS_PORT = int(os.environ['rsPort'])

#Set object names unique to job ID
POOL_NAME = "cliqr"+os.environ['parentJobId']+"pool"


try:
	#Create list of dependent service tiers
	dependencies = os.environ["CliqrDependencies"].split(",")
	#Set the new server list from the CliQr environment
	serverNodeIDs = os.environ["CliqrTier_"+dependencies[0]+"_NODE_ID"].split(",")
except (KeyError):
	print "No dependent service tiers found."
	# Set dependencies and server list to empty lists.
	dependencies = []
	serverNodeIDs = []

client = boto3.client('elb')

if cmd == "start" :
	members = []
	for member in serverNodeIDs:
		members.append({
			'InstanceId': member
		})

	response = client.create_load_balancer(
		LoadBalancerName=POOL_NAME,
		Listeners=[
			{
				'Protocol': 'HTTP',
				'LoadBalancerPort': VS_PORT,
				'InstanceProtocol': 'HTTP',
				'InstancePort': RS_PORT
			},
		],
		AvailabilityZones=[
			'us-west-2a',
			'us-west-2b',
			'us-west-2c'
		],
		SecurityGroups=[
			'sg-1bef717f',
		]
	)
	if len(members) > 0:
		response = client.register_instances_with_load_balancer(
			LoadBalancerName=POOL_NAME,
			Instances=members
		)

elif cmd == "reload" :
	#Get all the members in the current pool from API
	r = client.describe_instance_health(
		LoadBalancerName=POOL_NAME
	)

	#addServers = [server for server in serverNodeIDs if server not in currPool.keys() ]
	addServers = []
	for nodeId in serverNodeIDs:
		if not any(x['InstanceId'] == nodeId for x in r['InstanceStates']):
			addServers.append({
				'InstanceId': nodeId
			})


	#For each server in the currPool, add it to addServers if it's not in serverNodeIDs
	#removeServers = [server for server in currPool.keys() if server not in serverNodeIDs ]
	removeServers = []
	for server in r['InstanceStates']:
		if server['InstanceId'] not in serverNodeIDs:
			removeServers.append(server)

	if len(addServers) > 0:
		response = client.register_instances_with_load_balancer(
			LoadBalancerName=POOL_NAME,
			Instances=addServers
		)
		
	if len(removeServers) > 0:
		response = client.deregister_instances_from_load_balancer(
			LoadBalancerName=POOL_NAME,
			Instances=removeServers
		)


elif cmd == "stop" :
	response = client.delete_load_balancer(
		LoadBalancerName=POOL_NAME
	)