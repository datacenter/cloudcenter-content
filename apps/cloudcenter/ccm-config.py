#!/usr/bin/env python
import requests
import os
import json
# requests.packages.urllib3.disable_warnings()


ccmIp = os.getenv('CliqrTier_ccm_PUBLIC_IP')
baseUrl = "https://{ccmIp}".format(ccmIp=ccmIp)
apiUser = "admin@cliqrtech.com,1"
apiPass = "cliqr"

# Create session object
s = requests.Session()

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

# Add Amazon cloud
url = baseUrl+"/v1/tenants/1/clouds"
data = {
    "name": "Amazon",
    "description": "",
    "cloudFamily": "Amazon",
    "publicCloud": True,
    "tenantId": 1
}
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


