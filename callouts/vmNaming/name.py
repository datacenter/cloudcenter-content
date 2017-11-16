#!/usr/bin/env python
# This is an example of how you might build up a vmname to suit a particular custom naming convention. It can/should be
# modified to suit your particular use-case.
# Very Important: NEVER depend on use-supplied data for a valid name. Always have a default case in the event the user
# doesn't supply any value.

import os
import random
import string


# Gather up the information needed from environment variables.
# Need to look at the logs to get the actual env variables names. These are wrong, but give the right idea.
depEnv = os.environ['depEnv']
osType = os.environ['eNV_osName']

# Create maps (dictionaries) that associate the CloudCenter info to the custom values that should go into the VM name.
# You will need to look in the callout logs for the keys to use for this.
loc = {
    "Region1": "DCC",
    "Region2": "DC2"
}

platform = {
    "Windows": "W",
    "Linux": "L"
}

# It might be better to use a tag for this instead of the deployment env.
usage = {
    "depenv1": "P",
    "depenv2": "QA",
    "depenv3": "S"
}

# Allow the admin to set a role custom parameter to control that part of the name,
# but if it's not set then just use "SRV"
role = os.getenv('role', "SRV")[:3] # Look for a role parameter, return SRV as a default. Cut to first 3 chars only.

# Generate a random sequence of uppercase letters and didgits of length 4
rand = ''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(5))

# Start with an empty name and build it up.
name = "{location}-{platform}{role}{usage}{rand}".format(
    location = loc[region],
    platform = platform[osType],
    role = role,
    usage = usage[depEnv],
    rand = rand
)

# For AD compatibilty, check to ensure the name isn't longer than 15 characters.
if len(name) > 15:
    print("Length of generated name is greater than 15, which is invalid. Exiting")
    sys.exit(1)
else:
    print("vmName={name}".format(name = name))

