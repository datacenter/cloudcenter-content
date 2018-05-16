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

if [ -n "${kinesis_gitTag}" ]; then
    tag="${kinesis_gitTag}"
else
    tag="kinesis"
fi

if [ ! -z "$region" ];
then
        region="us-east-1";
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
echo "region=$region" >> /root/.aws/config
echo "output=json" >> /root/.aws/config
echo "[default]" > /root/.aws/credentials
echo "aws_access_key_id=${CliqrCloudAccountPwd}" >>/root/.aws/credentials
echo "aws_secret_access_key=${CliqrCloud_AccessSecretKey}" >> /root/.aws/credentials

cmd=$1 # Controls which part of this script is executed based on command line argument. Ex start, stop.

case ${cmd} in
    start)

        # Put config into file

        command="aws kinesis create-stream --stream-name ${streamName} --shard-count ${shardCount}"
        msg=$(${command} 2>&1) || \
            error "Failed to create kinesis stream: ${msg}"
        ;;
    stop)
        ;;
    update)
        ;;
    *)
        exit 127
        ;;
esac
