#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
exec > >(tee -a /var/tmp/appd-database-agent-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

#appd_controller_ip="172.16.204.34"
#appd_controller_http_port="8090"
#appd_access_key="281c9d49-f465-426f-ab92-ba1c983d434d"
# agentUrl="http://172.16.201.244:8081/artifactory/appd/download-file/php-rpm/4.3.3.4/appdynamics-php-agent.x86_64.rpm"

db_agent_home="/opt/appdynamics/db_agent"

sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.

sudo yum install -y unzip java-1.8.0-openjdk

cd /tmp
curl -o appd_db.zip  "http://172.16.201.244:8081/artifactory/appd/download-file/db/4.3.4.1/dbagent-4.3.4.1.zip"

sudo unzip appd_db.zip -d ${db_agent_home}

sudo sed -i.bak -e "s%<controller-host>%<controller-host>${appd_controller_ip}%g" \
-e "s%<controller-port>%<controller-port>${appd_controller_http_port}%g" \
-e "s%<account-access-key>%<account-access-key>${appd_access_key}%g" \
${db_agent_home}/conf/controller-info.xml

java -Ddbagent.name="DB Agent ${parentJobName}" -jar ${db_agent_home}/db-agent.jar


sudo mv ~/cliqr.repo /etc/yum.repos.d/




#
#agentSendLogMessage "Installing PHP CLI."
#sudo yum install -y php-cli
#
#export APPD_CONF_CONTROLLER_HOST=${appd_controller_ip}
#export APPD_CONF_CONTROLLER_PORT=${appd_controller_http_port}
#export APPD_CONF_APP=${parentJobName}
#export APPD_CONF_TIER=${cliqrNodeHostname}
#export APPD_CONF_ACCESS_KEY=${appd_access_key}
#
#
#cd /tmp
#agentSendLogMessage "Downloading the AppDynamics PHP Agent from ${agentUrl}."
#curl -o appdynamics-php-agent.rpm ${agentUrl}
#agentSendLogMessage "Installing the AppDynamics PHP Agent."
#sudo -E rpm -i appdynamics-php-agent.rpm
#agentSendLogMessage "The agent files are installed in opt/appdynamics/machine-agent and the agent is added as a service."
#rm -f appdynamics-php-agent.rpm