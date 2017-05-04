#!/bin/bash
. /utils.sh

config_url="${gitUrl}/${gitTag}/apps/cloudcenter/ccm-config.py"

wget --no-check-certificate ${config_url}
if [ $? -ne 0 ]; then
    print_log  "Failed downloading ${config_url}. You can still perform the post-install UI configuration manually."
fi

yum install python-pip -y
pip install --upgrade pip
pip install requests

python ccm-config.py

if [ $? -ne 0 ]; then
    print_log  "Failed executing ccm-config.py. You can still perform the post-install UI configuration manually."
fi