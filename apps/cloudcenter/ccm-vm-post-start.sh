#!/bin/bash
. /utils.sh

sudo yum install python-pip -y
sudo pip install --upgrade pip
sudo pip install requests

config_url="${gitUrl}/${gitTag}/apps/cloudcenter/ccm-config.py"

wget --no-check-certificate ${config_url}
if [ $? -ne 0 ]; then
    print_log  "Failed downloading ${config_url}. You can still perform the post-install UI configuration manually."
fi

python ccm-config.py

if [ $? -ne 0 ]; then
    print_log  "Failed executing ccm-config.py. You can still perform the post-install UI configuration manually."
fi
