#!/bin/bash

sudo mv /etc/yum.repos.d/cliqr.repo ~/


# Install Erlang & RabbitMQ
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
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
sudo wget -O /etc/sensu/config.json http://env.cliqrtech.com/sensu/config.json

# Install Checks
sudo wget -O /etc/sensu/conf.d/check_process.json http://env.cliqrtech.com/sensu/conf/check_process.json
sudo wget -O /etc/sensu/conf.d/check_disk.json http://env.cliqrtech.com/sensu/conf/check_disk.json

# Install SMTP Server
sudo yum install postfix -y

# Configure Sensu Mailer
sudo /opt/sensu/embedded/bin/gem install mail --no-ri --no-RDoc
sudo wget -O /etc/sensu/handlers/mailer.rb http://env.cliqrtech.com/sensu/mailer/mailer.rb
sudo chmod 755 /etc/sensu/handlers/mailer.rb
sudo wget -O /etc/sensu/conf.d/mailer.json http://env.cliqrtech.com/sensu/mailer/mailer.json
sudo wget -O /etc/sensu/conf.d/handler_mailer.json http://env.cliqrtech.com/sensu/mailer/handler_mailer.json

# Start sensu
sudo /etc/init.d/sensu-server start
sudo /etc/init.d/sensu-api start

# Install Uichwa
sudo yum install uchiwa -y
sudo wget -O /etc/sensu/uchiwa.json http://env.cliqrtech.com/sensu/uchiwa.json

# Enable start uichwa
sudo /etc/init.d/uchiwa start
