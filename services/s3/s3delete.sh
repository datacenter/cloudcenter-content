#!/bin/bash
# Title		: s3delete.sh
# Description	: Lifecycle action script for creating AWS S3 buckets.
# Author	: jasgrimm
# Date		: 2018-04-01
# Version	: 0.1
# Usage		: bash s3delete.sh
# External Vars	: Read in at run time - $AWS_REGION, $AWS_ACCESS_KEY_ID, and $AWS_SECRET_ACCESS_KEY
# Internal Vars	: Initialized within srcipt - $AWS_INSTALL_DIR, $AWS_CONFIG_DIR, $AWS_CONFIG_FILE, $AWS_CRED_FILE

# If running as an "external-service", execute and terminate docker container on the orchestrator
# . /utils.sh
# print_log "$(env)"

# If running within a virtual machine (default)
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# Declare / configure internal vars
AWS_INSTALL_DIR="/usr/local/aws"
PATH=$PATH:$AWS_INSTALL_DIR/bin
AWS_CONFIG_DIR="/root/.aws"
AWS_CONFIG_FILE="$AWS_CONFIG_DIR/config"
AWS_CRED_FILE="$AWS_CONFIG_DIR/credentials"
AWS_BUCKET_FILE_JSON="/root/bucketlist.json.txt"
AWS_BUCKET_FILE_PRETTY="/root/bucketlist.pretty.txt"

# Install prerequisites
installPrerequisites() {
	agentSendLogMessage "Installing prerequisites..."
	if [ -f /bin/jq ]; then
		agentSendLogMessage "JQ is already installed, skipping install."
	else
		agentSendLogMessage "JQ is not installed, installing now."
		yum -y --skip-broken install jq
	fi
}

# Functions
installAWSCli() {
    agentSendLogMessage "Installing AWS CLI tools..."

        if [ -f $AWS_INSTALL_DIR/bin/aws ]; then
            agentSendLogMessage  "AWS CLI already installed, skipping the AWS CLI Install."
        else
            mkdir -p $AWS_INSTALL_DIR; cd $AWS_INSTALL_DIR
            wget https://s3.amazonaws.com/aws-cli/awscli-bundle.zip; unzip awscli-bundle.zip
            ./awscli-bundle/install -i $AWS_INSTALL_DIR
            agentSendLogMessage  "AWS CLI tools are now installed."
        fi
}

configureAWSCli() {
	agentSendLogMessage "Configuring AWS CLI tools..."

	mkdir -p $AWS_CONFIG_DIR

	echo "[default]" > $AWS_CONFIG_FILE
	echo "region = $AWS_REGION" >> $AWS_CONFIG_FILE
	chmod 600 $AWS_CONFIG_FILE

	echo "[default]" > $AWS_CRED_FILE
	echo "aws_access_key_id = $AWS_ACCESS_KEY_ID" >> $AWS_CRED_FILE
	echo "aws_secret_access_key = $AWS_SECRET_ACCESS_KEY" >> $AWS_CRED_FILE
	chmod 600 $AWS_CRED_FILE
}

deleteAWSBucket() {
	agentSendLogMessage "Deleting AWS S3 Bucket: $AWS_INSTALL_DIR/bin/aws s3api delete-bucket --bucket $AWS_BUCKET_NAME"
	$AWS_INSTALL_DIR/bin/aws s3api delete-bucket --bucket $AWS_BUCKET_NAME
	agentSendLogMessage "AWS S3 Bucket Delete Complete."
	sleep 10
}

listAWSBuckets() {
	agentSendLogMessage "Listing AWS S3 Buckets with command: $AWS_INSTALL_DIR/bin/aws s3api list-buckets"

	$AWS_INSTALL_DIR/bin/aws s3api list-buckets > $AWS_BUCKET_FILE_JSON
	agentSendLogMessage "JSON Format"
	agentSendLogMessage `cat $AWS_BUCKET_FILE_JSON`

	agentSendLogMessage "List Format"
	echo "" > $AWS_BUCKET_FILE_PRETTY
	loopcount=0
	bucketcount=`cat $AWS_BUCKET_FILE_JSON | grep Creation | wc -l`
	while [ $loopcount -lt $bucketcount ]; do
		bucketname=`cat $AWS_BUCKET_FILE_JSON | jq '.Buckets['"$loopcount"'].Name' | sed -e 's/"//g'`
		bucketcreatedate=`cat $AWS_BUCKET_FILE_JSON | jq '.Buckets['"$loopcount"'].CreationDate' | awk -F\T '{ print $1 }' | sed -e 's/"//g'`
		bucketcreatetime=`cat $AWS_BUCKET_FILE_JSON | jq '.Buckets['"$loopcount"'].CreationDate' | awk -F\T '{ print $2 }' | awk -F. '{ print $1 }'`
		echo "Bucket # $loopcount  ---  Name: $bucketname  ---  Create Date: $bucketcreatedate  ---  Create Time: $bucketcreatetime" >> $AWS_BUCKET_FILE_PRETTY
		let loopcount=loopcount+1
	done
	while read line; do agentSendLogMessage "$line"; done < $AWS_BUCKET_FILE_PRETTY
}

# Main
agentSendLogMessage "#### S3 BUCKET DELETE SERVICE STARTING ####"

installPrerequisites
installAWSCli
configureAWSCli
listAWSBuckets
deleteAWSBucket
listAWSBuckets

agentSendLogMessage "#### S3 BUCKET DELETE SERVICE COMPLETE ####"

exit 0