#!/bin/bash -x
exec > >(tee -a /var/tmp/wp-restore_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
cd ~

echo "Username: $(whoami)" # Should execute as root
echo "Working Directory: $(pwd)"

env

#Install S3
sudo wget -N "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
sudo unzip -o awscli-bundle.zip
sudo ./awscli-bundle/install -b ~/bin/aws

#Configure S3
sudo mkdir -p ~/.aws
sudo echo "[default]" > ~/.aws/config
sudo echo "region=us-west-2" >> ~/.aws/config
sudo echo "output=json" >> ~/.aws/config
sudo echo "[default]" > ~/.aws/credentials
sudo echo "aws_access_key_id=$aws_access_key_id" >> ~/.aws/credentials
sudo echo "aws_secret_access_key=$aws_secret_access_key" >> ~/.aws/credentials

#cd /var/www
cp /var/www/wp-config.php /tmp
rm -rf /var/www/*

sudo ~/bin/aws s3 cp s3://$s3path/$migrateFromDepId/wordpressbkup.zip ~/wordpressbkup.zip
sudo unzip -o ~/wordpressbkup.zip -d /var/www
sudo cp /tmp/wp-config.php /var/www
sudo chown -R apache:apache /var/www

sudo rm ~/wordpressbkup.zip
sudo ~/bin/aws s3 rm --recursive s3://$s3path/$migrateFromDepId
