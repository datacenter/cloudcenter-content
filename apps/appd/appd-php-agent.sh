#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
exec > >(tee -a /var/tmp/appd-php-agent-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

appd_controller_ip="172.16.204.34"
appd_controller_http_port="8090"
appd_access_key="281c9d49-f465-426f-ab92-ba1c983d434d"
agentUrl="http://172.16.201.244:8081/artifactory/appd/download-file/php-rpm/4.3.3.4/appdynamics-php-agent.x86_64.rpm"

docker_running=false
apache_use_docker=false

docker ps
if [ $? -eq 0 ]; then
    docker_running=true
fi

if [ "${docker_running}" == true ]; then
    docker ps | grep apache
    if [ $? == 0 ]; then
        apache_use_docker=true
    fi
fi

if [ "${apache_use_docker}" == true ]; then
    agentSendLogMessage "Using docker for apache"
    agentUrl="http://172.16.201.244:8081/artifactory/appd/download-file/php-tar/4.3.3.4/appdynamics-php-agent-x64-linux-4.3.3.4.tar.bz2"
    agentInstallPath="/opt/appdynamics/php-agent"
    agentDownloadPath="/tmp/agent.tar.bz"
    container_name=`sudo docker ps | awk '{ print $1 }' | tail -n1`

    agentSendLogMessage "Installing PHP CLI."

    sudo docker exec ${container_name} apt-get update
    sudo docker exec ${container_name} apt-get install -y php5-cli
    sudo docker exec ${container_name} mkdir -p ${agentInstallPath}

    agentSendLogMessage "Downloading the AppDynamics PHP Agent from ${agentUrl}."
    sudo docker exec ${container_name} curl -o ${agentDownloadPath} ${agentUrl}

    agentSendLogMessage "Extracting agent to ${agentInstallPath}"
    sudo docker exec ${container_name} tar -xvjf ${agentDownloadPath} -C ${agentInstallPath}
    sudo docker exec ${container_name} rm -f ${agentDownloadPath}
    sudo docker exec ${container_name} chown -R www-data:www-data ${agentInstallPath}
    sudo docker exec ${container_name} chmod -R 755 ${agentInstallPath}/appdynamics-php-agent/logs
    sudo docker exec ${container_name} chmod 777 ${agentInstallPath}/appdynamics-php-agent/logs

    agentSendLogMessage "Installing the AppDynamics PHP Agent."
    sudo docker exec ${container_name} ${agentInstallPath}/appdynamics-php-agent/install.sh \
    -a=customer1@${appd_access_key} ${appd_controller_ip} ${appd_controller_http_port} \
    ${parentJobName} ${cliqrAppTierName} ${cliqrNodeHostname}

    agentSendLogMessage "The agent files are installed in ${agentInstallPath}."

    agentSendLogMessage "Restarting apache-php container ${container_name}"
    sudo docker restart ${container_name}


else
    agentSendLogMessage "Not using docker."
    agentSendLogMessage "Installing PHP CLI."
    sudo yum install -y php-cli

    export APPD_CONF_CONTROLLER_HOST=${appd_controller_ip}
    export APPD_CONF_CONTROLLER_PORT=${appd_controller_http_port}
    export APPD_CONF_APP=${parentJobName}
    export APPD_CONF_TIER=${cliqrNodeHostname}
    export APPD_CONF_ACCESS_KEY=${appd_access_key}


    cd /tmp
    agentSendLogMessage "Downloading the AppDynamics PHP Agent from ${agentUrl}."
    curl -o appdynamics-php-agent.rpm ${agentUrl}
    agentSendLogMessage "Installing the AppDynamics PHP Agent."
    sudo -E rpm -i appdynamics-php-agent.rpm
    agentSendLogMessage "Restarting apache"
    sudo systemctl restart httpd
    rm -f appdynamics-php-agent.rpm
fi