#!/usr/bin/env python
import requests
import os
import json
from requests.auth import HTTPBasicAuth

# requests.packages.urllib3.disable_warnings()

ccmIp = os.getenv('CliqrTier_ccm_PUBLIC_IP')
cloudType = os.getenv('OSMOSIX_CLOUD')
baseUrl = "https://{ccmIp}".format(ccmIp=ccmIp)
apiUser = "admin@cliqrtech.com,1"
apiPass = "cliqr"

# Create session object
s = requests.Session()


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


# Simple function to merge two dicts, with dict2 values overwriting dict1
def dict_merge(dict1=None, dict2=None):
    if dict1 and dict2:
        new_dict = dict1.copy()
        new_dict.update(dict2)
        return new_dict
    elif dict1:
        return dict1
    else:
        return dict2


def api_call(method, url, headers=None, params=None, data=None, files=None):
    if method == "GET":
        my_params = {
            "size": 0
        }
        params = dict_merge(my_params, params)
    my_headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }
    headers = dict_merge(my_headers, headers)
    response = s.request(method, url, headers=headers, params=params, data=data, files=files, verify=False,
                         auth=HTTPBasicAuth(apiUser, apiPass))
    # logging.debug("URL: {}".format(response.request.url))
    # logging.debug("Request Body: {}".format(response.request.body))
    # logging.debug("Request Headers: {}".format(response.request.headers))
    # logging.debug("Status Code: {}".format(response.status_code))
    # logging.debug("Response: {}".format(response.text))
    if response.status_code in [200, 201]:
        return response
    else:
        if response.status_code in [401]:
            msg = "API call failed, probably due to bad credentials."
        else:
            msg = "API call failed."
        raise Exception(msg)


headers = {
    'accept': "application/json",
    'content-type': "application/json"
}

# Create plan
url = baseUrl+"/v1/tenants/1/plans"
data = {
    "name": "planUnl",
    "description": "",
    "type": "UNLIMITED_PLAN",
    "showOnlyToAdmin": False,
    "price": "0.00",
    "onetimeFee": "",
    "billToVendor": False,
    "paymentProfileRequired": False,
    "tenantId": 1
}
response = s.request("POST", url, data=json.dumps(data), headers=headers, auth=(apiUser, apiPass), verify=False)
plan = response.json()

# Create contract
url = baseUrl+"/v1/tenants/1/contracts"
data = {
    "name": "Contract",
    "description": "",
    "length": "3",
    "showOnlyToAdmin": False,
    "terms": "terms",
    "tenantId": 1,
    "discountRate": "0"
}
response = s.request("POST", url, data=json.dumps(data), headers=headers, auth=(apiUser, apiPass), verify=False)
contract = response.json()

# Manage plan/contract for user.
url = baseUrl+"/v1/users/2"
data = {
    "action": "MANAGE_PLANS",
    "userManagePlansData": {
        "planId": int(plan['id']),
        "contractId": int(contract['id']),
        "renewContract": False,
        "type": "CHANGE_PRORATE",
        "userId": 2
    }
}
response = s.request("POST", url, data=json.dumps(data), headers=headers, auth=(apiUser, apiPass), verify=False)

# Agree to Terms
url = baseUrl+"/acctmgmt/service/agree_term"
data = {}
response = s.request("POST", url, data=json.dumps(data), headers=headers, auth=(apiUser, apiPass), verify=False)

# Import Apps

# Download app zip
apps = os.getenv('loadApps', None)
for app_url in apps.splitlines():
    response = s.request("GET", app_url)
    app_file = response.content

    # Import App
    url = baseUrl+"/apps_portation/import_apps"
    headers = {
        'accept': "*/*"
    }
    params = {}
    files = {'file': app_file}
    response = s.request("POST", url, files=files, headers=headers, auth=(apiUser, apiPass), verify=False)

# # Add cloud
# url = baseUrl+"/v1/tenants/1/clouds"
# data = {
#     "name": cloudType,
#     "description": "",
#     "cloudFamily": cloudType,
#     "publicCloud": True,
#     "tenantId": 1
# }
# response = s.request("POST", url, data=json.dumps(data), headers=headers, auth=(apiUser, apiPass), verify=False)
# response.text
#
# # Add Cloud Account
# cc_email = os.getEnv("ccEmail", None)
# cc_cloud_key = os.getEnv("ccCloudKey", None)
# cc_cloud_secret = os.getEnv("ccCloudSecret", None)
# cc_cloud_account = os.getEnv("ccCloudAccount", None)
# cc_tenant_id = os.getEnv("ccTenantID", None)
#
# url = baseUrl+"/v1/tenants/1/clouds/1/accounts"
# data = {
#     "IAMRoleEnable": cloudType,
#     "accountDescription": "",
#     "accountId": cc_cloud_account,
#     "accountName": cc_email,
#     "accountPassword": cc_cloud_key,
#     "accountProperties": [
#         {
#             "name": "IAMRoleEnable",
#             "value": False
#         }, {
#             "name": "AccessSecretKey",
#             "value": cc_cloud_secret
#         }, {
#             "name": "EC2ARN",
#             "value": ""
#         }
#     ],
#     "allowedUsers": [],
#     "cloudId": "1",
#     "displayName": "first_cloud_acct",
#     "manageCost": True,
#     "userId": 2
# }
# api_call(method="POST", url=url, data=json.dumps(data))

# Adding Azure account
# {"displayName":"mdavis-Az","accountDescription":"","userId":2,"cloudId":"2","allowedUsers":[],"accountName":"mdavis@cliqr.com","accountId":"09802e14-54b4-4b43-a56c-554ba30d9230","accountProperties":[{"name":"TenantId","value":"cac4fec3-892f-4eb8-b027-f479a1e96eaa"},{"name":"ClientId","value":"0f0caab2-e283-414c-b805-7c9a7ca416ca"},{"name":"ClientKey","value":"1IrDvBsOiwfEig7YDhSusjutcYNVByyCJiNkXvnQPsU="}],"accountPassword":""}