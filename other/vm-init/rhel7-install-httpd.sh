#!/bin/bash
sudo yum -y --skip-broken install httpd

sudo service httpd start
sudo service httpd status
sudo systemctl enable httpd

sudo echo 'ServerName 127.0.0.1' >> /etc/httpd/conf/httpd.conf

sudo firewall-cmd --zone=public --add-port=80/tcp --permanent
sudo firewall-cmd --zone=public --add-port=443/tcp --permanent
sudo firewall-cmd --reload

sudo echo "APACHE on RHEL7" > /var/www/html/index.html

sudo service httpd restart

exit 0
