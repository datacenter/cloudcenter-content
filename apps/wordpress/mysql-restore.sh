#!/bin/bash -x
(
echo "Username: $(whoami)"
echo "Working Directory: $(pwd)"

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh

env

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

#Download and restore old database
sudo ~/bin/aws s3 cp s3://$s3path/$migrateFromDepId/dbbak.sql dbbak.sql
sudo su -c "mysql -u root -pwelcome2cliqr < dbbak.sql"

#Use simple DB script to replace old front-end IP with new front-end IP in database
sudo ~/bin/aws s3 cp s3://$s3path/wp_migration.sql wp_migration.sql
replaceToken wp_migration.sql '%APP_SERVER_IP%' $CliqrTier_haproxy_2_PUBLIC_IP
sudo su -c "mysql -u root -pwelcome2cliqr < wp_migration.sql"


) 2>&1 | while IFS= read -r line; do echo "$(date) | $line"; done | tee -a /var/tmp/mysql-restore.log
