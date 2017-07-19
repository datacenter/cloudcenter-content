#!/bin/bash

#---------Script Variables------------#
APP_PORT=$1

#---------DO NOT MODIFY BELOW------------#
echo -e "Starting app install script" >> /var/log/siwapp/install.log
yum -y install git httpd php php-mysql php-xml php-mbstring && \
yum -y update && yum clean all

git clone https://github.com/siwapp/siwapp-sf1.git /var/www/html/

mkdir /var/www/html/cache
chmod 777 /var/www/html/cache
chmod 777 /var/www/html/web/config.php
chmod 777 /var/www/html/config/databases.yml

mkdir /var/www/html/web/uploads
chmod 777 /var/www/html/web/uploads

chown -R apache:apache /var/www/html/

sed -i -e '57,63d' /var/www/html/web/pre_installer_code.php

sed -i "s/80/$APP_PORT/" /etc/httpd/conf/httpd.conf

echo $"<Directory /var/www/html/web>
	Options FollowSymLinks
	AllowOverride All
</Directory>
<VirtualHost *:$APP_PORT>
	DocumentRoot /var/www/html/web
	RewriteEngine On
</VirtualHost>"\
>> /etc/httpd/conf/httpd.conf

echo -e "Restarting http services" >> /var/log/siwapp/install.log
systemctl enable httpd
systemctl start httpd
echo -e "App install script complete" >> /var/log/siwapp/install.log
