#!/bin/bash -x
exec > >(tee -a /var/tmp/cco-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh
cd ~

env

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag=master"
     gitTag="cc-from-appliances"
fi

sudo yum install nmap -y

# Use "?" as sed delimiter to avoid escaping all the slashes
sudo sed -i -e "s?host=?host=${CliqrTier_amqp_PUBLIC_IP}?g" /usr/local/osmosix/etc/rev_connection.properties
sudo sed -i -e "s?brokerHost=?brokerHost=${CliqrTier_amqp_PUBLIC_IP}?g" \
 -e "s?gateway.cluster.addresses=?gateway.cluster.addresses=${CliqrTier_amqp_PUBLIC_IP}:5671?g" \
 /usr/local/tomcat/webapps/ROOT/WEB-INF/rabbit-gateway.properties

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
if [ $ERR -ne 0 ]; then
    agentSendLogMessage "Failed to find port 5671 on AMQP Server ${CliqrTier_amqp_PUBLIC_IP} after about 5 min. Skipping tomcat restart."
else
    agentSendLogMessage "Found port 5671 on AMQP Server ${CliqrTier_amqp_PUBLIC_IP}. Restarting tomcat and clearing log file."

    # Source profile to ensure pick up the JAVA_HOME env variable.
    . /etc/profile
    sudo -E /etc/init.d/tomcat stop
    sudo su -c 'echo "" > /usr/local/tomcat/logs/osmosix.log'
    sudo -E /etc/init.d/tomcat start
fi



