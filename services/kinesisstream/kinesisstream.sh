#!/bin/bash

# Kinesis Stream service script

exec > >(tee -a /usr/local/osmosix/logs/service.log) 2>&1

. /utils.sh

#print_log "$(env)"

# Print the env to the CCM UI for debugging. Remove this line for production.
# Ues with:
# sed -n '/718WPR53 ENV START/,/718WPR53 ENV END/p' /usr/local/cliqr/logs/gateway.log | \
# head -n-1 | tail -n+2 | grep '=' | grep -v '\\n' > envfile
#echo "${parentJobName} ENV START"
#env
#echo "${parentJobName} ENV END"

cmd=$1
serviceStatus=""
SVCNAME="kinesisstream"
export INSTALL_DIR="/usr/local/aws"


if [ -n "${gitTag}" ]; then
    tag="${gitTag}"
else
    tag="kinesis"
fi

print_log "Tag/branch for code pull set to ${tag}"

error () {
    print_log "${1}"
    exit 1
}


# the following should be parameters from the service

if [ -z "$streamName" ];
then
	error "Stream Name missing"
else
    streamName="$streamName-$parentJobName"
fi

if [ -z "$shardCount" ];
then
	error "Shard count missing"
fi

if [ -n "$kinesis_region" ];
then
    region="$kinesis_region"
else
	region="us-east-1";
fi



installAWSCli() {

    print_log "Installing AWS CLI tools..."

	if [ -d $INSTALL_DIR ]; then
			echo  "AWS CLI already installed, skipping the AWS CLI Install";
			export PATH=$PATH:$INSTALL_DIR/bin
			echo "PATH value is = $PATH"
	else
			mkdir -p $INSTALL_DIR
			cd $INSTALL_DIR
			wget http://s3.amazonaws.com/aws-cli/awscli-bundle.zip
			unzip awscli-bundle.zip
			./awscli-bundle/install -i $INSTALL_DIR
			rm -f awscli-bundle.zip
			export PATH=$PATH:$INSTALL_DIR/bin
			echo "PATH value is = $PATH"
	fi

}


configureAWSCli(){
    print_log "Configuring AWS CLI..."
	export JAVA_HOME="/usr/lib/jvm/jre"
	export EC2_REGION="$region"
	export PATH=$PATH:$INSTALL_DIR/bin

	if [ ! -z "$AWSkey" ] && [ ! -z "$AWSsecretkey" ];
	then
		export AWS_ACCESS_KEY_ID="$AWSkey"
		export AWS_SECRET_ACCESS_KEY="$AWSsecretkey"

	elif [ -z $CliqrCloudAccountPwd ] || [ -z $CliqrCloud_AccessSecretKey ];
	then
		error "Insufficient permissions to access the Cloud Account, contact your Admin for the Cloud Account Accessibility"
	else
		export AWS_ACCESS_KEY_ID="$CliqrCloudAccountPwd"
		export AWS_SECRET_ACCESS_KEY="$CliqrCloud_AccessSecretKey"

	fi

	if [ -z $AWS_ACCESS_KEY_ID ];then
			error "Cloud Account Access Key not found or couldn't generate with IAM role"
	fi

	if [ -z $AWS_SECRET_ACCESS_KEY ];then
			error "Cloud Account Secret Key not found or couldn't generate with IAM role"
	fi

	if [ -z $region ];then
			error "Region Value is not set"
	fi

	export "AWS_DEFAULT_REGION"=$region

}


createStream(){

    command="aws kinesis create-stream --stream-name ${streamName} --shard-count ${shardCount}"

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to create kinesis stream: ${msg}"

    print_log "Successfully created the Kinesis stream $streamName"

}

deleteStream(){

    command="aws kinesis delete-stream --stream-name ${streamName}"

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to delete kinesis stream: ${msg}"

    print_log "Successfully deleted the Kinesis stream $streamName"

}


case $cmd in
	start)
		echo "Service Action -  $cmd"
		echo "Installing AWS CLI Tools"
		installAWSCli
		configureAWSCli
		createStream
		exit 0
		;;
	stop)
		echo "Service Action -  $cmd"
        echo "Installing AWS CLI Tools"
        installAWSCli
        configureAWSCli
		deleteStream
        exit 0
		;;
	*)
		echo "unknown command"
		exit 127
		;;
esac
