#!/bin/bash
. /utils.sh

# Required Service Parameters:
# gitTag - The tag or branch of code that you want to pull from github
# TODO

# Print the env to the CCM UI for debugging. Remove this line for production.
print_log "$(env)"

defaultGitTag="route53"
if [ -n "$gitTag" ]; then
    print_log  "Found gitTag parameter gitTag = ${gitTag}"
else
     print_log  "Didn't find custom parameter gitTag. Using gitTag = ${defaultGitTag}"
     gitTag=${defaultGitTag}
fi

print_log "Tag/branch for code pull set to $tag"

cmd=$1 # Controls which part of this script is executed based on command line argument. Ex start, stop.
