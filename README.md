# cloudcenter-content

## Applications:

## Services:

### Importing Services

- To import the service, use curl and point it to the manifest file:
-- `curl -k -X POST -H "Content-Type: application/json" --data-binary "@<path to servicemanifest file>" "https://<API username>:<API password>@<ccm IP>/v1/tenants/<tenant ID>/services/"`
-- Ex: `curl -k -X POST -H "Content-Type: application/json" --data-binary "@services/armtemplate/armtemplate.servicemanifest" "https://cliqradmin:82EBB1234C65EDB1@23.22.49.232/v1/tenants/1/services/"`
- **IMPORTANT:** If you have trouble, make sure the service manifest file DOESN'T have a logoPath or id parameter in there. id is usually at the very bottom of the file.


### Exporting Services
- To export a service, use curl and point it to the service you want to export, saving it to a file:
-- `curl -k -X GET -H "Content-Type: application/json" "https://<API username>:<API password>@<ccm IP>/v1/tenants/<tenant ID>/services/<service ID>" > <servicename>.servicemanifest`
-- Ex: `curl -k -X GET -H "Content-Type: application/json" "https://cliqradmin:82EBB1234C65EDB1@23.22.49.232/v1/tenants/1/services/64 > myservice.servicemanifest`
- **IMPORTANT**: Then open the file and strip out the logoPath and id parameters.

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
