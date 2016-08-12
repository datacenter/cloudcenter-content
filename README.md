# cloudcenter-content

A useful Postman collection to help you with CloudCenter API calls:
[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/46991f84de724bcab198)

APPS:

SERVICES:

To import the service, use curl and point it to the manifest file:
curl -k -X POST -H "Content-Type: application/json" --data-binary "@<path to servicemanifest file>" "https://<API username>:<API password>@<ccm IP>/v1/tenants/<tenant ID>/services/"
Ex: curl -k -X POST -H "Content-Type: application/json" --data-binary "@services/armtemplate/armtemplate.servicemanifest" "https://cliqradmin:82EBB1234C65EDB1@23.22.49.232/v1/tenants/1/services/"
IMPORTANT: If you have trouble, make sure the service manifest file DOESN'T have a logoPath or id parameter in there. id is usually at the very bottom of the file.


To export the service, use curl and point it to the service you want to export, saving it to a file:
curl -k -X GET -H "Content-Type: application/json" "https://<API username>:<API password>@<ccm IP>/v1/tenants/<tenant ID>/services/<service ID>" > <servicename>.servicemanifest
Ex: curl -k -X GET -H "Content-Type: application/json" "https://cliqradmin:82EBB1234C65EDB1@23.22.49.232/v1/tenants/1/services/64 > myservice.servicemanifest
IMPORTANT: Then open the file and strip out the logoPath and id parameters.

OTHER: