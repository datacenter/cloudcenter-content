#!/bin/bash

#echo "This service will create a K8 cluster in GKE"
#per the specifications provided.  

exec > >(tee -a /tmp/k8gkebuild_$$.log) 2>&1

. /utils.sh
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
#wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/CloudCenterTSA-3d1b0e624918.json
gcloud auth activate-service-account --key-file CloudCenterTSA-3d1b0e624918.json

#create a Kubernetes Engine cluster
gcloud container clusters create $cluster_name --zone $compute_zone --num-nodes 1 --cluster-version=$cluster_version --node-version=$node_version


#Get authentication credentials for the cluster
gcloud container clusters get-credentials $cluster_name --zone $compute_zone
#gcloud container clusters get-credentials jmbashdemo


#Setup Service Account in K8 Cluster
kubectl config set-cluster $cluster_name
#kubectl config set-cluster jmbashdemo

#Login to cluster
#gcloud auth application-default login

#Create Standard and Gold Storage Classes
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/ssd-storageclass.yaml
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/pdstandard-storageclass.yaml
kubectl apply -f ssd-storageclass.yaml
kubectl apply -f pdstandard-storageclass.yaml

#Create Secret for default namespace
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/secret.yaml
kubectl create -f secret.yaml --namespace="default"

#Create Name Space
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/namespacecreate.json
kubectl create -f namespacecreate.json

#Create Secret for chosen namespace
wget https://raw.githubusercontent.com/datacenter/cloudcenter-content/master/services/k8gkebuild/secret.yaml
kubectl create -f secret.yaml --namespace=$name_space


#Create service account in default namespace
kubectl create serviceaccount $service_account_name -n "default"
#Create service account in chosen namespace
#kubectl create serviceaccount $service_account_name -n $name_space
#export CLUSTER_ROLE_BINDING_NAME=$admin_cluster_role

#Create cluster role finding for default namespace
kubectl create clusterrolebinding "admin_cluster_role_0" --clusterrole=cluster-admin --serviceaccount="default":$service_account_name
#Create cluster role finding for chosen namespace
kubectl create clusterrolebinding $CLUSTER_ROLE_BINDING_NAME --clusterrole=cluster-admin --serviceaccount=$name_space:$service_account_name

export SECRET_NAME=$(kubectl get serviceaccount $service_account_name -n "default" -o 'jsonpath={.secrets[0].name}' 2>/dev/null)

print_log "Service Account Name: $service_account_name"

print_log "Service Account Token, required for Container Cloud Account: $(kubectl get secret $SECRET_NAME -n "default" -o "jsonpath={.data.token}" | openssl enc -d -base64 -A)"
