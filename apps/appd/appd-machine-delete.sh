#!/bin/bash -x

yum install -y python-pip
pip install pip --upgrade
pip install requests

curl -o appd-machine-delete.py https://raw.githubusercontent.com/datacenter/cloudcenter-content/appd1.1/apps/appd/appd-machine-delete.py
python appd-machine-delete.py