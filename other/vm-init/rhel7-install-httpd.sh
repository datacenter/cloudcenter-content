#!/bin/bash
yum -y --skip-broken install httpd

service httpd start
service httpd status
systemctl enable httpd

echo 'ServerName 127.0.0.1' >> /etc/httpd/conf/httpd.conf

firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --zone=public --add-port=443/tcp --permanent
firewall-cmd --reload

echo "APACHE on RHEL7" > /var/www/html/index.html

service httpd restart

exit 0
