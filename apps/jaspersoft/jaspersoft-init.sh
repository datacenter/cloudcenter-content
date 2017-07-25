#!/bin/bash -x
exec > >(tee -a /var/tmp/jaspesoft-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.
sudo yum install -y tomcat postgresql postgresql-server unzip openjdk java-1.8.0-openjdk-devel

#Configure Postgres for TCP and password access
sudo postgresql-setup initdb
#sudo sed -i.bak \
#-e 's/127.0.0.1\/32          ident/127.0.0.1\/32          md5/' \
#-e 's/::1\/128               ident/::1\/128               md5/' \
#/var/lib/pgsql/data/pg_hba.conf
sudo sed -i.bak -e "s%ident%md5%g" /var/lib/pgsql/data/pg_hba.conf
sudo systemctl start postgresql
sudo systemctl enable postgresql
sleep 5
#Give password to default postgres user to allow password-based login from Jasper
sudo su - -c "psql -c \"alter user postgres password 'postgres'\"" postgres

# https://iweb.dl.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.4.0/TIB_js-jrs-cp_6.4.0_bin.zip
cd /tmp
curl -o jasper.zip "${jasper_installer}"
unzip jasper.zip
sudo mv jasperreports-server-cp-6.4.0-bin /opt
rm -f jasper.zip
# sudo tar xvf $jasperPackage -C /opt/
#sudo rm -f $jasperPackage

# -e 's/# appServerDir = \/home/appServerDir = \/home/' \
#Configure Jasper Server for Tomcat and Postgres prior to build
sed -e 's%appServerDir = C:%# appServerDir = C:%g' \
-e 's/# CATALINA_HOME = \/usr\/share\/tomcat8/CATALINA_HOME = \/usr\/share\/tomcat/' \
-e 's/# CATALINA_BASE = \/var\/lib\/tomcat8/CATALINA_BASE = \/var\/lib\/tomcat/' \
/opt/jasperreports-server-cp-6.4.0-bin/buildomatic/sample_conf/postgresql_master.properties > tmp
sudo mv tmp /opt/jasperreports-server-cp-6.4.0-bin/buildomatic/default_master.properties

#Build and Install Jasper Server
agentSendLogMessage "Building JasperServer"
cd /opt/jasperreports-server-cp-6.4.0-bin/buildomatic/
sudo ./js-install-ce.sh minimal
agentSendLogMessage "Starting Tomcat. JasperServer will run at :8080/jasperserver/"
sudo systemctl enable tomcat
sudo systemctl start tomcat
# sudo /etc/init.d/tomcat start
#https://downloads.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.3.0/jasperreports-server-cp-6.3.0-linux-x64-installer.run?r=http%3A%2F%2Fcommunity.jaspersoft.com%2Fproject%2Fjasperreports-server%2Freleases&ts=1486080002&use_mirror=pilotfiber
# https://superb-dca2.dl.sourceforge.net/project/jasperserver/JasperServer/JasperReports%20Server%20Community%20Edition%206.4.0/TIB_js-jrs-cp_6.4.0_linux_x86.run


sudo mv ~/cliqr.repo /etc/yum.repos.d/
