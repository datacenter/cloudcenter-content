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

sudo mv /etc/yum.repos.d/cliqr.repo ~
sudo yum install -y wget vim java-1.8.0-openjdk nmap
sudo sudo mv ~/cliqr.repo /etc/yum.repos.d/

# Download necessary files
wget --no-check-certificate -O core_installer.bin --user $dlUser --password $dlPass https://download.cliqr.com/release-4.7.0-20170105.3/installer/core_installer.bin
wget --no-check-certificate -O ccm-installer.jar --user $dlUser --password $dlPass 	https://download.cliqr.com/release-4.7.0-20170105.3/appliance/ccm-installer.jar
wget --no-check-certificate -O ccm-response.xml --user $dlUser --password $dlPass https://download.cliqr.com/release-4.7.0-20170105.3/appliance/ccm-response.xml

sudo chmod +x core_installer.bin
sudo ./core_installer.bin centos7 amazon ccm
java -jar ccm-installer.jar ccm-response.xml


# Use "?" as sed delimiter to avoid escaping all the slashes
sed -i -e "s?publicDnsName=<mgmtserver_public_dns_name>?publicDnsName=${CliqrTier_ccm_PUBLIC_IP}?g" /usr/local/tomcat/webapps/ROOT/WEB-INF/server.properties

sudo /etc/init.d/tomcat stop
rm -f /usr/local/tomcat/catalina.pid
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

#TODO Move all this to External Post-Start
sudo yum install python-pip -y
sudo pip install --upgrade pip
sudo pip install requests
wget -N https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/apps/cloudcenter/ccm-config.py -O ccm-config.py
if [ $? -ne 0 ]; then
    agentSendLogMessage  "Failed downloading https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/apps/cloudcenter/ccm-config.py. You can still perform the post-install UI configuration manually."
fi

python ccm-config.py

if [ $? -ne 0 ]; then
    agentSendLogMessage  "Failed executing ccm-config.py. You can still perform the post-install UI configuration manually."
fi