#!/bin/bash -x
exec > >(tee -a /var/tmp/mysql-bkup_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
cd ~

echo "Username: $(whoami)"
echo "Working Directory: $(pwd)"

env

prereqs="mysql-community-client unzip"
agentSendLogMessage "Installing prereqs: ${prereqs}"
sudo yum install -y ${prereqs}

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
echo "aws_access_key_id=${aws_access_key_id}" | sudo tee --append /root/.aws/credentials
echo "aws_secret_access_key=${aws_secret_access_key}" | sudo tee --append /root/.aws/credentials


sudo su -c "mysqldump --host=127.0.0.1 --all-databases -u wordpress -pwelcome2cliqr > dbbak.sql"

sudo /root/bin/aws s3 cp dbbak.sql s3://${s3path}/${CliqrDeploymentId}/dbbak.sql

rm -f dbbak.sql