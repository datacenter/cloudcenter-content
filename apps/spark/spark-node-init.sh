#!/bin/bash -x
exec > >(tee -a /var/tmp/spark-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh


sudo mv /etc/yum.repos.d/cliqr.repo ~ # Move it back at end of script.


agentSendLogMessage "Doing yum update"
sudo yum update -y
pre_reqs="java-1.8.0-openjdk"
agentSendLogMessage "Installing pre-reqs: ${pre_reqs}"
sudo yum install -y ${pre_reqs}

cd /tmp
spark_file="spark.tgz"
agentSendLogMessage "Downloading ${spark_package}"
curl -o ${spark_file} "${spark_package}"
spark_folder=`tar -tzf ${spark_file} | head -n1`
tar -xvf ${spark_file} -C ~
rm -f ${spark_file}

ln -s ~/${spark_folder} ~/spark

echo "export SPARK_HOME=~/spark" >> ~/.bashrc
echo 'export PATH=${SPARK_HOME}/bin:${PATH}' >> ~/.bashrc
source ~/.bashrc




sudo mv ~/cliqr.repo /etc/yum.repos.d/
