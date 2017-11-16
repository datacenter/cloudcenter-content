#!/bin/bash -x

OSSVC_HOME=/usr/local/osmosix/service
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. $OSSVC_HOME/utils/cfgutil.sh
. $OSSVC_HOME/utils/install_util.sh
. $OSSVC_HOME/utils/os_info_util.sh


sed -i '/jdbc.url/c\jdbc.url=jdbc:mysql://'"$CliqrTier_Database_PUBLIC_IP"'/petclinic' /usr/local/tomcat6/webapps/ROOT/WEB-INF/classes/jdbc.properties
