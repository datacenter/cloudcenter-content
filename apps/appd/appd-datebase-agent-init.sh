#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
exec > >(tee -a /var/tmp/appd-database-agent-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

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

echo '
#!/bin/bash -x
exec > >(tee -a /var/tmp/appd-database-agent-startup_$$.log) 2>&1
. /usr/local/osmosix/etc/userenv

db_agent_home="/opt/appdynamics/db_agent"

java -Ddbagent.name="DB Agent ${parentJobName}" -jar ${db_agent_home}/db-agent.jar
' > run_db_agent.sh

echo "
[Unit]
Description=AppDDBagentprocess
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/root/run_db_agent.sh
" > appd-db-agent.service

sudo mv run_db_agent.sh /root/
sudo mv appd-db-agent.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable appd-db-agent
sudo systemctl start appd-db-agent.service

sudo mv ~/cliqr.repo /etc/yum.repos.d/
