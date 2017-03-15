#!/bin/bash
. /utils.sh

# Required Service Parameters:
# gitTag - The tag or branch of code that you want to pull from github
# TODO

# Print the env to the CCM UI for debugging. Remove this line for production.
print_log "$(env)"

defaultGitTag="route53"
if [ -n "$gitTag" ]; then
    print_log  "Found gitTag parameter gitTag = ${gitTag}"
else
     print_log  "Didn't find custom parameter gitTag. Using default gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

if [ -n "$aws_access_key_id" ]; then
    print_log  "AWS Access Key provided."
else
     print_log  "No AWS access key specified in custom parameter. Trying configured cloud account."
     aws_access_key_id=${CliqrCloudAccountPwd}
     aws_secret_access_key=${CliqrCloud_AccessSecretKey}
     # gitTag=${defaultGitTag}
fi

print_log "Tag/branch for code pull set to $gitTag"

# Setup a bunch of prerequisits
print_log "Installing pre-reqs"
yum install -y python-pip
pip install --upgrade pip
pip install boto3
print_log "Done installing pre-reqs"

print_log "Configuring AWS boto3"
mkdir -p ~/.aws
echo "[default]" > ~/.aws/config
echo "region=$region" >> ~/.aws/config
echo "output=json" >> ~/.aws/config
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$aws_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key=$aws_secret_access_key" >> ~/.aws/credentials

cmd=$1 # Controls which part of this script is executed based on command line argument. Ex start, stop.

wget --no-check-certificate https://raw.githubusercontent.com/datacenter/cloudcenter-content/${gitTag}/services/route53/route53.py
python route53.py ${cmd}
