#!/bin/bash -x
exec > >(tee -a /var/tmp/jaspesoft-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# In case you need to open the postgres port on CCM in order to pull data:
# iptables -I INPUT 1 -d 0.0.0.0/0  -j ACCEPT -p tcp --dport 5432

sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.
pre_reqs="tomcat postgresql postgresql-server unzip openjdk java-1.8.0-openjdk-devel"
agentSendLogMessage "Installing pre-reqs: ${pre_reqs}"
sudo yum install -y ${pre_reqs}

#Configure Postgres for TCP and password access
sudo postgresql-setup initdb

# Change identification to password.
sudo sed -i.bak -e "s%ident%md5%g" /var/lib/pgsql/data/pg_hba.conf

agentSendLogMessage "Starting Postgres"
sudo systemctl start postgresql
sudo systemctl enable postgresql
sleep 5
#Give password to default postgres user to allow password-based login from Jasper
sudo su - -c "psql -c \"alter user postgres password 'postgres'\"" postgres

# Can download bin.zip from https://iweb.dl.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.4.0/TIB_js-jrs-cp_6.4.0_bin.zip
cd /tmp
jasper_file="jasper.zip"
curl -o ${jasper_file} "${jasper_installer}"

# This gets the name of the root folder inside the zip from the output of the unzip command for later use.
jasper_folder=`unzip ${jasper_file} | head -n2 | tail -n1 | awk '{print $2}'`

sudo mv ${jasper_folder} /opt
rm -f ${jasper_file}

# Copy postgreq config example to build config file.
sudo cp /opt/${jasper_folder}buildomatic/sample_conf/postgresql_master.properties /opt/${jasper_folder}buildomatic/default_master.properties

# Append properties to build config file and comment unneeded line
echo "CATALINA_HOME = /usr/share/tomcat" >> /opt/${jasper_folder}buildomatic/default_master.properties
echo "CATALINA_BASE = /var/lib/tomcat" >> /opt/${jasper_folder}buildomatic/default_master.properties
sed -i.bak -e 's%^appServerDir%# appServerDir%g' /opt/${jasper_folder}buildomatic/default_master.properties

#Build and Install Jasper Server
agentSendLogMessage "Building JasperServer"
cd /opt/${jasper_folder}buildomatic/
sudo ./js-install-ce.sh minimal

agentSendLogMessage "Starting Tomcat. JasperServer will run at :8080/jasperserver/"
sudo systemctl enable tomcat
sudo systemctl start tomcat

agentSendLogMessage  "Waiting for server to start."
COUNT=0
MAX=50
SLEEP_TIME=5
ERR=0

ip_variable_name="CliqrTier_${cliqrAppTierName}_PUBLIC_IP"

until curl "http://${!ip_variable_name}:8080/jasperserver/" -k -m 5 ; do
  sleep ${SLEEP_TIME}
  let "COUNT++"
  echo ${COUNT}
  if [ ${COUNT} -gt 50 ]; then
    ERR=1
    break
  fi
done
if [ ${ERR} -ne 0 ]; then
    agentSendLogMessage "Failed to start server after about 5 minutes"
else
    agentSendLogMessage "Server Started."
fi


sudo mv ~/cliqr.repo /etc/yum.repos.d/
