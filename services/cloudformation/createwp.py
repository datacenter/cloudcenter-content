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


# cmd = sys.argv[1]
# Big fat try block to ensure that whatever bad happens, it gets bubbled to CCM UI.
try:
    JOB_NAME = os.environ['parentJobName']+os.environ['currentTierJobId']
    TEMPLATE_URL = os.environ['Templateurl']
    REGION_NAME = os.environ['region']

    symbol = "~`!@#$%^&*()_+={}[]:>;',</?*+"
    for i in JOB_NAME:
        if i in symbol:
               print_log("Job Name must satisfy regular expression pattern: [a-zA-Z][-a-zA-Z0-9]*")
               sys.exit(1)


    cft = boto3.client('cloudformation')
    with open('/cf-template.json', 'r') as template_file_fd:
        template = template_file_fd.read()

    params = []
    if os.path.isfile('/cf-params.json'):
        with open('/cf-params.json', 'r') as params_file_fd:
            params = json.load(params_file_fd)

    # TODO: Security review required for IAM capabilties
    create_cft = cft.create_stack(
        StackName=JOB_NAME,
        TemplateBody=template,
        Parameters=params,
        Capabilities=['CAPABILITY_NAMED_IAM'],
        TimeoutInMinutes=10
    )

    stack_id = create_cft.get("StackId")

    #Get WebURL for the deployed stack
    #
    #time.sleep(60)
    #conn = boto.cloudformation.connect_to_region(REGION_NAME)
    #get_stack = conn.describe_stacks(stack_id)
    stack = cft.describe_stacks(StackName=stack_id)

    i = 0
    while stack['Stacks'][0]['StackStatus'] not in ['ROLLBACK_COMPLETE', 'CREATE_COMPLETE', 'CREATE_FAILED']:
        status = stack['Stacks'][0].get('StackStatus', None)
        reason = stack['Stacks'][0].get('StackStatusReason', None)
        message = "{}, Reason: {}".format(status, reason)
        print(message)
        time.sleep(5)
        stack = cft.describe_stacks(StackName=stack_id)
        i =+ 1
        if i > 120: # break after 10min, just in case.
            break


    stack_events = cft.describe_stack_events(StackName=stack_id)
    for event in reversed(stack_events['StackEvents']):
        status = event.get('ResourceStatus', None)
        reason = event.get('ResourceStatusReason', None)
        # timestamp = event.get('Timestamp', None)
        resource_type = event.get('ResourceType', None)
        message = "{} {}, Reason: {}".format(resource_type, status, reason)
        print_log(message)

    for output in stack['Stacks'][0]['Outputs']:
        key = output['OutputKey']
        value = output['OutputValue']
        desc = output['Description']
        output_msg = "{}: {}, {}".format(key, value, desc)
        print_log(output_msg)

    # After all that, if it doesn't look complete, just delete it. At the end to ensure as much info as
    # possible about what went wrong is passed to UI.
    if stack['Stacks'][0]['StackStatus'] not in ['CREATE_COMPLETE']:
        print_log("Looks like the stack didn't deploy properly for some reason.")
        #cft.delete_stack(StackName=stack_id)
        sys.exit(1)

    # checkstatus = []
    #
    # while not checkstatus:
    #     time.sleep(10)
    #     conn = boto.cloudformation.connect_to_region(REGION_NAME)
    #     get_stack = conn.describe_stacks(stack_id)
    #     stack = get_stack[0]
    #     for output in stack.outputs:
    #         checkstatus = '%s=%s (%s)' % (output.key, '', output.value)
    #         print_log('%s=%s (%s)' % (output.key, '', output.value))
    #         if checkstatus != []:
    #             break

except Exception as err:
    print_log("Error: {0}".format(err))
    sys.exit(1)
