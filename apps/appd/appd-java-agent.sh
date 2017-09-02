#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
exec > >(tee -a /var/tmp/appd-java-agent_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

appd_controller_ip="172.16.204.34"
appd_controller_http_port="8090"
appd_access_key="281c9d49-f465-426f-ab92-ba1c983d434d"
agentUrl="http://172.16.201.244:8081/artifactory/appd/download-file/sun-jvm/4.3.5.7/AppServerAgent-4.3.5.7.zip"
tomcat_user="cliqruser"
homedir=`getent passwd ${tomcat_user} | cut -d: -f6`

prereqs="unzip"
agentSendLogMessage  "Installing OS Prerequisits ${prereqs}"
sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.
sudo yum install -y ${prereqs}

agent_home="/opt/appdynamics/appagent"
agent_file="appdynamics-java-agent.zip"
sudo mkdir -p ${agent_home}
sudo chown -R ${tomcat_user}:${tomcat_user} ${agent_home}

cd /tmp
agentSendLogMessage "Downloading the AppDynamics Java Agent from ${agentUrl}."
curl -o ${agent_file} ${agentUrl}

agentSendLogMessage "Extracting the agent to ${agent_home} and deleting the downloaded file."
unzip ${agent_file} -d ${agent_home}
rm -f ${agent_file}

sudo sed -i.bak -e "s%<controller-host>%<controller-host>${appd_controller_ip}%g" \
-e "s%<controller-port>%<controller-port>${appd_controller_http_port}%g" \
-e "s%<account-access-key>%<account-access-key>${appd_access_key}%g" \
-e "s%<application-name>%<application-name>${parentJobName}%g" \
-e "s%<tier-name>%<tier-name>${cliqrAppTierName}%g" \
-e "s%<node-name>%<node-name>${cliqrNodeHostname}%g" \
/opt/appdynamics/appagent/conf/controller-info.xml

agentSendLogMessage "Adding agent to CATALINA_OPTS in .bash_profile so it attaches when Tomcat starts."
echo "AGENT_HOME=${agent_home}" >> ${homedir}/.bash_profile
echo 'export CATALINA_OPTS="${CATALINA_OPTS} -javaagent:${AGENT_HOME}/javaagent.jar"' >> ${homedir}/.bash_profile

agentSendLogMessage "Attaching agent to running Tomcat process."
java_pid=`ps aux | grep tomcat | head -n1 | awk '{print $2}'`
java -Xbootclasspath/a:${JAVA_HOME}/lib/tools.jar -jar ${agent_home}/javaagent.jar ${java_pid}

sudo mv ~/cliqr.repo /etc/yum.repos.d/