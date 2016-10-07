#!/usr/bin/env python
import requests
import os

ccmIP = os.getenv('CliqrTier_ccm_PUBLIC_IP')

# Create Plan
url = "https://{ccmIP}/v1/tenants/1/plans".format(ccmIP = ccmIP)
querystring = {
    "name":"Test2",
    "description":"Initial Unlimited Plan",
    "type":"UNLIMITED_PLAN",
    "showOnlyToAdmin":False,
    "price":"0.00",
    "onetimeFee":"",
    "billToVendor":False,
    "paymentProfileRequired":False,
    "tenantId":"1"
}
headers = {
    "Accept":"application/json",
    "Content-Type":"application/json"
}
response = requests.request("POST", url, headers=headers, params=querystring, verify=False)
print(response.json())
