# Services

## Contributing services
- Include all necessary scripts along with a servicemanifest file and a logo that someone can use to import the service into their instance. See below for export instructions.

## Importing and Exporting Services
- The servicemanifest file can be exported or imported using the serviceTool.py script

## serviceTool.py
This script will export a CloudCenter service to a service manifest file. This will allow the service to be updated and then re-imported
into either the same instance to update it or into another instance.

- `usage serviceTool.py [-h] [-o] (-e servicename | -i filename) username apiKey ccm`
- `python serviceTool.py -h` for help.
- This script includes the following modules, which may need to be installed on your system:
  - argparse
  - re
  - requests
  - sys
  - json
  - logging
  - requests
  - Try
    - `yum install python pip`
    - `pip install pip --upgrade`
    - `pip install <module>`

### Known Issues:
You may see that your service was created and the ID is provided,
but it still doesn't show up in the list. This could be due to a bug
regarding parent services. To workaround until that is fixed,
just edit/view a different service and change the ID in the URL
to the ID of your new service, then resave your service.