#!/bin/bash
. /utils.sh

dlFile () {
    agentSendLogMessage  "Attempting to download $1"

    if [ -n "$dlUser" ]; then
        agentSendLogMessage  "Found user ${dlUser} specified. Using that and specified password for download auth."
        wget --no-check-certificate --user $dlUser --password $dlPass $1
    else
        agentSendLogMessage  "Didn't find username specified. Downloading with no auth."
        wget --no-check-certificate $1
    fi

    if [ "$?" = "0" ]; then
        agentSendLogMessage  "$1 downloaded"
    else
        agentSendLogMessage  "Error downloading $1"
        exit 1
    fi
}

sudo yum install python-pip -y
sudo pip install --upgrade pip
sudo pip install requests
dlFile https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/apps/cloudcenter/ccm-config.py -O ccm-config.py
if [ $? -ne 0 ]; then
    print_log  "Failed downloading https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/apps/cloudcenter/ccm-config.py. You can still perform the post-install UI configuration manually."
fi

python ccm-config.py

if [ $? -ne 0 ]; then
    print_log  "Failed executing ccm-config.py. You can still perform the post-install UI configuration manually."
fi
