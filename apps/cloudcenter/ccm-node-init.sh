#!/bin/bash -x
exec > >(tee -a /var/tmp/ccm-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh
cd ~

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="cc-from-appliances"
fi

yum install -y wget vim

# Download necessary files
wget --no-check-certificate -O core_installer.bin --user $dlUser --password $dlPass https://download.cliqr.com/release-4.6.1-20161109.1/installer/core_installer.bin
wget --no-check-certificate -O ccm-installer.jar --user $dlUser --password $dlPass 	https://download.cliqr.com/release-4.6.1-20161109.1/appliance/ccm-installer.jar
wget --no-check-certificate -O ccm-response.xml --user $dlUser --password $dlPass https://download.cliqr.com/release-4.6.1-20161109.1/appliance/ccm-response.xml


# Use "?" as sed delimiter to avoid escaping all the slashes
sed -i -e "s?publicDnsName=<mgmtserver_public_dns_name>?publicDnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/tomcat/webapps/ROOT/WEB-INF/server.properties

sudo /etc/init.d/tomcat stop
sudo echo "" > /usr/local/tomcat/logs/osmosix.log
sudo /etc/init.d/tomcat start


agentSendLogMessage  "Waiting for server to start."
COUNT=0
MAX=50
SLEEP_TIME=5
ERR=0

until $(curl https://$CliqrTier_ccm_PUBLIC_IP -k -m 5 ); do
  sleep ${SLEEP_TIME}
  let "COUNT++"
  echo $COUNT
  if [ $COUNT -gt 50 ]; then
    ERR=1
    break
  fi
done
if [ $ERR -ne 0 ]; then
    agentSendLogMessage "Failed to start server after about 5 minutes"
else
    agentSendLogMessage "Server Started."
fi