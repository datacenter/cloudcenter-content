#!/bin/bash -x
# Place this script into the INSTALL lifecycle action in your CentOS service.
. /utils.sh

env

echo "${sshKey}" > key
chmod 400 key