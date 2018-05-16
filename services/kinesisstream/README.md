# Kinesis Streams

https://aws.amazon.com/kinesis/data-streams

https://docs.aws.amazon.com/cli/latest/reference/kinesis/create-stream.html

# Installation
Use the serviceTool.py (cloudcenter-content/service/serviceTool.py)
utility to import this service into your instance.

`python ..\serviceTool.py <cc username> <api key> <ccm hostname/ip>
-i .\kinesisstream.servicemanifest -l .\kinesis.png
[--overwrite] [-d debug]`

You can use this tool repeatedly with the --overwrite flag if you want
to make changes to the servicemanifest file and import thsoe into your
instance (rather then just editing the service in the UI.)
