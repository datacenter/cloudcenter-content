# Infoblox

Infoblox callout integration sript examples. There are two versions:
- One version uses a library to connect to Infoblox for convenience, but only works on newer versions of the API that support the next_avilable function for IP address in the create_host API call. This is the recommended script for newer APIs.
- The other version is written just using requests, which works with older versions of the API but is more verbose.