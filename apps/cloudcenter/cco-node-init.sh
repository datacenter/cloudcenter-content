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
sudo sed -i -e "s?host=?host=${CliqrTier_amqp_PUBLIC_IP}?g" /usr/local/osmosix/etc/rev_connection.properties
sudo sed -i -e "s?brokerHost=?brokerHost=${CliqrTier_amqp_PUBLIC_IP}?g" \
 -e "s?gateway.cluster.addresses=?gateway.cluster.addresses=${CliqrTier_amqp_PUBLIC_IP}:5671?g" \
 /usr/local/tomcat/webapps/ROOT/WEB-INF/rabbit-gateway.properties
sudo -E /etc/init.d/tomcat restart
