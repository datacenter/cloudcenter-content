#!/usr/bin/env python
import sys
import os
import time
import boto3
import boto.cloudformation
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


# cmd = sys.argv[1]


JOB_NAME = os.environ['parentJobName']
TEMPLATE_URL = os.environ['Templateurl']
REGION_NAME = os.environ['region']

symbol = "~`!@#$%^&*()_+={}[]:>;',</?*+"
for i in JOB_NAME:
    if i in symbol:
           print_log("Job Name must satisfy regular expression pattern: [a-zA-Z][-a-zA-Z0-9]*")
           sys.exit(errno.EINVAL)          


cft = boto3.client('cloudformation')
with open('/cf-template.json', 'r') as template_file_fd:
    template = template_file_fd.read()
create_cft = cft.create_stack(StackName=JOB_NAME, TemplateBody=template)

stack_id = create_cft.get("StackId")

#Get WebURL for the deployed stack
#
time.sleep(60)
conn = boto.cloudformation.connect_to_region(REGION_NAME)
get_stack = conn.describe_stacks(stack_id)


checkstatus = []

while not checkstatus: 
    time.sleep(10)
    conn = boto.cloudformation.connect_to_region(REGION_NAME)
    get_stack = conn.describe_stacks(stack_id)
    stack = get_stack[0]
    for output in stack.outputs:
        checkstatus = '%s=%s (%s)' % (output.key, '', output.value)
        print_log('%s=%s (%s)' % (output.key, '', output.value))
        if checkstatus != []:
            break    