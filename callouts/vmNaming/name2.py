#!/home/cliqruser/callouts/bin/python
"""
Another vmnaming example, this one with logging and stripping
some characters that don't work when used as a hostname.
"""
import os
import uuid
import argparse
import re
import logging

parser = argparse.ArgumentParser()
log_choices = {
    'critical': logging.CRITICAL,
    'error': logging.ERROR,
    'warning': logging.WARNING,
    'info': logging.INFO,
    'debug': logging.DEBUG
}
parser.add_argument("-l", "--level", help="Set logging level.",
                    choices=log_choices, default='info')

args = parser.parse_args()
parser.parse_args()

log_file = '/usr/local/cliqr/callout/callout.log'
logging.basicConfig(
    filename=log_file,
    format="VMNAME:%(levelname)s:{job_name}:{tier}:%(message)s".format(
        job_name=os.getenv('eNV_parentJobName'),
        tier=os.getenv('eNV_cliqrAppTierName')
    ),
    level=log_choices[args.level]
)
logging.captureWarnings(True)
print("Log file at: {}".format(log_file))

# username = os.getenv('eNV_launchUserName').split("_")[0]
# os_type = os.getenv('eNV_osName')

# Remove _ and - from these for compatibility reasons.
job_name = re.sub('[_-]', '', os.getenv('eNV_parentJobName'))
tier_name = re.sub('[_-]', '', os.getenv('eNV_cliqrAppTierName'))

uuid = uuid.uuid4().hex  # Use hex just to get rid of the hyphens.

name = "{}{}{}".format(
    job_name[:6],
    tier_name[:6],
    uuid[:3]
)
logging.info("Name: {}".format(name))
print("vmName={name}".format(name=name))