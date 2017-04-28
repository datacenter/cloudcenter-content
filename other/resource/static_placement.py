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

# This dict provides all of the deployment configuration to CloudCenter.
content = {
    # vCenter Datacenter.
    "UserDataCenterName": "MyDatacenter",

    # vCenter cluster.
    "UserClusterName": "MyCluster",

    # Resource Pool.
    # "UserResourcePoolName": "",

    #
    "vmTagsList": "Name:my-vm",

    # Datastore or DS Cluster to deploy to.
    "UserDatastoreCluster": "my-ds-cluster",

    # vCenter VM folder
    "UserFolderName": "myfolder1/myfolder2",

    # Use strings, not booleans
    "RootDiskResizable": "false",  #
    "FullClone": "true",  #
    "VmRelocationEnabled": "true",  #
    "LocalDataStoreEnabled": "true",  #

    # vCenter Folder where the VM snapshot or template is that will be cloned.
    "SystemFolderName": "CliqrTemplates",

    # Port Group. Must be in form "<port group> (<DV Switch>)" If no DV switch, use empty parenthesis.
    "networkList": "apps-202 ()",

    # ESX Host to deploy to
    "UserHost": "esx01.demo.cisco.com",

    # These values will show up in the UI for the node being created.
    # Value should be a single string, not a nested dict.
    "nodeInfo": "UserDataCenterName: Tetration, UserClusterName: ta-apps,"
                "UserDatastoreCluster: ta-apps-vmfs, networkList: apps-202"
}

print_ext_service_result(json.dumps(content))
