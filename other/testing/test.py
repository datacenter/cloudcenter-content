import requests
from requests.auth import HTTPBasicAuth
requests.packages.urllib3.disable_warnings()
import argparse
import json
import os
import random
import string

parser = argparse.ArgumentParser()
parser.add_argument("username", help="Your API username. Not the same as your UI Login. See your CloudCenter admin for help.")
parser.add_argument("apiKey", help="Your API key.")
parser.add_argument("ccm", help="CCM hostname or IP.")

args = parser.parse_args()
parser.parse_args()

username = args.username
apiKey = args.apiKey
ccm = args.ccm
baseUrl = "https://"+args.ccm

for filename in os.listdir('profiles'):

    profile = None
    with open('profiles/'+filename, 'r') as f:
        profile = json.load(f)

    profile['name'] = "test"+''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(5))

    session = requests.Session()
    url = baseUrl+"/v2/jobs/"

    headers = {
        'x-cliqr-api-key-auth': "true",
        'accept': "application/json",
        'content-type': "application/json",
        'cache-control': "no-cache"
    }

    response = session.post(url, headers=headers, data=json.dumps(profile), verify=False, auth=HTTPBasicAuth(username, apiKey))
