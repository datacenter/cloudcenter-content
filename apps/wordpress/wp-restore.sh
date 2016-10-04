#!/bin/bash -x
exec > >(tee -a /var/tmp/wp-restore_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh

echo "Username: $(whoami)" # Should execute as root
echo "Working Directory: $(pwd)"

env

#Install S3
wget "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
unzip -o awscli-bundle.zip
./awscli-bundle/install -b ~/bin/aws

#Configure S3
mkdir -p ~/.aws
echo "[default]" > ~/.aws/config
echo "region=us-west-2" >> ~/.aws/config
echo "output=json" >> ~/.aws/config
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" >> ~/.aws/credentials

#cd /var/www
cp /var/www/wp-config.php /tmp
rm -rf /var/www/*

~/bin/aws s3 cp s3://$s3path/$migrateFromDepId/wordpressbkup.zip ~/wordpressbkup.zip
unzip -o ~/wordpressbkup.zip -d /var/www
cp /tmp/wp-config.php /var/www
chown -R apache:apache /var/www

rm ~/wordpressbkup.zip
~/bin/aws s3 rm --recursive s3://$s3path/$migrateFromDepId
