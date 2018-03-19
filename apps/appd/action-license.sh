#!/bin/bash -x
exec > >(tee -a /var/tmp/action-license_$$.log) 2>&1

. /usr/local/osmosix/service/utils/agent_util.sh

agentSendLogMessage "Copying license file"
echo "${action_appd_license}" > /home/appduser/AppDynamics/Controller/license.lic

agentSendLogMessage "Stopping Controller. This will take a few minutes"
/home/appduser/AppDynamics/Controller/bin/stopController.sh

agentSendLogMessage "Starting Controller. This will take a a few minutes"
/home/appduser/AppDynamics/Controller/bin/startController.sh

agentSendLogMessage "License applied and controller restarted"
