#!/bin/bash
. /utils.sh

# Required Service Parameters:
# route53_gitTag - The tag or branch of code that you want to pull from github

# Print the env to the CCM UI for debugging. Remove this line for production.
# Ues with:
# sed -n '/718WPR53 ENV START/,/718WPR53 ENV END/p' /usr/local/cliqr/logs/gateway.log | \
# head -n-1 | tail -n+2 | grep '=' | grep -v '\\n' > envfile
#print_log "${parentJobName} ENV START
#$(env)
#${parentJobName} ENV END"

defaultGitTag="route53"
if [ -n "$route53_gitTag" ]; then
    print_log  "Found route53_gitTag parameter route53_gitTag = ${route53_gitTag}"
else
     print_log  "Didn't find custom parameter route53_gitTag. Using default route53_gitTag = ${defaultGitTag}"
     route53_gitTag=${defaultGitTag}
fi

if [ -n "$route53_aws_access_key_id" ]; then
    print_log  "AWS Access Key provided."
else
     print_log  "No AWS access key specified in custom parameter. Trying configured cloud account."
     route53_aws_access_key_id=${CliqrCloudAccountPwd}
     route53_aws_secret_access_key=${CliqrCloud_AccessSecretKey}
fi

print_log "Tag/branch for code pull set to $route53_gitTag"

# Setup a bunch of prerequisits
print_log "Installing pip and boto3"
yum install -y python-pip
pip install --upgrade pip
pip install boto3
print_log "Done installing pip and boto3"

print_log "Configuring AWS boto3"
mkdir -p ~/.aws
echo "[default]" > ~/.aws/config
echo "region=$region" >> ~/.aws/config
echo "output=json" >> ~/.aws/config
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id=$route53_aws_access_key_id" >> ~/.aws/credentials
echo "aws_secret_access_key=$route53_aws_secret_access_key" >> ~/.aws/credentials

cmd=$1 # Controls which part of this script is executed based on command line argument. Ex start, stop.

wget --no-check-certificate https://raw.githubusercontent.com/datacenter/cloudcenter-content/${route53_gitTag}/services/route53/route53.py
python route53.py ${cmd}
