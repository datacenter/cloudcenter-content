#!/usr/bin/env bash

env

#yum install -y python-pip
#pip install --upgrade pip
pip install --upgrade requests

curl -O https://raw.githubusercontent.com/datacenter/cloudcenter-content/servicenow/other/servicenow/servicenow.py
python servicenow.py $1