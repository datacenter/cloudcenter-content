#!/usr/bin/env python

import requests
import json
import sys
import os

requests.packages.urllib3.disable_warnings()

swarmIp = os.getenv('swarmIp')
swarmPort = os.getenv('swarmPort', '2376')
publishedPort = os.getenv('publishedPort')
exposedPort = os.getenv('exposedPort')

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

service_name = os.environ['parentJobName']+os.environ['parentJobId']

s = requests.Session()

url = "http://{swarmIp}:{swarmPort}/".format(swarmIp=swarmIp, swarmPort=swarmPort)

#r = s.request("GET", url+"services")

#print(r.json())

if cmd == "start" :
    try:
        with open("/serviceDef.json", 'r') as template_file_fd:
            serviceDef = json.load(template_file_fd)
    except Exception as err:
        print_log("Error loading the Swarm Template: {0}. Check your syntax".format(err))
        sys.exit(1)
    serviceDef['Name'] = service_name
    serviceDef['EndpointSpec']['Ports'] = [
        {
            "Protocol": "tcp",
            "TargetPort": exposedPort,
            "PublishedPort": publishedPort
        }
    ]

    try:
        r = s.request("POST", url+"services/create", data=json.dumps(serviceDef))
        print_log(r.status_code)
        print_log(json.dumps(r.json(), indent=2))
        r.raise_for_status()
    except Exception as err:
        print_log("Error deploying the Swarm Template: {0}.".format(err))
        sys.exit(1)


elif cmd == "stop" :
    r = s.request("DELETE", url+"services/{name}".format(name=service_name))
    #print(json.dumps(r.json(), indent=2))

elif cmd == "reload" :
    pass


print(r.json())