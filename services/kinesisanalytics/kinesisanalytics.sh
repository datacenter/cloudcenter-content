#!/bin/bash
. /utils.sh

# Print the env to the CCM UI for debugging. Remove this line for production.
# Ues with:
# sed -n '/718WPR53 ENV START/,/718WPR53 ENV END/p' /usr/local/cliqr/logs/gateway.log | \
# head -n-1 | tail -n+2 | grep '=' | grep -v '\\n' > envfile
echo "${parentJobName} ENV START"
env
echo "${parentJobName} ENV END"

cmd=$1
serviceStatus=""

if [ -n "${kinesisanalytics_gitTag}" ]; then
    tag="${kinesisanalytics_gitTag}"
else
    tag="kinesisanalytics"
fi

error () {
    print_log "${1}"
    exit 1
}

print_log "Tag/branch for code pull set to ${tag}"

#Install AWS CLI
wget -N "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip"
unzip -o awscli-bundle.zip
./awscli-bundle/install -b /usr/bin/aws

#Configure AWS CLI
mkdir -p /root/.aws
echo "[default]" > /root/.aws/config
echo "region=us-west-1" >> /root/.aws/config
echo "output=json" >> /root/.aws/config
echo "[default]" > /root/.aws/credentials
echo "aws_access_key_id=${CliqrCloudAccountPwd}" >>/root/.aws/credentials
echo "aws_secret_access_key=${CliqrCloud_AccessSecretKey}" >> /root/.aws/credentials

cmd=$1 # Controls which part of this script is executed based on command line argument. Ex start, stop.

case ${cmd} in
    start)

        # Put config into file

        command="aws kinesisanalytics create-application --application-name ${applicationName}"
        if [ -n "${applicationDescription}" ]; then
            command+=" --application-description ${applicationDescription}"
        fi
        if [ -n "${inputs}" ]; then
            echo ${inputs} > tempfile
            command+=" --inputs file://tempfile"
        fi
        if [ -n "${outputs}" ]; then
            echo ${outputs} > tempfile
            command+=" --outputs file://tempfile"
        fi
        if [ -n "${cloudWatchLoggingOptions}" ]; then
            echo ${cloudWatchLoggingOptions} > tempfile
            command+=" --cloud-watch-logging-options file://tempfile"
        fi
        if [ -n "${applicationCode}" ]; then
            command+=" --application-code ${applicationCode}"
        fi
        msg=$(${command} 2>&1) || \
            error "Failed to create delivery stream: ${msg}"
        ;;
    stop)
        ;;
    update)
        ;;
    *)
        exit 127
        ;;
esac
