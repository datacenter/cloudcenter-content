#!/usr/bin/python

import json
import requests
import sys


def get_token(session, user='admin', password='password'):
    headers = { 'Content-Type': 'application/json' }
    payload = { 'username': user, 'password': password }
    r = session.request('POST', 'http://mkv-satwrdev01.co.ihc.com/api/v1/authtoken', data=json.dumps(payload), headers=headers)
    r = session.request('POST', 'http://mkv-satwrdev01.co.ihc.com/api/v1/authtoken', data=json.dumps(payload), headers=headers)
    j = r.json()
    return j['token']


def add_host(session, token, hostname):
    inventory_id = "5"
    headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Token {0}'.format(token)
    }

    payload = {
        "name": hostname,
        "enabled": True,
        "description": ""
    }

    r = session.request('POST', 'http://mkv-satwrdev01.co.ihc.com/api/v1/inventories/{0}/hosts'.format(inventory_id), data=json.dumps(payload), headers=headers)
    r = session.request('POST', 'http://mkv-satwrdev01.co.ihc.com/api/v1/inventories/{0}/hosts'.format(inventory_id), data=json.dumps(payload), headers=headers)


def delete_host(session, token, hostname):
    inventory_id = "5"
    headers = {
        'Authorization': 'Token {0}'.format(token)
    }

    r = session.request('GET', 'http://mkv-satwrdev01.co.ihc.com/api/v1/inventories/{0}/hosts/?search={1}'.format(inventory_id, hostname), headers=headers)
    j = r.json()
    if not r.json()['results']:
        return
    url = r.json()['results'][0]['url']
    r = session.request('DELETE', 'http://mkv-satwrdev01.co.ihc.com/{0}'.format(url), headers=headers)


if __name__ == '__main__':
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option("--add", dest="add", action="store_true", default=False)
    parser.add_option("--delete", dest="delete", action="store_true", default=False)
    parser.add_option("--hostname", dest="hostname", default=None)

    (options, args) = parser.parse_args()

    if not (options.add or options.delete):
        print("add/delete not specified, exiting...")
        sys.exit(1)
    if not options.hostname:
        if options.add:
            print("no hostname specified, exiting...")
            sys.exit(3)


    session = requests.Session()
    token = get_token(session)

    if options.add:
        add_host(session, token, options.hostname)
    elif options.delete:
        delete_host(session, token, options.hostname)
