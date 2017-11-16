#!/bin/bash

# https://kubernetes.io/docs/getting-started-guides/kops/

. /utils.sh

# Remove this line and add as service custom parameter 'hostedZone'
hostedZone="cloudcenterdemo.com"

prereqs="unzip wget openssh"
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

ssh-keygen -f /root/.ssh/id_rsa -N

s3bucket="s3://clusters.${hostedZone}"
aws s3 mb ${s3bucket}
export KOPS_STATE_STORE=${s3bucket}

clusterName="useast1.${hostedZone}"
kops create cluster \
--name=${clusterName} \
--state=${s3bucket} \
--zones=us-east-1c \
--node-count=2

kops update cluster ${clusterName} --yes

kube_config_path="${s3bucket}/${clusterName}/kube_config"
aws s3 cp /root/.kube/config ${kube_config_path}
print_log "Kube config file uploaded to ${kube_config_path}"

# Installing Istio Client and misc files
# https://istio.io/docs/setup/kubernetes/quick-start.html
# Downloading latest Istio version
curl -L https://git.io/getLatestIstio | sh -
# Add istio bin dir to path
cd istio-*
export PATH=$PWD/bin:$PATH

# Installing Istio into Kube cluster, without TLS
kubectl apply -f install/kubernetes/istio.yaml

# Installing kubefed
# https://kubernetes.io/docs/tasks/federation/set-up-cluster-federation-kubefed/
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/kubernetes-client-linux-amd64.tar.gz
tar -xzvf kubernetes-client-linux-amd64.tar.gz
cp kubernetes/client/bin/kubefed /usr/local/bin
chmod +x /usr/local/bin/kubefed

# Initializing the cluster
#kubefed init fellowship \
#    --host-cluster-context=rivendell \
#    --dns-provider="google-clouddns" \
#    --dns-zone-name="example.com."