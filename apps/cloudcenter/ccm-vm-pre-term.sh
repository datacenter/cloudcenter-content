#!/bin/bash
. /utils.sh

clean_url="${gitUrl}/${gitTag}/apps/cloudcenter/cleanup.py"

wget --no-check-certificate ${clean_url}
if [ $? -ne 0 ]; then
    agentSendLogMessage  "CRITICAL: Failed downloading ${clean_url}. Unable to terminate running jobs in terminated
    CloudCenter instance. There may still be VMs running in the clouds that were deployed by this instance."
    exit 1
fi

sudo yum install python-pip -y
sudo pip install --upgrade pip
sudo pip install requests

python cleanup.py admin@cliqrtech.com,1 cliqr ${CliqrTier_ccm_PUBLIC_IP}
