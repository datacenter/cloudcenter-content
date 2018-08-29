#!/bin/bash

# Kinesis Analytics service script

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
    tag="kinesisanalytics"
fi

print_log "Tag/branch for code pull set to ${tag}"

error () {
    print_log "${1}"
    exit 1
}

# the following should be parameters from the service

if [ -z "$applicationName" ];
then
	error "Application Name missing"
fi

if [ "$addReferenceDataSource" = "true" ] && [ -z "$referenceDataSource" ];
then
	error "Application reference data source missing"
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


createApplication(){

    command="aws kinesisanalytics create-application --application-name ${applicationName}"
    if [ -n "${applicationDescription}" ]; then
        command+=" --application-description \"${applicationDescription}\""
    fi
    if [ -n "${inputs}" ]; then
            echo ${inputs} > inputfile
            command+=" --inputs file://inputfile"
    fi
    if [ -n "${outputs}" ]; then
            echo ${outputs} > outputfile
            command+=" --outputs file://outputfile"
    fi
    if [ -n "${cloudWatchLoggingOptions}" ]; then
            echo ${cloudWatchLoggingOptions} > cloudwatchfile
            command+=" --cloud-watch-logging-options file://cloudwatchfile"
    fi
    if [ -n "${applicationCode}" ]; then
            echo ${applicationCode} > appcodefile
            command+=" --application-code file://appcodefile"
    fi

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to create Kinesis application: ${msg}"

    print_log "Successfully created the Kinesis application $applicationName"

    # Add an optional reference data source if specified in the parameters
    if [ ${addReferenceDataSource} = "true" ]; then

        command="aws kinesisanalytics add-application-reference-data-source --application-name ${applicationName}"

        echo ${referenceDataSource} > tempfile
        command+=" --reference-data-source file://tempfile"

        # get current application version id
        # hardcoding it in as it should always be the same TODO - use the describe-application CLI to get this
        currentVersionId=1
        command+=" --current-application-version-id ${currentVersionId}"

        print_log $command

        msg=$(${command} 2>&1) || \
            error "Failed to add reference data source to Kinesis application: ${msg}"

        print_log "Successfully created the Kinesis application $applicationName"

    fi


}

deleteApplication(){

    # need to get create timestamp before being able to delete application
    command="aws kinesisanalytics describe-application --application-name ${applicationName}"

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to get create timestamp for Kinesis application: ${msg}"

    createTimestamp=`echo $msg | sed 's/.*CreateTimestamp": \([0-9]*\.[0-9]\).*/\1/'`

    command="aws kinesisanalytics delete-application --application-name ${applicationName} --create-timestamp ${createTimestamp}"

    print_log $command

    msg=$(${command} 2>&1) || \
        error "Failed to delete Kinesis application: ${msg}"

    print_log "Successfully deleted the Kinesis application $applicationName"

}


case $cmd in
	start)
		echo "Service Action -  $cmd"
		echo "Installing AWS CLI Tools"
		installAWSCli
		configureAWSCli
		createApplication
		exit 0
		;;
	stop)
		echo "Service Action -  $cmd"
        echo "Installing AWS CLI Tools"
        installAWSCli
        configureAWSCli
		deleteApplication
        exit 0
		;;
	*)
		echo "unknown command"
		exit 127
		;;
esac
