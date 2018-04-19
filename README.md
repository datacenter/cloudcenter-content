# cloudcenter-content

## Applications:

## Services:
See the services README.md for instructions on working with and importing and exporting services.

### Importing/Exporting Services
See README.md in services folder for instructions.


## Callouts

Make sure to include subfolders for each topic that might be part of a whole logical integration, such as both IPAM and IPAM2. These should be structured just as the callout directory structure would be in the CCO itself. So it should include callout.conf files, plus whatever other scripts are needed. You might also need to include a bash script that would perform other setup tasks, like installing the right version of python requests, downloading a particular library or whatever.

## Other:

Miscellaneous other useful scripts and integrations that don't fit into any of the other categories.

## Best Practices for Contributions

- use straight URL references rather than CloudCenter repo references in the service definition
- Link to publically available files, preferably right from this github repo.
- if linking to files in a git repo, link to a specific tag, not a branch. This avoids the service in use from changing/breaking just because someone checked in some new code.

## Tools and resources

A useful Postman collection to help you with CloudCenter API calls:
[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/46991f84de724bcab198)

Or just import the collection from this file: https://www.getpostman.com/collections/46991f84de724bcab198