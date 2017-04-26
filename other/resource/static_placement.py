#!/usr/bin/env python

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


content = {
    "UserDataCenterName": "Tetration",
    "UserClusterName": "ta-apps",
    # "UserResourcePoolName": "",
    "vmTagsList": "Name:mdavis-vm",
    "UserDatastoreCluster": "ta-apps-vmfs",
    # "RootFolderName": "vm",
    "UserFolderName": "mdavis",
    "RootDiskResizable": "false",
    "FullClone": "true",
    "VmRelocationEnabled": "true",
    "LocalDataStoreEnabled": "true",
    "SystemFolderName": "CliqrTemplates",
    "networkList": "apps-202",
    "UserHost": "ta-apps-esx-04.auslab.cisco.com"  # ,
    # "nodeInfo": "UserDataCenterName: Tetration, UserClusterName: ta-apps,"
    #             "UserDatastoreCluster: ta-apps-vmfs, networkList: apps-202"
}

print_ext_service_result(json.dumps(content))
