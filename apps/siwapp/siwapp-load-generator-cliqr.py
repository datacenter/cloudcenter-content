def get_cliqr_env_variables(var_list):
    env_dict = {}
    with open('/usr/local/osmosix/etc/userenv', 'r') as env_vars:
        for line in env_vars:
            if any(env_var in line for env_var in var_list) and line is not None:
                env_pair = (line.split(' ')[1]).split('=')
                env_dict[env_pair[0]] = env_pair[1].strip().replace('"','')
    return env_dict

import os
import sys
import time
import requests
from lxml import html

environment_variables = get_cliqr_env_variables(['CliqrTier_siwapp_app_HOSTNAME','CliqrTier_siwapp_haproxy_app_PUBLIC_IP'])
print environment_variables

SIWAPP_APP_SERVERS = environment_variables["CliqrTier_siwapp_app_HOSTNAME"].split(',')
SIWAPP_FRONTEND_PROXY_URL = 'http://' + environment_variables["CliqrTier_siwapp_haproxy_app_PUBLIC_IP"]
SIWAPP_LOGIN = '/login'
SIWAPP_PAGES = ['dashboard','invoices','recurring','customers','estimates','products']

while True:
    try:
        session = requests.session()
        resp = session.get(SIWAPP_FRONTEND_PROXY_URL + SIWAPP_LOGIN,timeout=10)
        break
    except requests.exceptions.ConnectTimeout:
        print("Get Timed Out")

while True:
    for server in SIWAPP_APP_SERVERS:
        session = requests.session()
        session.cookies.update({
            'SERVERID':server
        })

        login_page = session.get(SIWAPP_FRONTEND_PROXY_URL + SIWAPP_LOGIN)
        tree = html.fromstring(login_page.content)
        csrf_token = tree.xpath('//input[@name="signin[_csrf_token]"]/@value')
        print csrf_token
        payload = {
            'signin[_csrf_token]': csrf_token[0],
            'signin[username]': 'siwapp',
            'signin[password]': 'siwapp'
        }
        login = session.post(SIWAPP_FRONTEND_PROXY_URL + SIWAPP_LOGIN,data=payload)

        print session.cookies
        for page in SIWAPP_PAGES:
            response = session.get(SIWAPP_FRONTEND_PROXY_URL + '/' + page)
            print response.status_code

        response = session.get(SIWAPP_FRONTEND_PROXY_URL + '/logout')
        print response.status_code
    time.sleep(2)
