# Deployment cleanup script

import requests, pdb, sys
from requests.auth import HTTPBasicAuth
requests.packages.urllib3.disable_warnings()

if len(sys.argv) != 3:
    print("Requires 3 arguments. Usage python clean.py <api username> <api key> <ccm address/hostname>")
    sys.exit(1)

username = sys.argv[1]
apiKey = sys.argv[2]
ccm = sys.argv[3]

url = "https://"+ccm+"/v1/jobs"

querystring = {}

headers = {
    'x-cliqr-api-key-auth': "true",
    'accept': "application/json",
    'content-type': "application/json",
    'cache-control': "no-cache"
    }

response = requests.request("GET", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))
print(response.text)

for job in response.json()['jobs']:
    if job['deploymentInfo'] and job['deploymentInfo']['deploymentStatus'] in ['Error']:
        deploymentId = job['deploymentInfo']['deploymentId']


        url = "https://"+ccm+"/v1/jobs/"+job['id']

        querystring = {"hide":"true"}

        headers = {
            'cache-control': "no-cache"
            }

        response = requests.request("DELETE", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))
        print(job['id'])
        print(response.text)
    if job['deploymentInfo'] and job['deploymentInfo']['deploymentStatus'] in ['Terminated']:
        deploymentId = job['deploymentInfo']['deploymentId']


        url = "https://"+ccm+"/v1/jobs/"+job['id']

        querystring = {"action":"hide"}

        headers = {
            'cache-control': "no-cache"
            }

        response = requests.request("PUT", url, headers=headers, params=querystring, verify=False, auth=HTTPBasicAuth(username, apiKey))
        print(job['id'])
        print(response.text)