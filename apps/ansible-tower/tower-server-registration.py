#!/usr/bin/env python

import sys
import requests
from requests.auth import HTTPBasicAuth
import argparse
import json


parser = argparse.ArgumentParser()
parser.add_argument("cmd", help="add or remove node", choices=['add', 'remove'])
parser.add_argument("tower_ip", help="IP or hostname of Tower")
parser.add_argument("tower_username", help="Tower username")
parser.add_argument("tower_password", help="Tower password")
parser.add_argument("node_name", help="Name of the node you want to add or remove.")
parser.add_argument("inventory_id", help="Inventory ID to add or remove the node to/from.")

args = parser.parse_args()
parser.parse_args()

tower_base_url = "https://{}/api/v1/".format(args.tower_ip)


def get_host_id(name):
    s = requests.Session()

    url = tower_base_url+"hosts/"

    headers = {
        'content-type': "application/json"
    }
    querystring = {"name": name}

    response = s.request("GET", url, headers=headers, params=querystring, verify=False,
                         auth=HTTPBasicAuth(args.tower_username, args.tower_password))

    results = response.json()['results']
    if len(results) < 1:
        print("No host found with that name.")
        sys.exit(1)
    elif len(results) > 1:
        print("Multiple hosts found with that name, so I won't remove any of them.")
        sys.exit(1)
    else:
        return results[0]['id']


def remove_host(host_id):
    s = requests.Session()

    url = tower_base_url+"hosts/{}".format(host_id)

    headers = {
        'content-type': "application/json"
    }

    s.request("DELETE", url, headers=headers, verify=False,
              auth=HTTPBasicAuth(args.tower_username, args.tower_password))


def add_host(host_name, inventory):
    s = requests.Session()

    url = tower_base_url+"hosts/"

    headers = {
        'content-type': "application/json"
    }

    payload = {
        "name": host_name,
        "enabled": True,
        "inventory": inventory
    }

    s.request("POST", url, headers=headers, data=json.dumps(payload), verify=False,
              auth=HTTPBasicAuth(args.tower_username, args.tower_password))

if __name__ == "__main__":
    if args.cmd == 'add':
        add_host(args.node_name, args.inventory_id)
    elif args.cmd == 'remove':
        my_host_id = get_host_id(args.node_name)
        remove_host(my_host_id)
