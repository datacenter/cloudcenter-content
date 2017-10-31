#!/bin/bash
. /utils.sh

prereqs="unzip wget"
yum install -y ${prereqs}

#Install AWS CLI
wget -N "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
unzip -o awscli-bundle.zip
./awscli-bundle/install -b /bin/aws

#Configure AWS CLI
mkdir -p /root/.aws
echo "[default]" | tee --append /root/.aws/config
echo "region=us-west-1" | tee --append /root/.aws/config
echo "output=json" | tee --append /root/.aws/config
echo "[default]" | tee --append /root/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" | tee --append /root/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" | tee --append /root/.aws/credentials


wget -O kops https://github.com/kubernetes/kops/releases/download/1.7.0/kops-linux-amd64
chmod +x ./kops
sudo mv ./kops /usr/local/bin/

wget -O kubectl https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl