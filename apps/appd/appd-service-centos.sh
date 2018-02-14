#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.

while getopts ":h:u:p:n:i:o:" opt; do
  case $opt in
    h)
        appd_controller_ip=$OPTARG
      ;;
    u)
        agentUrl=$OPTARG
      ;;
    p)
        appd_controller_http_port=$OPTARG
      ;;
    n)
        appd_access_key=$OPTARG
      ;;
    o)
        cmd=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

exec > >(tee -a /var/tmp/appd-service-centos-init_$$.log) 2>&1

. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/agent_util.sh

#appd_controller_ip="10.36.60.51"
#appd_controller_http_port="8090"
#appd_access_key="6c65a39a-78e5-42ec-a183-70e3fb2483fc"
#agentUrl="http://10.36.60.58:8081/artifactory/appd/download-file
#/machine/4.3.3.4/appdynamics-machine-agent-4.3.8.4-1.x86_64.rpm"
# ./test.sh -h 10.36.60.51 -u http://10.36.60.58:8081/artifactory/appd/download-file/machine/4.3.3.4/appdynamics-machine-agent-4.3.8.4-1.x86_64.rpm -p 8090 -

case ${cmd} in
    add)
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
        ;;
    remove)
        ;;
    *)
        ;;
esac

