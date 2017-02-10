#!/bin/bash -x
exec > >(tee -a /var/tmp/amqp-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

defaultGitTag="cc-full-4.7.1.1"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

ccRel="release-4.7.1.1-20170206.2"

agentSendLogMessage  "CloudCenter release ${ccRel} selected."

agentSendLogMessage  "Installing OS Prerequisits wget vim java-1.8.0-openjdk nmap"
sudo mv /etc/yum.repos.d/cliqr.repo ~
sudo yum install -y wget vim java-1.8.0-openjdk nmap

# Download necessary files
cd /tmp
agentSendLogMessage  "Downloading installer files."
wget --no-check-certificate -O core_installer.bin --user $dlUser --password $dlPass https://download.cliqr.com/${ccRel}/installer/core_installer.bin
wget --no-check-certificate -O cco-installer.jar --user $dlUser --password $dlPass 	https://download.cliqr.com/${ccRel}/appliance/cco-installer.jar
wget --no-check-certificate -O conn_broker-response.xml --user $dlUser --password $dlPass https://download.cliqr.com/${ccRel}/appliance/conn_broker-response.xml

sudo chmod +x core_installer.bin
agentSendLogMessage  "Running core installer"
sudo ./core_installer.bin centos7 amazon rabbit

agentSendLogMessage  "Running jar installer"
sudo java -jar cco-installer.jar conn_broker-response.xml

agentSendLogMessage  "Running rabbit_config.sh"
sudo /usr/local/osmosix/bin/rabbit_config.sh

# Use "?" as sed delimiter to avoid escaping all the slashes
sudo sed -i -e "s?dnsName=?dnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/osmosix/etc/gateway_config.properties
sudo sed -i -e "s?gatewayHost=?gatewayHost=${CliqrTier_cco_PUBLIC_IP}?g" /usr/local/tomcatgua/webapps/access/WEB-INF/gua.properties

sudo /etc/init.d/guacd start
sudo -E /etc/init.d/tomcatgua restart

# Source profile to ensure pick up the JAVA_HOME env variable.
# . /etc/profile
# sudo -E /etc/init.d/rabbitmq-server restart


sudo sudo mv ~/cliqr.repo /etc/yum.repos.d/