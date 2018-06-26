#!/bin/bash -x

#echo "This service will create a K8 cluster in GKE"
#per the specifications provided.  

exec > >(tee -a /tmp/k8gkebuild_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

env

cd /tmp/

#Install openssl
yum install -y openssl
#Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod u+x kubectl
mv kubectl /usr/local/bin/kubectl

#update repos for google cloud sdk
tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM
#Install gcloud
yum install -y google-cloud-sdk
#gcloud init
#gcloud auth activate-service-account --key-file=credential_key.json


#Set Project ID
gcloud config set project $project_id
#gcloud config set project cloudcentertsa-196419

#Set Poject Zone
gcloud config set compute/zone $compute_zone
#gcloud config set compute/zone us-central1-a

#Set Auth Credentials
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/projcred.zip
#unzip -P $cred_password projcred.zip
echo "unzip -P password projcred.zip" > string.txt
sed -i 's/password/'$proj_cred'/g' string.txt
i=`cat string.txt`
eval "$i"
gcloud auth activate-service-account --key-file CloudCenterTSA-3d1b0e624918.json

#Delete Kubernetes Engine cluster
gcloud container clusters delete --quiet $cluster_name

