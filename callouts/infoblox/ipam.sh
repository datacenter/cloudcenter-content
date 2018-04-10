#!/bin/bash

script="/usr/local/cliqr/callout/ipam/ipam.py"
curl --silent --output ${script} "http://172.16.204.50/root/auslab/raw/master/callouts/ipam/ipam.py"
chmod +x ${script}
chown cliqruser:cliqruser ${script}
${script}