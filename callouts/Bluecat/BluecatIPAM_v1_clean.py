#!/usr/bin/env python

import json
import requests
import re
import os
from xml.etree import ElementTree
from requests.packages.urllib3.exceptions import InsecureRequestWarning

requests.packages.urllib3.disable_warnings()

#
#  Function    - bluecatLogin
#
#  Description
#
#  Inputs
#    bluecatHost
#    bluecatUser
#    bluecatPassword
#
#  Output
#    sessionId
#
def bluecatLogin(bluecatHost, bluecatUser, bluecatPassword):
    bluecatApi = "https://" + bluecatHost + "/Services/API"
    headers = {'content-type': 'text/xml'}
    msgXML = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:api=\"http://api.proteus.bluecatnetworks.com\">"\
        "<soapenv:Header/>"\
        "<soapenv:Body>"\
            "<api:login>"\
                "<username>" + bluecatUser + "</username>"\
                "<password>" + bluecatPassword + "</password>"\
            "</api:login>"\
        "</soapenv:Body>"\
    "</soapenv:Envelope>"

    r = requests.post(bluecatApi, msgXML, headers=headers, verify=False)
    sessionId = r.cookies["JSESSIONID"]
    return "JSESSIONID=" + sessionId;
# END bluecatLogin


#
#  Function    - bluecatGetNextAvailableIP4Address
#
#  Description
#
#  Inputs
#    bluecatHost
#    sessionid
#    ip4NetworkOID
#
#  Output
#    nextIP4Address
#
def bluecatGetNextAvailableIP4Address(bluecatHost, sessionid, ip4NetworkOID):
    bluecatApi = "https://" + bluecatHost + "/Services/API"
    headers = {'content-type': 'text/xml','Cookie': sessionid}
    msgXML = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:api=\"http://api.proteus.bluecatnetworks.com\">"\
        "<soapenv:Header/>"\
        "<soapenv:Body>"\
            "<api:getNextAvailableIP4Address>"\
                "<parentId>" + ip4NetworkOID + "</parentId>"\
            "</api:getNextAvailableIP4Address>"\
        "</soapenv:Body>"\
    "</soapenv:Envelope>"

    r = requests.post(bluecatApi, msgXML, headers=headers, verify=False)

    xmlDoc = ElementTree.fromstring(r.content)
    nextIP4Address = xmlDoc.find("{http://schemas.xmlsoap.org/soap/envelope/}Body/{http://api.proteus.bluecatnetworks.com}getNextAvailableIP4AddressResponse/return").text
    return nextIP4Address;
# END bluecatGetNextAvailableIP4Address


#
#  Function    - bluecatGetEntityByName
#
#  Description
#
#  Inputs
#    N/A
#
#  Output
#    True
#
def bluecatGetEntityByName(bluecatHost, sessionId, parentId, entityName, entityType):
    bluecatApi = "https://" + bluecatHost + "/Services/API"
    headers = {'content-type': 'text/xml','Cookie': sessionId}
    msgXML = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:api=\"http://api.proteus.bluecatnetworks.com\">"\
        "<soapenv:Header/>"\
        "<soapenv:Body>"\
            "<api:getEntitiesByName>"\
                "<parentId>" + parentId + "</parentId>" \
                "<name>" + entityName + "</name>" \
                "<type>" + entityType + "</type>" \
                "<start>0</start>" \
                "<count>1</count>" \
            "</api:getEntitiesByName>"\
        "</soapenv:Body>"\
    "</soapenv:Envelope>"

    r = requests.post(bluecatApi, msgXML, headers=headers, verify=False)
    xmlDoc = ElementTree.fromstring(r.content)

    entityId = xmlDoc.find("{http://schemas.xmlsoap.org/soap/envelope/}Body/{http://api.proteus.bluecatnetworks.com}getEntitiesByNameResponse/return/item/id").text
    return entityId

# END bluecatGetEntityByName


#
#  Function    - bluecatGetEntityByName
#
#  Description
#
#  Inputs
#    N/A
#
#  Output
#    True
#
def bluecatAddHostRecord(bluecatHost, sessionId, dnsViewOID, nextHostname, domainName, ipAddress):
    bluecatApi = "https://" + bluecatHost + "/Services/API"
    headers = {'content-type': 'text/xml','Cookie': sessionId}
    msgXML = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:api=\"http://api.proteus.bluecatnetworks.com\">"\
        "<soapenv:Header/>"\
        "<soapenv:Body>"\
            "<api:addHostRecord>"\
                "<viewId>" + dnsViewOID + "</viewId>" \
                "<absoluteName>" + nextHostname + "." + domainName + "</absoluteName>" \
                "<addresses>" + ipAddress + "</addresses>" \
                "<ttl>-1</ttl>" \
                "<properties/>"\
            "</api:addHostRecord>"\
        "</soapenv:Body>"\
    "</soapenv:Envelope>"

    r = requests.post(bluecatApi, msgXML, headers=headers, verify=False)
    xmlDoc = ElementTree.fromstring(r.content)

    if r.status_code is 200:
        return xmlDoc.find("{http://schemas.xmlsoap.org/soap/envelope/}Body/{http://api.proteus.bluecatnetworks.com}addHostRecordResponse/return").text

    else:
        print "ERROR: " + str(r.status_code)
# END bluecatAddHostRecord


#
#  Function    - bluecatFullDeploy
#
#  Description
#
#  Inputs
#    N/A
#
#  Output
#    True
#
def bluecatFullDeploy(bluecatHost, sessionId, serverId):
    bluecatApi = "https://" + bluecatHost + "/Services/API"
    headers = {'content-type': 'text/xml','Cookie': sessionId}
    msgXML = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:api=\"http://api.proteus.bluecatnetworks.com\">"\
        "<soapenv:Header/>"\
        "<soapenv:Body>"\
            "<api:deployServer>"\
                "<serverId>" + serverId + "</serverId>"\
            "</api:deployServer>"\
        "</soapenv:Body>"\
    "</soapenv:Envelope>"

    r = requests.post(bluecatApi, msgXML, headers=headers, verify=False)
    if r.status_code is 200:
        return True
    else:
        print "ERROR: " + r.status_code
# END bluecatFullDeploy


#
#  Function    - bluecatLogout
#
#  Description
#
#  Inputs
#    N/A
#
#  Output
#    True
#
def bluecatLogout(bluecatHost):
    bluecatApi = "https://" + bluecatHost + "/Services/API"
    headers = {'content-type': 'text/xml'}
    msgXML = "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:api=\"http://api.proteus.bluecatnetworks.com\">"\
        "<soapenv:Header/>"\
        "<soapenv:Body>"\
            "<api:logout/>"\
        "</soapenv:Body>"\
    "</soapenv:Envelope>"

    r = requests.post(bluecatApi, msgXML, headers=headers, verify=False)
    return True
# END bluecatLogout


def main():
    bluecatHost = "<BLUECAT_IP>"
    bluecatUser = "<BLUECAT_USER>"
    bluecatPassword = "<BLUECAT_PASSWORD>"

    # Object ID Names
    bluecatConfigName = "<BLUECAT_CONFIG_NAME>"
    bluecatDnsViewName = "Internal"
    bluecatServerName = "<BLUECAT_SERVER_NAME>"
    ipObjectId = "<IP_OBJECT_ID>"


    # Get and domain
    hostname = os.environ['vmName']
    #print "VM Name: " + hostname
    domain = "<DOMAIN>"

    #print "Logging in..."
    sessionId = bluecatLogin(bluecatHost, bluecatUser, bluecatPassword)

    # Get and assign the next IP/Hostname
    #print "Getting IP Address"
    ipAddress = bluecatGetNextAvailableIP4Address(bluecatHost, sessionId, ipObjectId)

    #print "Adding record: " + ipAddress + " - " + hostname
    bluecatConfigId = bluecatGetEntityByName(bluecatHost, sessionId, "0", bluecatConfigName, "Configuration")
    bluecatDnsViewId = bluecatGetEntityByName(bluecatHost, sessionId, bluecatConfigId, bluecatDnsViewName, "View")
    bluecatAddHostRecord(bluecatHost, sessionId, bluecatDnsViewId, hostname, domain, ipAddress)

    # Bluecat Full Deploy
    bluecatServerId = bluecatGetEntityByName(bluecatHost, sessionId, bluecatConfigId, bluecatServerName, "Server")
    bluecatFullDeploy(bluecatHost, sessionId, bluecatServerId)

    #print "Logging out..."
    bluecatLogout(bluecatHost)

    #print "Setting outputs..."
    try:
        print "DnsServerList=<DNS_SERVER_IP>"
        print "nicCount=1"
        print "nicIP_0=" + ipAddress
        print "nicDnsServerList_0=<DNS_SERVER_IP>"
        print "nicGateway_0=<GATEWAY_IP>"
        print "nicNetmask_0=<SUBNET>"
        print "domainName=<DOMAIN>"
        print "HWClockUTC=true"
        print "timeZone=<TIMEZONE>"
        print "osHostname=" + hostname
        # print "infobloxFQDN=<FQDN>"
    except Exception as e:
        # print "There was an error"
        print e

main()
