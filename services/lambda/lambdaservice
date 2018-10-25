#!/bin/bash

# lambda service script

exec > >(tee -a /usr/local/osmosix/logs/service.log) 2>&1

. /utils.sh

cmd=$1
SVCNAME="lambda1"
export INSTALL_DIR="/usr/local/aws"

error () {
    print_log "${1}"
    exit 1
}

# the following are required parameters from the service

if [ -z "$lambdaFunctionName" ];
then
	export functionName="lambda-"$currentTierJobId;
fi

if [ -z "$lambdaRuntime" ];
then
	error "Runtime missing for Lambda function"
fi

if [ -z "$lambdaHandler" ];
then
	error "Handler missing for Lambda function"
fi

if [ -z "$lambdaRole" ];
then
	error "Role missing for Lambda function"
fi

if [ -z "$lambdaCodeS3Bucket" ] && [ -n "$lambdaCodeS3Key" ];
then
	error "S3 Bucket containing function code missing"
fi

if [ -z "$lambdaCodeS3Key" ] && [ -n "$lambdaCodeS3Bucket" ];
then
	error "S3 Key containing function code missing"
fi

if [ ! -z "$lambdaRegion" ];
then
	export region=$lambdaRegion;
fi

if [ -z "$region" ];
then
	export region="us-east-1";
fi


installAWSCli() {

    print_log "Installing AWS CLI tools..."

	if [ -d $INSTALL_DIR ]; then
			echo  "AWS Cli already installed skipping the AWS Cli Install";
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
		print_error "Insufficient permissions to access the Cloud Account, contact your Admin for the Cloud Account Accessibility";
		exit 127
	else
		export AWS_ACCESS_KEY_ID="$CliqrCloudAccountPwd"
		export AWS_SECRET_ACCESS_KEY="$CliqrCloud_AccessSecretKey"

	fi

	if [ -z $AWS_ACCESS_KEY_ID ];then
			print_error "Cloud Account Access Key not found or couldn't generate with IAM role"
			exit 127
	fi

	if [ -z $AWS_SECRET_ACCESS_KEY ];then
			print_error "Cloud Account Secret Key not found or couldn't generate with IAM role"
			exit 127
	fi

	if [ -z $region ];then
			print_error "Region Value is not set"
			exit 127
	fi

	export "AWS_DEFAULT_REGION"=$region

}


createLambdaFunction(){

    command="aws --no-verify-ssl lambda create-function --function-name $lambdaFunctionName --runtime $lambdaRuntime --handler $lambdaHandler --role $lambdaRole"

    if [ -n "${lambdaTimeout}" ]; then
        command+=" --timeout ${lambdaTimeout}"
    fi
    if [ -n "${lambdaMemorySize}" ]; then
            command+=" --memory-size ${lambdaMemorySize}"
    fi
    if [ -n "${lambdaZipfile}" ]; then
            command+=" --zip \"${lambdaZipfile}\""
    fi
    if [ "${lambdaPublish}" = "yes" ]; then
            command+=" --publish"
    elif [ "${lambdaPublish}" = "no" ]; then
            command+=" --no-publish"
    fi
    if [ -n "${lambdaCodeS3Bucket}" ]; then
            command+=" --code S3Bucket=$lambdaCodeS3Bucket,S3Key=$lambdaCodeS3Key"
    fi

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to create Lambda Function: ${msg}"

    print_log "Successfully created the Lambda function $lambdaFunctionName"

        # Add an optional event source mapping if specified in the parameters
    if [ ${createEventSourceMapping} = "true" ]; then

        command="aws lambda create-event-source-mapping --event-source-arn $lambdaEventSourceARN --function-name $lambdaFunctionName"
        command+=" --enabled --batch-size 200 --starting-position TRIM_HORIZON"

        print_log $command

        msg=$(${command} 2>&1) || \
            error "Failed to add event source mapping: ${msg}"

        print_log "Successfully added the event source mapping to $lambdaFunctionName"

    fi



}

deleteLambdaFunction(){

    command="aws lambda delete-function --function-name $lambdaFunctionName"

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to delete Lambda Function: ${msg}"

    print_log "Successfully deleted the Lambda function $LambdaFunctionName"

}


case $cmd in
	start)
		echo "Service Action -  $cmd"
		echo "Installing AWS Cli Tools"
		installAWSCli
		configureAWSCli
		createLambdaFunction
		exit 0
		;;
	stop)
		echo "Service Action -  $cmd"
        	echo "Installing AWS Cli Tools"
        	installAWSCli
        	configureAWSCli
		deleteLambdaFunction
        	exit 0
		;;
	suspend)
		echo "Service Action -  $cmd"
		echo "Installing AWS Cli Tools"
		installAWSCli
        	configureAWSCli
		deleteLambdaFunction
		exit 0
		;;
	resume)
		echo "Service Action -  $cmd"
		echo "Installing AWS Cli Tools"
		installAWSCli
        	configureAWSCli
		createLambdaFunction
		exit 0
		;;
	*)
		echo "unknown command"
		exit 127
		;;
esac
