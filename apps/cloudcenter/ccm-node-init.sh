#!/bin/bash -x
exec > >(tee -a /var/tmp/ccm-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh

env

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="master"
fi


yum install python-pip -y
pip install requests

# Use "?" as sed delimiter to avoid escaping all the slashes
sed -i -e "s?publicDnsName=<mgmtserver_public_dns_name>?publicDnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/tomcat/webapps/ROOT/WEB-INF/server.properties

sudo /etc/init.d/tomcat start

sudo wget -N https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/apps/cloudcenter/ccm-config.py -O ccm-config.py
if [ $? -ne 0 ]; then
    agentSendLogMessage  "Failed downloading https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/apps/cloudcenter/ccm-config.py. You can still perform the post-install UI configuration manually."
fi

python ccm-config.py

if [ $? -ne 0 ]; then
    agentSendLogMessage  "Failed executing ccm-config.py. You can still perform the post-install UI configuration manually."
fi