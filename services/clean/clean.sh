#!/bin/bash -x
. /utils.sh

# Required Service Parameters:
# gitTag - The tag or branch of code that you want to pull from github
# TODO

# Print the env to the CCM UI for debugging. Remove this line for production.
print_log "$(env)"

if [ -n $gitTag ]; then
    tag=$gitTag
else
    tag="clean"
fi

print_log "Tag/branch for code pull set to $tag"

yum install -y python-pip
pip install --upgrade pip requests

wget -N --no-check-certificate --no-cache https://raw.githubusercontent.com/datacenter/cloudcenter-content/${tag}/services/clean/clean.py

python clean.py ${apiUN} ${apiPW} ${ccm}