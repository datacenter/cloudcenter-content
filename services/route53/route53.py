#!/usr/bin/env python
import os
import boto3
import json
import sys

client = boto3.client('route53')


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
    response_hz = client.list_hosted_zones()
    for hosted_zone in response_hz['HostedZones']:
        if hosted_zone['Name'] in [domain, domain+'.']:
            return hosted_zone['Id']
    raise Exception("Unable to find hosted zone {domain} in this AWS account.".format(domain=domain))


def get_dependent_tier():
    # Create list of dependent service tiers
    dependencies = os.environ["CliqrDependencies"].split(",")
    # NOTE: THIS SCRIPT ONLY SUPPORTS THE FIRST DEPENDENT TIER!!!
    if len(dependencies) != 1:
        raise Exception("This Route53 service supports only exactly one dependent (lower) tier."
                        "If you want multiple add another Route53 service to the other service tier.")
        exit(1)
    return dependencies[0]


def get_dependent_ips():
    # Set the new server list from the CliQr environment
    dependent_addresses = os.environ["CliqrTier_" + get_dependent_tier() + "_PUBLIC_IP"]
    print_log("Dependent Addresses: {}".format(dependent_addresses))

    return dependent_addresses.split(",")


try:
    app_domain = os.getenv("route53_appDomain")
    app_hostname = os.getenv("route53_appHostname", None)
    if not app_hostname:
        app_hostname = os.getenv('parentJobName')

    server_addresses = get_dependent_ips()

    # Restructure server_addresses simple list of IPs into ResourceRecordSet dict.
    ip_address_rr = [{'Value': ip} for ip in server_addresses]

    # Valid DNS names are lower-alphanumeric, digits and dashes. Nothing else.
    fqdn = "{}.{}.{}".format(
        "".join(a for a in get_dependent_tier() if (a.isalnum() or a == '-')).lower(),
        "".join(a for a in app_hostname if (a.isalnum() or a == '-')).lower(),
        app_domain
    )
    print_log("FQDN: {}".format(fqdn))

    cmd = sys.argv[1]
    # Map the CloudCenter actions to the route53 DNS actions.
    crud_map = {
        'start': 'UPSERT',
        'stop': 'DELETE',
        'update': 'UPSERT',
        'post_migrate': 'UPSERT'
    }
    change_batch = {
        'Comment': 'string',
        'Changes': [
            {
                'Action': crud_map[cmd],  # Request is the same but for the action.
                'ResourceRecordSet': {
                    'Name': fqdn,
                    'Type': 'A',
                    'TTL': 1,
                    'ResourceRecords': ip_address_rr
                }
            }
        ]
    }
    print_log("Change Batch: {}".format(change_batch))
    try:
        response = client.change_resource_record_sets(
            HostedZoneId=get_hosted_zone_id(app_domain),
            ChangeBatch=change_batch
        )
    except Exception as err:
        print_log("Error  {}".format(err))
        template = "An exception of type {0} occurred while trying to update the record set. Arguments:\n{1!r}"
        message = template.format(type(err).__name__, err.args)
        print_log(message)
        raise

    result = {
        'hostName': fqdn,
        'ipAddress': fqdn,
        'environment': {
        }
    }
    print_ext_service_result(json.dumps(result))
except Exception as err:
    template = "An exception of type {0} occurred. Arguments:\n{1!r}"
    message = template.format(type(err).__name__, err.args)
    print_log(message)
    raise
