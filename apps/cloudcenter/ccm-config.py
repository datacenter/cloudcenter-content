#!/usr/bin/env python
import requests
import os
import json
from bs4 import BeautifulSoup
requests.packages.urllib3.disable_warnings()


ccmIP = os.getenv('CliqrTier_ccm_PUBLIC_IP')

# Create session object
s = requests.Session()

# Get CSRF Token
url = "https://{ccmIP}/system/service/get_session".format(ccmIP = ccmIP)

# Retrieve the CSRF token first
response = s.request("GET", url, verify=False)
#soup = BeautifulSoup(response.text, "lxml")
#csrftoken = soup.find('input', dict(name='_csrf'))['value']

csrftoken = json.loads(response.text)["_csrf"]["token"]

# Login
url = "https://{ccmIP}/account/login".format(ccmIP = ccmIP)

querystring = {}
payload = {
    "username":"admin@cliqrtech.com,1",
    "password":"cliqr",
    "request_source" : "",
    "_csrf" : csrftoken
}
headers = {
    'origin': "https://54.164.180.248",
    'x-devtools-emulate-network-conditions-client-id': "431ae4e3-53f3-4153-9a63-bfd3f8cab801",
    'upgrade-insecure-requests': "1",
    'user-agent': "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36",
    'content-type': "application/x-www-form-urlencoded",
    'accept': "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
    'referer': url,
    'accept-encoding': "gzip, deflate, br",
    'accept-language': "en-US,en;q=0.8",
    'cache-control': "no-cache",
    'postman-token': "0caca4fe-a1d3-03f1-a239-0804c7111986"
}
response = s.request("POST", url, data=payload, headers=headers, verify=False)
lr = response.request
print(response.text)

# Get API Key

url = "https://{ccmIP}/v1/users/2/keys".format(ccmIP = ccmIP)

headers = {
    'accept': "*/*",
    'x-requested-with': "XMLHttpRequest",
    'user-agent': "Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.143 Safari/537.36",
    'referer': "https://54.164.180.248/",
    'accept-encoding': "gzip, deflate, sdch, br",
    'accept-language': "en-US,en;q=0.8",
    'cache-control': "no-cache"
}

response = s.request("GET", url, headers=headers, verify=False)

print(response.text)

# Create Plan
url = "https://{ccmIP}/v1/tenants/1/plans".format(ccmIP = ccmIP)
querystring = {}
payload = {
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
response = s.request("POST", url, data=json.dumps(payload), headers=headers, params=querystring, verify=False, auth=('admin', 'infoblox'))
print(response.text)
