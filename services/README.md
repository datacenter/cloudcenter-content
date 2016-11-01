# Services

## Contributing services
- Include all necessary scripts along with a servicemanifest file that someone can use to import the service into their instance. See below for export instructions.

## Export instructions:
- Use the exportService.py script to export the service from your instance into a .servicemanifest file. This file can be used with import instructions below.
- `python exportService.py <api username> <api key> <ccm address/hostname> <serviceName>`
- This script will automatically output a file to your current directory called <servicename>.servicemanifest.

## Importing Services

- To import the service, use curl and point it to the manifest file:
-- `curl -k -X POST -H "Content-Type: application/json" --data-binary "@<path to servicemanifest file>" "https://<API username>:<API password>@<ccm IP>/v1/tenants/<tenant ID>/services/"`
-- Ex: `curl -k -X POST -H "Content-Type: application/json" --data-binary "@services/armtemplate/armtemplate.servicemanifest" "https://cliqradmin:82EBB1234C65EDB1@23.22.49.232/v1/tenants/1/services/"`
- **IMPORTANT:** If you have trouble, make sure the service manifest file DOESN'T have a logoPath or id parameter in there. id is usually at the very bottom of the file.
