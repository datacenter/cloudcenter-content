#!/bin/bash -x
exec > >(tee -a /var/tmp/jaspesoft-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh


sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.


agentSendLogMessage "Doing yum update"
sudo yum update -y
#pre_reqs="tomcat postgresql postgresql-server unzip java-1.8.0-openjdk java-1.8.0-openjdk-devel"
#agentSendLogMessage "Installing pre-reqs: ${pre_reqs}"
#sudo yum install -y ${pre_reqs}




sudo mv ~/cliqr.repo /etc/yum.repos.d/
