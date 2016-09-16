#!/bin/bash -x
(

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv

# Install Erlang & RabbitMQ
sudo wget http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm
sudo rpm -Uvh erlang-solutions-1.0-1.noarch.rpm
sudo yum install erlang -y

sudo rpm --import http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
sudo rpm -Uvh http://www.rabbitmq.com/releases/rabbitmq-server/v3.5.4/rabbitmq-server-3.5.4-1.noarch.rpm

# Enable boot start and start
sudo chkconfig rabbitmq-server on
sudo /etc/init.d/rabbitmq-server start

# Create vhost
sudo rabbitmqctl add_vhost /sensu

# Create user
sudo rabbitmqctl add_user sensu secret
sudo rabbitmqctl set_permissions -p /sensu sensu ".*" ".*" ".*"

# Install Redis
sudo rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
sudo yum install redis -y

# Enable boot start and start redis
sudo /sbin/chkconfig redis on
sudo /etc/init.d/redis start

# Install Repo
echo '[sensu]
name=sensu
baseurl=http://repositories.sensuapp.org/yum/$basearch/
gpgcheck=0
enabled=1' | sudo tee /etc/yum.repos.d/sensu.repo

# Install Sensu
sudo yum install sensu -y

# Configure Sensu
sudo wget -O /etc/sensu/config.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/config.json

# Install Checks
sudo wget -O /etc/sensu/conf.d/check_process_haproxy.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/check_process_haproxy.json
sudo wget -O /etc/sensu/conf.d/check_process_tomcat.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/check_process_tomcat.json
sudo wget -O /etc/sensu/conf.d/check_disk.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/check_disk.json
sudo wget -O /etc/sensu/conf.d/check_process_win.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/check_process_win.json
sudo wget -O /etc/sensu/conf.d/check_disk_win.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/check_disk_win.json

# Install SMTP Server
sudo yum install postfix -y

# Configure Sensu Mailer
sudo /opt/sensu/embedded/bin/gem install mail --no-ri --no-RDoc
sudo wget -O /etc/sensu/handlers/mailer.rb https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/mailer.rb
sudo chmod 755 /etc/sensu/handlers/mailer.rb
sudo wget -O /etc/sensu/conf.d/mailer.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/mailer.json
sudo wget -O /etc/sensu/conf.d/handler_mailer.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/handler_mailer.json
sudo sed -i "s/%MAIL_TO%/$MAIL_TO/g" /etc/sensu/conf.d/mailer.json
sudo sed -i "s/%PUBLIC_IP%/$OSMOSIX_PUBLIC_IP/g" /etc/sensu/conf.d/mailer.json

# Start sensu
sudo /etc/init.d/sensu-server start
sudo /etc/init.d/sensu-api start

# Install Uichwa
sudo yum install uchiwa -y
sudo wget -O /etc/sensu/uchiwa.json https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/apps/sensu/uchiwa.json

# Enable start uichwa
sudo /etc/init.d/uchiwa start
) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | tee -a /var/tmp/sensu-server_$$.log