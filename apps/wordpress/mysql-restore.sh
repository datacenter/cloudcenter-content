#!/bin/bash -x
exec > >(tee -a /var/tmp/mysql-restore_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
cd ~

echo "Username: $(whoami)"
echo "Working Directory: $(pwd)"

defaultGitTag="wordpress"
if [ -n "$gitTag" ]; then
    agentSendLogMessage  "Found gitTag parameter gitTag = ${gitTag}"
else
     agentSendLogMessage  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

 #Install S3
sudo wget -N "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
sudo unzip -o awscli-bundle.zip
sudo ./awscli-bundle/install -b /root/bin/aws

#Configure S3
sudo mkdir -p /root/.aws
echo "[default]" | sudo tee --append /root/.aws/config
echo "region=us-west-1" | sudo tee --append /root/.aws/config
echo "output=json" | sudo tee --append /root/.aws/config
echo "[default]" | sudo tee --append /root/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" | sudo tee --append /root/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" | sudo tee --append /root/.aws/credentials

#Download and restore old database
sudo /root/bin/aws s3 cp s3://$s3path/$migrateFromDepId/dbbak.sql dbbak.sql
sudo su -c "mysql -u root -pwelcome2cliqr < dbbak.sql"

#Use simple DB commands to replace old front-end IP with new front-end IP in database
sudo mysql -u root -pwelcome2cliqr -e "update wordpress.wp_options set option_value = 'http://${CliqrTier_haproxy_2_PUBLIC_IP}/wordpress' where option_name = 'siteurl';"
sudo mysql -u root -pwelcome2cliqr -e "update wordpress.wp_options set option_value = 'http://${CliqrTier_haproxy_2_PUBLIC_IP}/wordpress' where option_name = 'home';"
sudo mysql -u root -pwelcome2cliqr -e "FLUSH PRIVILEGES;"
