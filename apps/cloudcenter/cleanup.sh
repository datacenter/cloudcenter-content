#!/bin/bash -x
exec > >(tee -a /var/tmp/cleanup_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh


clean_url="${gitUrl}/${gitTag}/apps/cloudcenter/cleanup.py"

wget --no-check-certificate ${clean_url}
if [ $? -ne 0 ]; then
    agentSendLogMessage  "CRITICAL: Failed downloading ${clean_url}. Unable to terminate running jobs in terminated
    CloudCenter instance. There may still be VMs running in the clouds that were deployed by this instance."
    exit 1
fi

yum install -y python-pip
pip install --upgrade pip requests

python cleanup.py admin@cliqrtech.com,1 cliqr ${CliqrTier_ccm_PUBLIC_IP}
