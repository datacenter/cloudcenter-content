#!/bin/bash -x
exec > >(tee -a /var/tmp/snow-mid-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

cd /tmp
curl -o mid.zip "https://install.service-now.com/glide/distribution/builds/package/mid/2017/05/31/mid.jakarta-05-03-2017__patch0-05-18-2017_05-31-2017_2011.linux.x86-64.zip"