#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
exec > >(tee -a /var/tmp/appd-service-centos-init_$$.log) 2>&1

. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/agent_util.sh

appd_controller_ip="172.16.204.34"
appd_controller_http_port="8090"
appd_access_key="281c9d49-f465-426f-ab92-ba1c983d434d"
agentUrl="http://172.16.201.244:8081/artifactory/appd/download-file/machine/4.3.3.4/appdynamics-machine-agent-4.3.3.4-1.x86_64.rpm"

cd /tmp
agentSendLogMessage "Downloading the AppDynamics Machine Agent from ${agentUrl}."
curl -o appdynamics-machine-agent.rpm ${agentUrl}
agentSendLogMessage "Installing the AppDynamics Machine Agent."
sudo rpm -ivh appdynamics-machine-agent.rpm
agentSendLogMessage "The agent files are installed in opt/appdynamics/machine-agent and the agent is added as a service."
rm -f appdynamics-machine-agent.rpm

# Note that Service Visibility (sim-enabled) won't work without a license, even
# if enabled.
sudo sed -i.bak -e "s%<controller-host>%<controller-host>${appd_controller_ip}%g" \
-e "s%<controller-port>%<controller-port>${appd_controller_http_port}%g" \
-e "s%<account-access-key>%<account-access-key>${appd_access_key}%g" \
-e "s%<sim-enabled>false%<sim-enabled>true%g" \
/opt/appdynamics/machine-agent/conf/controller-info.xml

sudo systemctl start appdynamics-machine-agent
