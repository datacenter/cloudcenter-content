#!/usr/bin/env python
import os
import boto3
import json
import sys


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


def get_hosted_zone_id(domain):
    response = client.list_hosted_zones()
    for hosted_zone in response['HostedZones']:
        if hosted_zone['Name'] in [domain, domain+'.']:
            return hosted_zone['Id']
    return False


app_domain = os.getenv("appDomain")
app_hostname = os.getenv("appHostname", None)
if not app_hostname:
    app_hostname = os.getenv('parentJobName')



client = boto3.client('route53')
# Create list of dependent service tiers
dependencies = os.environ["CliqrDependencies"].split(",")
# NOTE: THIS SCRIPT ONLY SUPPORTS THE FIRST DEPENDENT TIER!!!
if len(dependencies) != 1:
    print_error("This Route53 service supports only exactly one dependent (lower) tier. If you want multiple"
                "add another Route53 service to the other service tier.")
    exit(1)

# Set the new server list from the CliQr environment
server_addresses = os.environ["CliqrTier_" + dependencies[0] + "_PUBLIC_IP"].split(",")
ip_address_rr = [{'Value': ip} for ip in server_addresses]


fqdn = "{}.{}.{}".format(dependencies[0], app_hostname, app_domain)

cmd = sys.argv[1]
if cmd == "start":
    response = client.change_resource_record_sets(
        HostedZoneId=get_hosted_zone_id(app_domain),
        ChangeBatch={
            'Comment': 'string',
            'Changes': [
                {
                    'Action': 'CREATE',
                    'ResourceRecordSet': {
                        'Name': fqdn,
                        'Type': 'A',
                        'TTL': 1,
                        'ResourceRecords': ip_address_rr
                    }
                }
            ]
        }
    )
    result = {
        'hostName': fqdn,
        'ipAddress': fqdn,
        'environment': {
        }
    }
    print_ext_service_result(json.dumps(result))

elif cmd == "stop":
    response = client.change_resource_record_sets(
        HostedZoneId=get_hosted_zone_id(app_domain),
        ChangeBatch={
            'Comment': 'string',
            'Changes': [
                {
                    'Action': 'DELETE',
                    'ResourceRecordSet': {
                        'Name': fqdn,
                        'Type': 'A',
                        'TTL': 1,
                        'ResourceRecords': ip_address_rr
                    }
                }
            ]
        }
    )

elif cmd == "update":
    print_log("No action defined for UPDATE")

else:
    print_log("No valid action specified (start, stop or update).")

