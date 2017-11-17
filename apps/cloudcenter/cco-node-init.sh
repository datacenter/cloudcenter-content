#!/bin/bash -x
exec > >(tee -a /var/tmp/cco-node-init_$$.log) 2>&1

# . /usr/local/osmosix/etc/.osmosix.sh
# TODO: fix this so that it comes from env variable.
OSMOSIX_CLOUD="vmware"
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

check_error()
{
        status=$1
        msg=$2
        exit_status=$3

        if [[ ${status} -ne 0 ]]; then
                agentSendLogMessage "${msg}"
                exit ${exit_status}
        fi

        return 0
}

dlFile () {
    agentSendLogMessage  "Attempting to download $1"
    if [ -n "$dlUser" ]; then
        agentSendLogMessage  "Found user ${dlUser} specified. Using that and specified password for download auth."
        wget --no-check-certificate --user $dlUser --password $dlPass $1
    else
        agentSendLogMessage  "Didn't find username specified. Downloading with no auth."
        wget --no-check-certificate $1
    fi
    if [ "$?" = "0" ]; then
        agentSendLogMessage  "$1 downloaded"
    else
        agentSendLogMessage  "Error downloading $1"
        exit 1
    fi
}

agentSendLogMessage "Username: $(whoami)" # Should execute as cliqruser
agentSendLogMessage "Working Directory: $(pwd)"

# agentSendLogMessage  "Installing OS Prerequisits wget vim java-1.8.0-openjdk nmap"
sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.
sudo mv /usr/local/osmosix/etc/userenv ~ # Move it back at end of script.

#sudo yum update -y
#sudo yum install -y wget
#sudo yum install -y vim
#sudo yum install -y java-1.8.0-openjdk
sudo yum install -y nmap # Used below to check AMQP for open port.

# Download necessary files
cd /tmp
agentSendLogMessage  "Downloading installer files."
dlFile ${baseUrl}/installer/core_installer.bin
dlFile ${baseUrl}/appliance/cco-installer.jar
dlFile ${baseUrl}/appliance/cco-response.xml

# Set custom repo if desired
if [ -n "$cc_custom_repo" ]; then
    agentSendLogMessage  "Setting custom repo to ${cc_custom_repo}"
    export CUSTOM_REPO=${cc_custom_repo}
fi

# Remove list of installed modules residual from worker installer.
sudo rm -f /etc/cliqr_modules.conf

# Install packages not present in cliqr repo.
#sudo yum install -y python-setuptools
#sudo yum install -y jbigkit-libs

sudo chmod +x core_installer.bin
agentSendLogMessage  "Running core installer"
sudo -E ./core_installer.bin centos7 ${OSMOSIX_CLOUD} cco

agentSendLogMessage  "Running jar installer"
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-8-sun/bin/java 1
sudo java -jar cco-installer.jar cco-response.xml


# Use "?" as sed delimiter to avoid escaping all the slashes
#sudo sed -i -e "s?host=?host=${CliqrTier_amqp_PUBLIC_IP}?g" /usr/local/osmosix/etc/rev_connection.properties
#sudo sed -i -e "s?brokerHost=?brokerHost=${CliqrTier_amqp_PUBLIC_IP}?g" \
# -e "s?gateway.cluster.addresses=?gateway.cluster.addresses=${CliqrTier_amqp_PUBLIC_IP}:5671?g" \
# /usr/local/tomcat/webapps/ROOT/WEB-INF/rabbit-gateway.properties
#sed -i -e "s?cco.log.elkHost=?cco.log.elkHost=${CliqrTier_monitor_PUBLIC_IP}?g" \
#/usr/local/tomcat/webapps/ROOT/WEB-INF/gateway.properties

sudo /usr/local/osmosix/bin/cco_config_cli.sh amqp_server ${CliqrTier_amqp_PUBLIC_IP} 5671



agentSendLogMessage  "Waiting for AMQP to start."
COUNT=0
MAX=50
SLEEP_TIME=5
ERR=0

until $(nmap -p 5671 "${CliqrTier_amqp_PUBLIC_IP}" | grep "open" -q); do
  sleep ${SLEEP_TIME}
  let "COUNT++"
  echo $COUNT
  if [ $COUNT -gt 50 ]; then
    ERR=1
    break
  fi
done

# Remove these two unsupported properties in the tomcat env config file.
# sed -i.bak -e 's$ -XX:PermSize=512m -XX:MaxPermSize=512m$$g' /usr/local/tomcat/bin/setenv.sh

if [ $ERR -ne 0 ]; then
    agentSendLogMessage "Failed to find port 5671 on AMQP Server ${CliqrTier_amqp_PUBLIC_IP} after about 5 min. Skipping tomcat restart."
else
    agentSendLogMessage "Found port 5671 on AMQP Server ${CliqrTier_amqp_PUBLIC_IP}. Restarting tomcat and clearing log file."
    sudo systemctl start cco
    # Source profile to ensure pick up the JAVA_HOME env variable.
#    . /etc/profile
#    sudo -E /etc/init.d/mongod start
#    sudo -E /etc/init.d/tomcat stop
#    sudo rm /usr/local/tomcat/logs/osmosix.log
#    # sudo su -c 'echo "" > /usr/local/tomcat/logs/osmosix.log'
#    sudo -E /etc/init.d/tomcat start
fi

rm -f core_installer.bin
rm -f cco-installer.jar
rm -f cco-response.xml

sudo mv ~/userenv /usr/local/osmosix/etc/
sudo mv ~/cliqr.repo /etc/yum.repos.d/


