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

    # TODO: Test resource pool assignment.
    # Resource Pool.
    # "UserResourcePoolName": "",

    # TODO: Test vm tag list.
    "vmTagsList": "Name:my-vm",

    # Datastore or DS Cluster to deploy to.
    "UserDatastoreCluster": "my-ds-cluster",

    # vCenter VM folder - Just the folder itself, not the whole path.
    # Not '/path/to/folder', just 'folder'.
    "UserFolderName": "myfolder1",

    # Use strings, not booleans
    "RootDiskResizable": "false",  #
    "FullClone": "true",  #
    "VmRelocationEnabled": "true",  #
    "LocalDataStoreEnabled": "true",  #

    # vCenter Folder where the VM snapshot or template is that will be cloned.
    "SystemFolderName": "CliqrTemplates",

    # Port Group. Must be in form "<port group> (<DV Switch>)" If no DV switch, use empty parenthesis.
    "networkList": "apps-202 ()",

    # These values will show up in the UI for the node being created.
    # Value should be a single string, not a nested dict.
    "nodeInfo": "Arbitrary String that shows up in Node Info area on deployment page."
}

print_ext_service_result(json.dumps(content))
