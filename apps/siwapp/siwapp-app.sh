#!/bin/bash -x
exec > >(tee -a /var/tmp/apache-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# agentSendLogMessage $(env)

#---------Script Variables------------#
#siwapp_APP_PORT=$1

#---------DO NOT MODIFY BELOW------------#
sudo mv /etc/yum.repos.d/cliqr.repo ~

agentSendLogMessage "Starting app install script"
sudo yum -y update
sudo yum -y install git httpd php php-mysql php-xml php-mbstring
sudo yum clean all

sudo git clone https://github.com/siwapp/siwapp-sf1.git /var/www/html/

sudo mkdir /var/www/html/cache
sudo chmod 777 /var/www/html/cache
sudo chmod 777 /var/www/html/web/config.php
sudo chmod 777 /var/www/html/config/databases.yml

sudo mkdir /var/www/html/web/uploads
sudo chmod 777 /var/www/html/web/uploads

sudo chown -R apache:apache /var/www/html/

sudo sed -i -e '57,63d' /var/www/html/web/pre_installer_code.php

sudo sed -i "s/80/${siwapp_APP_PORT}/" /etc/httpd/conf/httpd.conf
sudo sed -i "s/LogFormat \"%h/LogFormat \"%a/g" /etc/httpd/conf/httpd.conf

sudo sed -i "21s%.*%${cliqrNodeHostname}%g" /var/www/html/apps/siwapp/templates/layout.php

sudo su -c "echo $'<Directory /var/www/html/web>
	Options FollowSymLinks
	AllowOverride All
</Directory>
<VirtualHost *:${siwapp_APP_PORT}>
	DocumentRoot /var/www/html/web
	RewriteEngine On
</VirtualHost>'\
>> /etc/httpd/conf/httpd.conf"

sudo su -c "cat << EOF > /var/www/html/config/databases.yml
all:
  doctrine:
    class: sfDoctrineDatabase
    param:
      dsn: 'mysql:host=${CliqrTier_siwapp_haproxy_db_PUBLIC_IP};dbname=siwapp'
      username: '${GALERA_DB_USER}'
      password: '${GALERA_DB_USER_PWD}'

test:
  doctrine:
    class: sfDoctrineDatabase
    param:
      dsn: 'mysql:host=${CliqrTier_siwapp_haproxy_db_PUBLIC_IP};dbname=siwapp_test'
      username: '${GALERA_DB_USER}'
      password: '${GALERA_DB_USER_PWD}'
EOF
"

sudo sed -i.bak "s#false#true#g" /var/www/html/web/config.php

agentSendLogMessage "Restarting http services"
sudo systemctl enable httpd
sudo systemctl start httpd
agentSendLogMessage "App install script complete"

sudo mv ~/cliqr.repo /etc/yum.repos.d/
