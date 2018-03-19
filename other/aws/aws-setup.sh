#!/bin/bash -x
exec > >(tee -a /var/tmp/aws-setup_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
cd ~

#Install AWS CLI
sudo wget -N "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
sudo unzip -o awscli-bundle.zip
sudo ./awscli-bundle/install -b /root/bin/aws

#Configure AWS CLI
sudo mkdir -p /root/.aws
echo "[default]" | sudo tee --append /root/.aws/config
echo "region=us-west-1" | sudo tee --append /root/.aws/config
echo "output=json" | sudo tee --append /root/.aws/config
echo "[default]" | sudo tee --append /root/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" | sudo tee --append /root/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" | sudo tee --append /root/.aws/credentials
