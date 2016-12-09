#!/usr/bin/env python
import os
import boto3
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


# cmd = sys.argv[1]

# Big fat try block to ensure that whatever bad happens, it gets bubbled to CCM UI.
try:

    JOB_NAME = os.environ['parentJobName']+os.environ['currentTierJobId']

    print_log("Job Name: " + str(JOB_NAME))
    cft = boto3.client('cloudformation')
    delete_cft = cft.delete_stack(StackName=JOB_NAME)
    print_log(delete_cft)

except Exception as err:
    print_log("Error: {0}".format(err))
    sys.exit(1)
