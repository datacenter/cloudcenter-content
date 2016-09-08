#!/bin/bash -x
(
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh

#Install S3
sudo wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
sudo unzip -o awscli-bundle.zip
./awscli-bundle/install -b ~/bin/aws

#Configure S3
mkdir -p ~/.aws
echo "[default]" > ~/.aws/config
echo "region=us-west-2" >> ~/.aws/config
echo "output=json" >> ~/.aws/config
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" >> ~/.aws/credentials


#apt-get install mysql-client -y

#cd /var/www
sudo cp /var/www/wp-config.php /tmp
sudo rm -rf /var/www/*

sudo ~/bin/aws s3 cp s3://$s3path/$migrateFromDepId/wordpressbkup.zip ~/wordpressbkup.zip
sudo unzip -o ~/wordpressbkup.zip -d /var/www
sudo cp /tmp/wp-config.php /var/www
sudo chown -R apache:apache /var/www

rm ~/wordpressbkup.zip
aws s3 rm --recursive s3://$s3path/$migrateFromDepId

) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | tee -a /var/tmp/wp-restore.log
