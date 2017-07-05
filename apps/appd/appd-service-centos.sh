#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
exec > >(tee -a /var/tmp/appd-service-centos-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

cd /tmp
agentUrl="https://download-files.appdynamics.com/download-file/machine/4.3.3.4/appdynamics-machine-agent-4.3.3.4-1.x86_64.rpm"
agentSendLogMessage "Downloading the AppDynamics Machine Agent from ${agentUrl}."
curl -o appdynamics-machine-agent.rpm ${agentUrl}
agentSendLogMessage "Installing the AppDynamics Machine Agent."
sudo rpm -ivh appdynamics-machine-agent.rpm
agentSendLogMessage "The agent files are installed in opt/appdynamics/machine-agent and the agent is added as a service."

sudo sed -E "s%<controller-host>%<controller-host>172.16.204.22%g" \
/etc/appdynamics/machine-agent/controller-info.xml

sudo systemctl start appdynamics-machine-agent