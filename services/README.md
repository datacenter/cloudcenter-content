# Services

## Contributing services
- Include all necessary scripts along with a servicemanifest file that someone can use to import the service into their instance. See below for export instructions.

## Importing and Exporting Services
- The servicemanifest file can be exported or imported using the serviceTool.py script

## serviceTool.py
`usage serviceTool.py [-h] [-o] (-e servicename | -i filename) username apiKey ccm`

This script will export a CloudCenter service to a service manifest file. This will allow the service to be updated and then re-imported
into either the same instance to update it or into another instance.
