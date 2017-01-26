#!/bin/bash -x
exec > >(tee -a /var/tmp/amqp-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh
cd ~

env

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="cloudcenter-fullinstall"
fi

sudo mv /etc/yum.repos.d/cliqr.repo ~
sudo yum install -y wget vim java-1.8.0-openjdk nmap
sudo sudo mv ~/cliqr.repo /etc/yum.repos.d/

cd /tmp
wget --no-check-certificate -O core_installer.bin --user $dlUser --password $dlPass https://download.cliqr.com/release-4.7.0-20170105.3/installer/core_installer.bin
wget --no-check-certificate -O cco-installer.jar --user $dlUser --password $dlPass 	https://download.cliqr.com/release-4.7.0-20170105.3/appliance/cco-installer.jar
wget --no-check-certificate -O conn_broker-response.xml --user $dlUser --password $dlPass https://download.cliqr.com/release-4.7.0-20170105.3/appliance/conn_broker-response.xml

sudo chmod +x core_installer.bin
sudo ./core_installer.bin centos7 amazon rabbit
sudo java -jar cco-installer.jar conn_broker-response.xml

 # Use "?" as sed delimiter to avoid escaping all the slashes
 sudo sed -i -e "s?dnsName=?dnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/osmosix/etc/gateway_config.properties
 sudo sed -i -e "s?gatewayHost=?gatewayHost=${CliqrTier_cco_PUBLIC_IP}?g" /usr/local/tomcatgua/webapps/access/WEB-INF/gua.properties

 # Source profile to ensure pick up the JAVA_HOME env variable.
 . /etc/profile
 sudo -E /etc/init.d/tomcatgua restart
 sudo -E /etc/init.d/rabbitmq-server restart
 sudo /usr/local/osmosix/bin/rabbit_config.sh