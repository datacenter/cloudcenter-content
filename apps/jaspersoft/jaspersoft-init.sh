#!/usr/bin/env bash
set -x
exec > >(tee -a /var/tmp/jaspersoft-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

echo "Username: $(whoami)" # Should execute as cliqruser
echo "Working Directory: $(pwd)"

defaultGitTag="jaspersoft"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

sudo yum install tomcat postgresql postgresql-server -y

#Configure Postgres for TCP and password access
sudo service postgresql initdb
sudo sed -i.bak \
-e 's/127.0.0.1\/32          ident/127.0.0.1\/32          md5/' \
-e 's/::1\/128               ident/::1\/128               md5/' \
/var/lib/pgsql/data/pg_hba.conf
sudo service postgresql start
sleep 5
#Give password to default postgres user to allow password-based login from Jasper
sudo su - -c "psql -c \"alter user postgres password 'postgres'\"" postgres


sudo tar xvf $jasperPackage -C /opt/
#sudo rm -f $jasperPackage

#Configure Jasper Server for Tomcat and Postgres prior to build
sudo sed -e 's/appServerDir = C:/# appServerDir = C:/' \
-e 's/# appServerDir = \/home/appServerDir = \/home/' \
-e 's/# CATALINA_HOME = \/usr\/share\/tomcat6/CATALINA_HOME = \/usr\/share\/tomcat/' \
-e 's/# CATALINA_BASE = \/var\/lib\/tomcat6/CATALINA_BASE = \/var\/lib\/tomcat/' \
/opt/jasperreports-server-cp-6.1.1-bin/buildomatic/sample_conf/postgresql_master.properties > /opt/jasperreports-server-cp-6.1.1-bin/buildomatic/default_master.properties

#Build and Install Jasper Server
cd /opt/jasperreports-server-cp-6.1.1-bin/buildomatic/
sudo ./js-install-ce.sh minimal
sudo /etc/init.d/tomcat start
#https://downloads.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.3.0/jasperreports-server-cp-6.3.0-linux-x64-installer.run?r=http%3A%2F%2Fcommunity.jaspersoft.com%2Fproject%2Fjasperreports-server%2Freleases&ts=1486080002&use_mirror=pilotfiber
# https://superb-dca2.dl.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.4.0/TIB_js-jrs-cp_6.4.0_linux_x86.run