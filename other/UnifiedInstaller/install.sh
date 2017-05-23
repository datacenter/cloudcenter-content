#!/bin/bash
#echo "Please enter the Version that you wish to install"
#read version
echo "Please enter the component that you wish to install(ccm, cco, rabbit)"
read COMPONENT
#echo "Please enter the Cloud where you will be performing the install(amazon,azure,azurerm,azurepack,bracket,cloudn,cloudstack,google,opsource,openstack,rackspace,softlayer,vmware,vcd)"
#read CLOUD
#echo "Please enter CCM IP address"
#read CCM_IP
#echo "Please enter CCO IP address"
#read CCO_IP
#echo "Please enter AMQP/RabbitMQ Server IP Address"
#read AMQP_IP
#echo "Enter the OS Type (centos7, centos6, rhel6, rhel7, ubuntu1204)"
#read OS
#echo "Please enter the username used for downloading the artifacts"
#read USERNAME
#echo "Please enter the password used for downloading the artifacts"
#read PASSWORD
export CLOUD="amazon"
export OS="centos7"
export CCM_IP="X.X.X.X"
export CCO_IP="X.X.X.X"
export AMQP_IP="X.X.X.X"
export version="4.8.0"
export USERNAME="ciscoaci"
export PASSWORD="xxxxxxxxxxx"

#if [[ "$COMPONENT" = "CCM" || "$COMPONENT" = "ccm" ]]; then
#  echo "Enter the DB type that you wish to install (mysql, mariadb)"
#  read db
#  if [ $db = 'mysql' ]; then
#    export DB_TYPE=$db
#  elif [ $db = 'mariadb' ]; then
#    export DB_TYPE=mariadb
#  else
#    echo "No such DB exists"
#  fi
#else
#  echo "The component is CCM"
#fi

function install_os {
   case $OS in
   (centos7|centos6|rhel6|rhel7)
	yum install -y wget
	yum install -y vim
	;;
   (ubuntu1204)
	apt-get install wget
	apt-get install vim
	;;
   (*)
	echo "The OS name entered is not supported. Please use either Centos6 / Centos7 / RHEL6 / RHEL7 / Ubuntu12"
	;;
   esac
}

function ccm_install {
  touch /tmp/ccm_init.log
  echo "Working on Core Installer" >> /tmp/ccm_init.log
  cd /tmp/
  chmod +x core_installer.bin
  echo "Executing the core installer" >> /tmp/ccm_init.log
  echo $OS >> /tmp/ccm_init.log
  echo $CLOUD >> /tmp/ccm_init.log
  bash ./core_installer.bin $OS $CLOUD $COMPONENT >> /tmp/ccm_init.log
  source /etc/profile
  echo "Installation complete of core installer and setting path" >> /tmp/ccm_init.log
  echo "Importing the Certificates" >> /tmp/ccm_init.log
  cd /tmp/
  mkdir -p /usr/local/osmosix/ssl
  cd /usr/local/osmosix/ssl
  jar xf /tmp/certs.zip ccm
  chown -R cliqruser /usr/local/osmosix/ssl
  cd /usr/local/tomcat/conf/ssl
  rm -f .keystore
  rm -f .truststore
  rm -f mgmtserver.crt
  rm -f mgmtserver.key
  rm -f ca.crt
  ln -s /usr/local/osmosix/ssl/ccm/ccm_keystore.jks .keystore
  ln -s /usr/local/osmosix/ssl/ccm/ca_truststore.jks .truststore
  ln -s /usr/local/osmosix/ssl/ccm/ccm.crt mgmtserver.crt
  ln -s /usr/local/osmosix/ssl/ccm/ccm.key mgmtserver.key
  ln -s /usr/local/osmosix/ssl/ccm/ca_root.crt ca.crt
  echo "Working the Rest of the Installer" >> /tmp/ccm_init.log
  cd /tmp/
  java -jar ccm-installer.jar ccm-response.xml >> /tmp/ccm_init.log
  echo "Installation complete. Proceeding with the configuration of the CCM machine" >> /tmp/ccm_init.log
  cd /usr/local/tomcat/webapps/ROOT/WEB-INF
  sed -i -e "s/<mgmtserver_public_dns_name>/${CCM_IP}/" server.properties
  chown -H -R cliqruser:cliqruser /usr/local/tomcat/
  echo "Everything is complete. Initializing the Reboot of the system" >> /tmp/ccm_init.log
  export INTERACTIVE=false
#  /usr/local/osmosix/bin/db_install_wizard.sh
  sleep 30
  sudo shutdown -r now
}

function cco_install {
  touch /tmp/cco_init.log
  echo "Working on Core Installer" >> /tmp/cco_init.log
  cd /tmp/
  chmod +x core_installer.bin
  echo "Executing the core installer" >> /tmp/cco_init.log
  echo $OS >> /tmp/cco_init.log
  echo $CLOUD >> /tmp/cco_init.log
  bash ./core_installer.bin $OS $CLOUD $COMPONENT >> /tmp/cco_init.log
  source /etc/profile
  echo "Installation complete of core installer and setting path" >> /tmp/cco_init.log
  echo "Importing the Certificates" >> /tmp/cco_init.log
  cd /tmp/
  mkdir -p /usr/local/osmosix/ssl
  cd /usr/local/osmosix/ssl
  jar xf /tmp/certs.zip cco
  cd /usr/local/tomcat/conf/ssl
  rm -f .keystore
  rm -f .truststore
  rm -f gateway.crt
  rm -f gateway.key
  rm -f ca.crt
  ln -s /usr/local/osmosix/ssl/cco/cco_keystore.jks .keystore
  ln -s /usr/local/osmosix/ssl/cco/ca_truststore.jks .truststore
  ln -s /usr/local/osmosix/ssl/cco/cco.crt gateway.crt
  ln -s /usr/local/osmosix/ssl/cco/cco.key gateway.key
  ln -s /usr/local/osmosix/ssl/cco/ca_root.crt ca.crt
  echo "Working the Rest of the Installer" >> /tmp/cco_init.log
  cd /tmp/
  java -jar $COMPONENT-installer.jar $COMPONENT-response.xml >> /tmp/cco_init.log
  echo "Installation completed, proceeding with the configuration" >> /tmp/cco_init.log
  GW_FILE='/usr/local/tomcat/webapps/ROOT/WEB-INF/gateway.properties'
  BROKER_FILE='/usr/local/osmosix/etc/rev_connection.properties'
  AMQP_FILE='/usr/local/tomcat/webapps/ROOT/WEB-INF/rabbit-gateway.properties'
  Set_Prop_Val()
	{
	  prop_file=$1
	  prop_name="$2"
	  prop_val="$3"

	  perl -pi -e "s|$prop_name=.*$|$prop_name=$prop_val|" $prop_file
	}
  echo "Updating the /usr/local/tomcat/webapps/ROOT/WEB-INF/rabbit-gateway.properties file with the data" >> /tmp/cco_init.log
	Set_Prop_Val $AMQP_FILE 'rabbit.gateway.brokerHost' $AMQP_IP
	cluster_addresses=$AMQP_IP:5671
	Set_Prop_Val $AMQP_FILE 'rabbit.gateway.cluster.addresses' $cluster_addresses
	echo "Updating the /usr/local/osmosix/etc/rev_connection.properties file with the data" >> /tmp/cco_init.log
	Set_Prop_Val $BROKER_FILE 'connection.broker.host' $AMQP_IP
	echo "Everything is complete. Initializing the Reboot of the System" >> /tmp/cco_init.log
	sleep 30
  sudo shutdown -r now
}

function amqp_install {
  touch /tmp/amqp_init.log
  cd /tmp/
  chmod +x core_installer.bin
  echo "Executing the core installer" >> /tmp/amqp_init.log
  echo $OS >> /tmp/amqp_init.log
  echo $CLOUD >> /tmp/amqp_init.log
  bash ./core_installer.bin $OS $CLOUD $COMPONENT >> /tmp/amqp_init.log
  source /etc/profile
  echo "Installation complete of core installer and setting path" >> /tmp/amqp_init.log
  cd /tmp/
  mkdir -p /usr/local/osmosix/ssl
  cd /usr/local/osmosix/ssl
  jar xf /tmp/certs.zip gua
  cd /usr/local/tomcatgua/conf/ssl
  rm -f .keystore
  rm -f .truststore
  rm -f gateway.crt
  rm -f gateway.key
  rm -f ca.crt
  ln -s /usr/local/osmosix/ssl/gua/gua_keystore.jks .keystore
  ln -s /usr/local/osmosix/ssl/gua/ca_truststore.jks .truststore
  ln -s /usr/local/osmosix/ssl/gua/gua.crt gateway.crt
  ln -s /usr/local/osmosix/ssl/gua/gua.key gateway.key
  ln -s /usr/local/osmosix/ssl/gua/ca_root.crt ca.crt
  echo "Working the Rest of the Installer" >> /tmp/amqp_init.log
  cd /tmp/
  java -jar cco-installer.jar conn_broker-response.xml >> /tmp/amqp_init.log
  echo "Installation completed, proceeding with the configuration" >> /tmp/amqp_init.log
  GW_CONFIG_FILE='/usr/local/osmosix/etc/gateway_config.properties'
  GUA_CONF='/usr/local/tomcatgua/webapps/access/WEB-INF/gua.properties'

  Set_Prop_Val()
  {
    prop_file=$1
    prop_name="$2"
    prop_val="$3"

    perl -pi -e "s|$prop_name=.*$|$prop_name=$prop_val|" $prop_file
  }

  echo "Updating the $GW_CONFIG_FILE file with the data" >> /tmp/amqp_init.log
  Set_Prop_Val $GW_CONFIG_FILE 'mgmtserver.dnsName' $CCM_IP

  echo "Updating the $GUA_CONF file with the data" >> /tmp/amqp_init.log
  Set_Prop_Val $GUA_CONF 'gatewayHost' $CCO_IP
  sudo bash /usr/local/osmosix/bin/rabbit_config.sh
  sudo shutdown -r now
}

case $version in
  (4.8.0)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.8.0-20170502.3/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.8.0-20170502.3/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.8.0-20170502.3/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.8.0-20170502.3/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.8.0-20170502.3/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.8.0-20170502.3/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.7.1)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.7.1-20170128.5/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.7.1-20170128.5/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.7.1-20170128.5/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.7.1-20170128.5/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.7.1-20170128.5/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.7.1-20170128.5/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.6.2)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.6.2-20161216.2/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.6.2-20161216.2/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.6.2-20161216.2/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.6.2-20161216.2/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.6.2-20161216.2/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.6.2-20161216.2/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.6.0)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.6.0-20161002.1/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.6.0-20161002.1/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.6.0-20161002.1/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.6.0-20161002.1/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.6.0-20161002.1/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.6.0-20161002.1/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.5.5)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.5.5-20160806.1/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.5.5-20160806.1/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.5.5-20160806.1/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.5.5-20160806.1/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.5.5-20160806.1/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.5.5-20160806.1/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.5.4)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.5.4-20160715.3/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.5.4-20160715.3/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.5.4-20160715.3/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.5.4-20160715.3/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.5.4-20160715.3/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.5.4-20160715.3/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.5.3)
  cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.5.3-20160623.3/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.5.3-20160623.3/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.5.3-20160623.3/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.5.3-20160623.3/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.5.3-20160623.3/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.5.3-20160623.3/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.5.2)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.5.2-20160609.3/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.5.2-20160609.3/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.5.2-20160609.3/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.5.2-20160609.3/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.5.2-20160609.3/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.5.2-20160609.3/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.5.1)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.5.1-20160505.1/installer/core_installer.bin'
    CCM_INSTALLER='http://download.cliqr.com/release-4.5.1-20160505.1/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.5.1-20160505.1/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.5.1-20160505.1/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.5.1-20160505.1/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.5.1-20160505.1/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
 (4.5.0)
    cd /tmp
    CORE_INSTALLER='http://download.cliqr.com/release-4.5-20160415.2/installer/core_installer.bin	'
    CCM_INSTALLER='http://download.cliqr.com/release-4.5-20160415.2/appliance/ccm-installer.jar'
    CCM_RESPONSE='http://download.cliqr.com/release-4.5-20160415.2/appliance/ccm-response.xml'
    CCO_INSTALLER='http://download.cliqr.com/release-4.5-20160415.2/appliance/cco-installer.jar'
    CCO_RESPONSE='http://download.cliqr.com/release-4.5-20160415.2/appliance/cco-response.xml'
    CONN_RESPONSE='http://download.cliqr.com/release-4.5-20160415.2/appliance/conn_broker-response.xml'
    CERTS='http://env.cliqrtech.com/deepak/certs.zip'
    ;;
  (4.3.1)
   cd /tmp
   CORE_INSTALLER='http://download.cliqr.com/release-4.3.1-20151201.1/installer/core_installer.bin'
   CCM_INSTALLER='http://download.cliqr.com/release-4.3.1-20151201.1/appliance/ccm-installer.jar'
   CCM_RESPONSE='http://download.cliqr.com/release-4.3.1-20151201.1/appliance/ccm-response.xml'
   CCO_INSTALLER='http://download.cliqr.com/release-4.3.1-20151201.1/appliance/cco-installer.jar'
   CCO_RESPONSE='http://download.cliqr.com/release-4.3.1-20151201.1/appliance/cco-response.xml'
   CONN_RESPONSE='http://download.cliqr.com/release-4.3.1-20151201.1/appliance/conn_broker-response.xml'
   CERTS='http://env.cliqrtech.com/deepak/certs.zip'
   ;;
  *)
    echo "The Version entered is not supported by the utility"
    ;;
esac

case "$COMPONENT" in
  (CCM|ccm)
    install_os
    wget --no-check-certificate -O core_installer.bin --user $USERNAME --password $PASSWORD $CORE_INSTALLER
    wget --no-check-certificate -O ccm-installer.jar --user $USERNAME --password $PASSWORD $CCM_INSTALLER
    wget --no-check-certificate -O ccm-response.xml --user $USERNAME --password $PASSWORD $CCM_RESPONSE
    wget --no-check-certificate -O certs.zip --user $USERNAME --password $PASSWORD $CERTS
    ccm_install
    ;;
  (CCO|cco)
    install_os
    wget --no-check-certificate -O core_installer.bin --user $USERNAME --password $PASSWORD $CORE_INSTALLER
    wget --no-check-certificate -O cco-installer.jar --user $USERNAME --password $PASSWORD $CCO_INSTALLER
    wget --no-check-certificate -O cco-response.xml --user $USERNAME --password $PASSWORD $CCO_RESPONSE
    wget --no-check-certificate -O certs.zip --user $USERNAME --password $PASSWORD $CERTS
    cco_install
    ;;
  (rabbit|RABBIT)
    install_os
    wget --no-check-certificate -O core_installer.bin --user $USERNAME --password $PASSWORD $CORE_INSTALLER
    wget --no-check-certificate -O cco-installer.jar --user $USERNAME --password $PASSWORD $CCO_INSTALLER
    wget --no-check-certificate -O conn_broker-response.xml --user $USERNAME --password $PASSWORD $CONN_RESPONSE
    wget --no-check-certificate -O certs.zip --user $USERNAME --password $PASSWORD $CERTS
    amqp_install
    ;;
  *)
    echo "Please enter component as either ccm / cco / rabbit"
      ;;
  esac
