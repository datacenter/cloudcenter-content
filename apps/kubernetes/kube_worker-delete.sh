#!/bin/bash -x
# https://kubernetes.io/docs/setup/independent/install-kubeadm/
exec > >(tee -a /var/tmp/kube_worker-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

env

cd /tmp/

kubectl drain ${cliqrNodeHostname} --delete-local-data --force --ignore-daemonsets
kubectl delete node ${cliqrNodeHostname}

sudo kubeadm reset

sudo mv ~/cliqr.repo /etc/yum.repos.d/
