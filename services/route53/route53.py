#!/usr/bin/env python
import sys
import os
import time
import boto3
# import boto.cloudformation
import json


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

app_domain = os.getenv("appDomain")
app_hostname = os.getenv("appHostname", None)
if not app_hostname:
    app_hostname = os.getenv('parentJobName')

fqdn = "{}.{}".format(app_hostname, app_domain)

client = boto3.client('route53')

response = client.change_resource_record_sets(
    HostedZoneId="/hostedzone/ZX2E8F6AAJENO",
    ChangeBatch={
        'Comment': 'string',
        'Changes': [
            {
                'Action': 'CREATE',
                'ResourceRecordSet': {
                    'Name': fqdn,
                    'Type': 'A',
                    'TTL': 1,
                    'ResourceRecords': [
                        {
                            'Value': '192.0.2.1'
                        },
                    ]
                }
            },
        ]
    }
)