#!/usr/bin/env python
from __future__ import print_function
import pan.xapi
import sys
import xml.etree.ElementTree as ET
import os


def print_log(msg):
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_LOG_MSG_END")


def print_error(msg):
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_ERR_MSG_END")


def print_ext_service_result(msg):
    print("CLIQR_EXTERNAL_SERVICE_RESULT_START")
    print(msg)
    print("CLIQR_EXTERNAL_SERVICE_RESULT_END")


# First argument controls the script: start, stop, etc.
cmd = sys.argv[1]

# Get any user-defied tags
# tags = os.environ["USER_DEFINED_TAGS"].split(',')

# Get dependency (lower) tiers.
dependencies = os.environ["CliqrDependencies"].split(',')
addrGrp = "addrGrp" + os.environ['parentJobId']

api_username = os.getenv('panext_username')
api_password = os.getenv('panext_password')
hostname = os.getenv('panext_hostname')
panext_fwtag = os.environ["panext_fwtag"]

if cmd == "start":
    # xpath = "/config/devices/entry/vsys/entry/address"
    xpath = "/config/devices/entry/vsys"

    # Build the XML tree for the settings we want to add to the FW. In this case adding a named address.
    root = ET.Element("entry")
    root.set("name", "vsys1")
    address = ET.SubElement(root, "address")

    addressGrp = ET.SubElement(root, "address-group")
    addressGrpEntry = ET.SubElement(addressGrp, "entry")
    addressGrpEntry.set("name", addrGrp)

    grpEntryStatic = ET.SubElement(addressGrpEntry, "static")
    tag = ET.SubElement(addressGrpEntry, "tag")
    memberTag = ET.SubElement(tag, "member")
    memberTag.text = panext_fwtag

    for dependency in dependencies:
        depNodeIPs = os.environ["CliqrTier_" + dependency + "_IP"].split(',')
        depNodeIDs = os.environ["CliqrTier_" + dependency + "_NODE_ID"].split(',')
        for nodeID, nodeIP in zip(depNodeIDs, depNodeIPs):
            entryAddress = ET.SubElement(address, "entry")
            entryAddress.set("name", nodeID)
            entryAddress.set("addrGrp", addrGrp)
            ip = ET.SubElement(entryAddress, "ip-netmask")
            ip.text = nodeIP
            description = ET.SubElement(entryAddress, "description")
            description.text = nodeID
            grpEntryStaticMember = ET.SubElement(grpEntryStatic, "member")
            grpEntryStaticMember.text = nodeID

    data = ET.tostring(root)
    print(data)

    try:
        xapi = pan.xapi.PanXapi(api_username=api_username, api_password=api_password, hostname=hostname)
        print("Successfully Connected!")

        xapi.op(cmd='show system info', cmd_xml=True)
        print(xapi.xml_result())

        # set the config using the above xpath
        xapi.set(xpath, element=data)
        print(xapi.xml_result())

        # commit the config. Make sure to add the xml command.
        xapi.commit('<commit/>')
        print(xapi.xml_result())

    except pan.xapi.PanXapiError as msg:
        print('pan.xapi.PanXapi:', msg, file=sys.stderr)
        sys.exit(1)

elif cmd == "stop":

    # Build the XML tree for the settings we want to add to the FW. In this case adding a named address.
    # root.set("name", "Kimberly")

    try:
        xapi = pan.xapi.PanXapi(api_username=api_username, api_password=api_password, hostname=hostname)
        print("Successfully Connected!")

        xapi.op(cmd='show system info', cmd_xml=True)
        print(xapi.xml_result())

        # Delete Address Group

        xpath = "/config/devices/entry/vsys/entry/address-group/entry[@name='" + addrGrp + "']"
        xapi.delete(xpath)
        print(xapi.xml_result())

        # Delete Address with appropriate addrGrp attribute
        xpath = "/config/devices/entry/vsys/entry/address/entry[@addrGrp='" + addrGrp + "']"
        xapi.delete(xpath)
        print(xapi.xml_result())

        # commit the config. Make sure to add the xml command.
        xapi.commit('<commit/>')
        print(xapi.xml_result())

    except pan.xapi.PanXapiError as msg:
        print('pan.xapi.PanXapi:', msg, file=sys.stderr)
        sys.exit(1)

elif cmd == "reload":
    pass
