#!/bin/bash -x
exec > >(tee -a /var/tmp/ccm-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
cd ~

env

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="cc-from-appliances"
fi

# Use "?" as sed delimiter to avoid escaping all the slashes
sudo sed -i -e "s?dnsName=?dnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/osmosix/etc/gateway_config.properties
sudo sed -i -e "s?gatewayHost=?gatewayHost=${CliqrTier_cco_PUBLIC_IP}?g" /usr/local/tomcatgua/webapps/access/WEB-INF/gua.properties
sudo -E /etc/init.d/tomcatgua restart
sudo -E /etc/init.d/rabbitmq-server restart