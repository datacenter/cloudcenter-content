import socket
import json
import os
import argparse
import errno
from urlparse import urlparse

###############################################################################
#########################      TEST CONSTANTS    ##############################
###############################################################################

# The Unit is seconds
CONNECTION_WAIT_TIME = 10

#JSON Related Settings
ROOT_ELEMENT = 'CloudCenterComponents'
CLOUD_REGIONS_ELEMENT = 'CloudRegions'
CCM_ELEMENT = 'CCM'
MONITOR_ELEMENT = 'MON'
REPOS_ELEMENT = 'REPOS'

CCM_COMPONENT = 'CCM'
CCM_SA_COMPONENT = 'CCM_SA'
DB_COMPONENT = 'MGMTPOSTGRES'
CCO_COMPONENT = 'CCO'
AMQP_COMPONENT = 'AMQP'
GUAC_COMPONENT = 'GUAC'
CLIENT_COMPONENT = 'CLIENT'
EXT_SCRIPT_COMPONENT = 'EXT_SCRIPT_EXECUTOR'
AGENT_COMPONENT = 'AGENT'
DEDICATED_GUAC_COMPONENT = 'Dedicated_Guacamole_Server'
DEDICATED_EXTERNAL_SCRIPT_EXECUTOR = 'Dedicated_External_Script_Executor'
MON_COMPONENT = 'MON'

CCM_LB_COMPONENT = 'CCM_LB'
CCO_LB_COMPONENT = 'CCO_LB'
AMQP_LB_COMPONENT = 'AMQP_LB'
GUAC_LB_COMPONENT = 'GUAC_LB'
MON_LB_COMPONENT = 'MON_LB'

BUNDLE_STORE_COMPONENT = 'BUNDLE_STORE'
PACKAGE_STORE_COMPONENT = 'PACKAGE_STORE'
DOCKER_REGISTRY_COMPONENT = 'DOCKER_REGISTRY'

MODE = 'mode'
NAME = 'name'
COMPONENTS = 'components'
REGION = 'region'
IP = 'IP'
NOT_PROVIDED = 'Not_Provided'

HA_MODE = 'HA'
NONE_HA_MODE = 'NON-HA'
NONE_HA_STANDALONE_MODE = 'NON-HA-STANDALONE'
HA_PRIMARY = '_PRIMARY'
HA_SECONDARY = '_SECONDARY'
HA_TERTIARY = '_TERTIARY'
DB_MASTER = '_MASTER'
DB_SLAVE = '_SLAVE'
HA_VIP = '_VIP'
IP_KEY = '_IP'

AMQP_PORTS = [5671]
AMQP_CLUSTER_PORTS = [4369, 25672]
GUAC_ACCESS_PORTS = [443]
GUAC_PORTS = [8443]
REV_CONN_PORTS = [7789]

CCO_PORTS = [8443]
CCO_HAZELCAST_PORTS = [5701]
CCO_MONGO_PORTS = [27017]
DOCKER_PORTS = [2376]

CCM_PORTS = [8443]
CCM_ACCESS_PORTS = [80, 443]
CCM_HAZELCAST_PORTS = [5703]
DB_PORTS = [5432]

DOCKER_REGISTRY_PORTS = [5000]

CCM_TO_MON_PORTS = [4560, 8881]
CCO_TO_MON_PORTS = [4560, 8881]
CLIENT_TO_MON_PORTS = [8882]

SUCCESS = 'Success'
FAILED = 'Failed'
ERROR = 'Error'

#Result related constants
DEFAULT_OUTPUT_FILE = '/tmp/cloudcenter_validator.json'
TARGET_ROLE = 'TO_ROLE'
TARGET_IP = 'TO_IP'
TARGET_PORT = 'PORT'
RESULT = 'RESULT'

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
###############################################################################
####### Testing Connection
###############################################################################

def customEnum(**named_values):
     return type('CustomEnum', (), named_values)

STATUS = customEnum(CONNECTED="connected", REFUSED="refused", TIMEOUT="timeout")

def connectionTest(ipAddress, port):
    s = socket.socket()
    s.settimeout(CONNECTION_WAIT_TIME)

    try:
        s.connect((ipAddress, port))
        s.close()
        return STATUS.CONNECTED
    except socket.timeout, exc:
        return STATUS.TIMEOUT
    except socket.gaierror, exc:
        return STATUS.TIMEOUT
    except socket.error, exc:
        if exc.errno != errno.ECONNREFUSED:
            return STATUS.TIMEOUT
        else:
            return STATUS.REFUSED

def testConnAndPrint(ipAddress, port, key, otherFields=None):
    result = None
    postInstallMode = args.postInstallMode

    if ipAddress is None:
        status = STATUS.TIMEOUT
    else:
        status = connectionTest(ipAddress, port)

    if status == STATUS.TIMEOUT:
        print '\t', bcolors.FAIL, 'Component %s IP %s Port %d is not open!' % (key, ipAddress, port), bcolors.ENDC
        result = FAILED
    #Uncomment the following lines when we find cases that the firewall give connection refused instead of
    #timeout when the port is not open
    elif status == STATUS.REFUSED and postInstallMode:
        print '\t', bcolors.FAIL, 'Component %s IP %s Port %d is open but refusing connection!' % (key, ipAddress, port), bcolors.ENDC
        result = FAILED
    else:
        print '\t', bcolors.OKGREEN, 'Component %s IP %s Port %d passed!' % (key, ipAddress, port), bcolors.ENDC
        result = SUCCESS

    if ipAddress is None:
        ipAddress = NOT_PROVIDED

    value = {TARGET_ROLE: key, TARGET_IP: ipAddress, TARGET_PORT: port, RESULT: result}
    if otherFields is not None:
        for key in otherFields.keys():
            value[key] = otherFields[key]
    return value


def jsonParser(jsonFile):
    if not os.path.exists(jsonFile):
        print 'JSON file "%s" provided does not exist!' % jsonFile
        return None
    else:
        f = open(jsonFile, 'r')

        try:
            data = json.load(f)
            return data
        except ValueError, e:
            print 'The content of the json file %s cannot be parsed, please check' % jsonFile
            print e
            return None
        finally:
            f.close()

###############################################################################
####     Helper functions
###############################################################################

def testPackageStore(data):
    # Test Package repo connectivity
    result = []
    print 'Test Package Store connectivity'
    repos = data[REPOS_ELEMENT]
    componentsToTest = [PACKAGE_STORE_COMPONENT]

    for key in componentsToTest:
        if key in repos.keys():
            url = getDomainFromURl(repos[key])
            port = getPortFromUrl(repos[key])
            if port is None:
                print bcolors.FAIL, 'Unknown bundle type for url', url, bcolors.ENDC
            else:
                result.append(testConnAndPrint(url, port, PACKAGE_STORE_COMPONENT))
        else:
            result.append(testConnAndPrint(None, port, PACKAGE_STORE_COMPONENT))
    return result

def testBundleStore(data):
    # Test BUNDLE Store connectivity
    print 'Test Bundle Store connectivity'
    result = []
    repos = data[REPOS_ELEMENT]
    componentsToTest = [BUNDLE_STORE_COMPONENT]

    for key in componentsToTest:
        if key in repos.keys():
            url = getDomainFromURl(repos[key])
            port = getPortFromUrl(repos[key])
            if port is None:
                print bcolors.FAIL, 'Unknown bundle type for url', url, bcolors.ENDC
            else:
                result.append(testConnAndPrint(url, port, BUNDLE_STORE_COMPONENT))
        else:
            result.append(testConnAndPrint(None, port, BUNDLE_STORE_COMPONENT))
    return result


###############################################################################
####     Components Testing Code
###############################################################################

def testCCM(data, role):
    result = []
    postInstallMode = args.postInstallMode

    if CCM_ELEMENT not in data.keys():
        errMsg = 'No CCM element defined!'
        print errMsg
        return {ERROR : errMsg}
    CCMs = data[CCM_ELEMENT]

    targetCCMIP = None
    targetCCMIPKey = role + '_IP'
    if targetCCMIPKey in CCMs.keys():
        targetCCMIP = CCMs[targetCCMIPKey]

    if targetCCMIP is None:
        errMsg = 'CCM %s cannot be found in the JSON file, please check the name provided' % (role,)
        print errMsg
        return {ERROR: errMsg}

    if role.startswith(CCM_LB_COMPONENT):
        componentsToTest = [CCM_SA_COMPONENT + HA_PRIMARY, CCM_SA_COMPONENT + HA_SECONDARY]

        for key in componentsToTest:
            print 'Test CCM %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in CCM_PORTS + CCM_ACCESS_PORTS:
                if ipKey in CCMs.keys():
                    result.append(testConnAndPrint(CCMs[ipKey], port, key))
                else:
                    result.append(testConnAndPrint(None, port, key))
    else:

        #Test All CCO first
        print 'Testing CCO ports from CCM'
        cloudRegions = data[CLOUD_REGIONS_ELEMENT]

        for cloudRegion in cloudRegions:
            CCO = cloudRegion[COMPONENTS][CCO_COMPONENT]
            print 'Test CCO', cloudRegion[NAME]
            mode = CCO[MODE]
            testComponents = []

            if mode == HA_MODE:
                testComponents = [CCO_LB_COMPONENT]
            else:
                testComponents = [CCO_COMPONENT]

            for key in testComponents:
                ipKey = key + IP_KEY
                for port in CCO_PORTS:
                    if ipKey not in CCO.keys():
                        result.append(testConnAndPrint(None, port, key, {REGION: cloudRegion[NAME]}))
                    else:
                        result.append(testConnAndPrint(CCO[ipKey], port, key, {REGION: cloudRegion[NAME]}))

        #Test Database connection
        testComponents = []
        mode = CCMs[MODE]
        if mode == NONE_HA_STANDALONE_MODE:
            testComponents = [DB_COMPONENT]
        elif mode == HA_MODE and postInstallMode:
            testComponents = [DB_COMPONENT + HA_VIP]
        elif mode == HA_MODE:
            testComponents = [DB_COMPONENT + DB_MASTER, DB_COMPONENT + DB_SLAVE]

        if len(testComponents) > 0:
            print 'Test Database connections from CCM'

        for key in testComponents:
            print 'Testing Database', key

            if not key.endswith(HA_VIP):
                ipKey = key + IP_KEY
            else:
                ipKey = key

            for port in DB_PORTS:
                if ipKey not in CCMs.keys():
                    result.append(testConnAndPrint(None, port, key))
                else:
                    result.append(testConnAndPrint(CCMs[ipKey], port, key))

        #Test Hazelcast connection in HA mode
        mode = CCMs[MODE]
        if mode == HA_MODE:
            testComponents = [CCM_SA_COMPONENT + HA_PRIMARY, CCM_SA_COMPONENT + HA_SECONDARY]
            testComponents.remove(role)

            print 'Test Hazelcast connection between CCMs'
            for key in testComponents:
                ipKey = key + IP_KEY
                for port in CCM_HAZELCAST_PORTS:
                    if ipKey in CCMs.keys():
                        result.append(testConnAndPrint(CCMs[ipKey], port, key))
                    else:
                        result.append(testConnAndPrint(None, port, key))

        #Test Monitor connection
        MONs = data[MONITOR_ELEMENT]
        if MONs == None:
            MONs = {}
        mode = MONs[MODE]
        if mode == HA_MODE:
            testComponents = [MON_LB_COMPONENT]
        else:
            testComponents = [MON_COMPONENT]

        print 'Test Monitor connection from CCM'
        for key in testComponents:
            ipKey = key + IP_KEY
            for port in CCM_TO_MON_PORTS:
                if ipKey in MONs.keys():
                    result.append(testConnAndPrint(MONs[ipKey], port, key))
                else:
                    result.append(testConnAndPrint(None, port, key))

        result += testPackageStore(data)
    return result

def getDomainFromURl(url):
    urlProps = urlparse(url)

    return urlProps.netloc

def getPortFromUrl(url):
    urlProps = urlparse(url)

    port = urlProps.port

    if port is None:
        if urlProps.scheme == 'http':
            port = 80
        elif urlProps.scheme == 'https':
            port = 443
    return port



def testCCO(data, role, region):
    # Test All CCO first
    if CLOUD_REGIONS_ELEMENT not in data.keys():
        errMsg = 'No CloudRegions element defined!'
        print errMsg
        return {ERROR : errMsg}

    CCOs = data[CLOUD_REGIONS_ELEMENT]
    targetCCO = None
    targetCCOIP = None
    result = []

    for CCO in CCOs:
        for key in CCO.keys():
            if key == 'name' and CCO[key] == region:
                targetCCO = CCO
                targetCCOIPKey = role + IP_KEY
                if targetCCOIPKey in targetCCO[COMPONENTS][CCO_COMPONENT].keys():
                    targetCCOIP = targetCCO[COMPONENTS][CCO_COMPONENT][targetCCOIPKey]
                break

    if targetCCO is None or targetCCOIP is None:
        errMsg = 'CCO %s of region %s cannot be found in the JSON file, please check the name provided' % (role, region)
        print errMsg
        return {ERROR: errMsg}

    if role.startswith(CCO_LB_COMPONENT):
        componentsToTest = [CCO_COMPONENT + HA_PRIMARY, CCO_COMPONENT + HA_SECONDARY, CCO_COMPONENT + HA_TERTIARY]

        for key in componentsToTest:
            print 'Test CCO %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in CCO_PORTS:
                if ipKey in targetCCO[COMPONENTS][CCO_COMPONENT].keys():
                    result.append(testConnAndPrint(targetCCO[COMPONENTS][CCO_COMPONENT][ipKey], port, key, {REGION: targetCCO[NAME]}))
                else:
                    result.append(testConnAndPrint(None, port, key, {REGION: targetCCO[NAME]}))
    else:

        # Test CCM connection
        print 'Testing CCM ports from CCO'
        CCMs = data[CCM_ELEMENT]
        mode = CCMs[MODE]
        componentsToTest = []

        if mode == HA_MODE:
            componentsToTest = [CCM_LB_COMPONENT]
        elif mode == NONE_HA_STANDALONE_MODE:
            componentsToTest = [CCM_SA_COMPONENT]
        else:
            componentsToTest = [CCM_COMPONENT]

        for key in componentsToTest:
            print 'Test CCM %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in CCM_PORTS:
                if ipKey in CCMs.keys():
                    result.append(testConnAndPrint(CCMs[ipKey], port, key))
                else:
                    result.append(testConnAndPrint(None, port, key))

        #Test AMQP Connection
        print 'Testing AMQP ports from CCO'
        amqp = targetCCO[COMPONENTS][AMQP_COMPONENT]
        componentsToTest = []
        mode = amqp[MODE]

        if mode == HA_MODE:
            if (AMQP_LB_COMPONENT + IP_KEY) in amqp.keys():
                componentsToTest = [AMQP_LB_COMPONENT]
            else:
                componentsToTest = [AMQP_COMPONENT + HA_PRIMARY, AMQP_COMPONENT + HA_SECONDARY]
        else:
            componentsToTest = [AMQP_COMPONENT]

        for key in componentsToTest:
            print 'Test AMQP %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in AMQP_PORTS:
                if ipKey in amqp.keys():
                    result.append(testConnAndPrint(amqp[ipKey], port, key, {REGION: targetCCO[NAME]}))
                else:
                    result.append(testConnAndPrint(None, port, key, {REGION: targetCCO[NAME]}))

        #Test Docker Engine connection
        if DEDICATED_EXTERNAL_SCRIPT_EXECUTOR in targetCCO[COMPONENTS].keys():
            print 'External Script Engine ports from CCO'
            dockerExec = targetCCO[COMPONENTS][DEDICATED_EXTERNAL_SCRIPT_EXECUTOR]
            componentsToTest = [EXT_SCRIPT_COMPONENT]

            for key in componentsToTest:
                ipKey = key + IP_KEY
                for port in DOCKER_PORTS:
                    if ipKey in dockerExec.keys():
                        result.append(testConnAndPrint(dockerExec[ipKey], port, key, {REGION: targetCCO[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: targetCCO[NAME]}))


        result += testBundleStore(data)
        result += testPackageStore(data)

        #Test Docker Registry if the element is there
        repos = data[REPOS_ELEMENT]
        if DOCKER_REGISTRY_COMPONENT in repos.keys():
            print 'Test Docker Registry connectivity'
            key = DOCKER_REGISTRY_COMPONENT
            url = getDomainFromURl(repos[key])
            port = getPortFromUrl(repos[key])
            if port is None:
                print bcolors.FAIL, 'Unknown bundle type for url', url, bcolors.ENDC
            else:
                result.append(testConnAndPrint(url, port, DOCKER_REGISTRY_COMPONENT))

        #If it is HA mode, test hazelcast port and mongo ports
        cco = targetCCO[COMPONENTS][CCO_COMPONENT]
        mode = cco[MODE]
        if mode == HA_MODE:
            print 'Testing hazelcast port for CCO', role
            componentsToTest = [CCO_COMPONENT + HA_PRIMARY, CCO_COMPONENT + HA_SECONDARY, CCO_COMPONENT + HA_TERTIARY]
            componentsToTest.remove(role)

            for key in componentsToTest:
                ipKey = key + IP_KEY
                for port in CCO_HAZELCAST_PORTS:
                    if ipKey in cco.keys():
                        result.append(testConnAndPrint(cco[ipKey], port, key, {REGION: targetCCO[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: targetCCO[NAME]}))

            print 'Testing mongo port for CCO', role
            componentsToTest = [CCO_COMPONENT + HA_PRIMARY, CCO_COMPONENT + HA_SECONDARY, CCO_COMPONENT + HA_TERTIARY]
            componentsToTest.remove(role)

            for key in componentsToTest:
                ipKey = key + IP_KEY
                for port in CCO_MONGO_PORTS:
                    if ipKey in cco.keys():
                        result.append(testConnAndPrint(cco[ipKey], port, key, {REGION: targetCCO[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: targetCCO[NAME]}))


        #Test Monitor connection
        MONs = data[MONITOR_ELEMENT]
        if MONs == None:
            MONs = {}
        mode = MONs[MODE]
        if mode == HA_MODE:
            testComponents = [MON_LB_COMPONENT]
        else:
            testComponents = [MON_COMPONENT]

        print 'Test Monitor connection from CCO'
        for key in testComponents:
            ipKey = key + IP_KEY
            for port in CCO_TO_MON_PORTS:
                if ipKey in MONs.keys():
                    result.append(testConnAndPrint(MONs[ipKey], port, key))
                else:
                    result.append(testConnAndPrint(None, port, key))

    return result

def testGUAC(data, role, region):
    AMQPs = data[CLOUD_REGIONS_ELEMENT]
    targetAMQP = None
    targetGUACIP = None
    result = []

    for AMQP in AMQPs:
        for key in AMQP.keys():
            if key == 'name' and AMQP[key] == region:
                targetAMQP = AMQP
                targetGUACIPKey = role + IP_KEY
                if targetGUACIPKey in targetAMQP[COMPONENTS].keys():
                    targetGUACIP = targetAMQP[COMPONENTS][AMQP_COMPONENT][targetGUACIPKey]
                break

    if targetAMQP is None or targetGUACIP is None:
        errMsg = 'Guacamole %s of region %s cannot be found in the JSON file, please check the name provided' % (role, region)
        print errMsg
        return {ERROR: errMsg}

    # Test CCM connection
    print 'Testing CCM ports from Guacamole'
    CCMs = data[CCM_ELEMENT]
    mode = CCMs[MODE]
    componentsToTest = []

    if mode == HA_MODE:
        componentsToTest = [CCM_LB_COMPONENT]
    elif mode == NONE_HA_STANDALONE_MODE:
        componentsToTest = [CCM_SA_COMPONENT]
    else:
        componentsToTest = [CCM_COMPONENT]

    for key in componentsToTest:
        print 'Test CCM %s\'s Connection' % key
        ipKey = key + IP_KEY
        for port in CCM_PORTS:
            if ipKey in CCMs.keys():
                result.append(testConnAndPrint(CCMs[ipKey], port, key))
            else:
                result.append(testConnAndPrint(None, port, key))

    #Test AMQP Connection
    CCO = targetAMQP[COMPONENTS][CCO_COMPONENT]
    mode = CCO[MODE]
    componentsToTest = []
    if mode == HA_MODE:
        comonentsTotTest = [CCO_LB_COMPONENT]
    else:
        comonentsTotTest = [CCO_COMPONENT]

    print 'Testing CCO ports from AMQP'
    for key in comonentsTotTest:
        print 'Test CCO %s\'s Connection' % key
        ipKey = key + IP_KEY
        for port in CCO_PORTS:
            if ipKey in CCO.keys():
                result.append(testConnAndPrint(CCO[ipKey], port, key, {REGION: targetAMQP[NAME]}))
            else:
                result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))

    result += testPackageStore(data)

    return result

def testAMQP(data, role, region):
    AMQPs = data[CLOUD_REGIONS_ELEMENT]
    targetAMQP = None
    targetAMQPIP = None
    result = []

    for AMQP in AMQPs:
        for key in AMQP.keys():
            if key == 'name' and AMQP[key] == region:
                targetAMQP = AMQP
                targetAMQPIPKey = role + IP_KEY
                if targetAMQPIPKey in targetAMQP[COMPONENTS][AMQP_COMPONENT].keys():
                    targetAMQPIP = targetAMQP[COMPONENTS][AMQP_COMPONENT][targetAMQPIPKey]
                break

    if targetAMQP is None or targetAMQPIP is None:
        errMsg = 'AMQP %s of region %s cannot be found in the JSON file, please check the name provided' % (role, region)
        print errMsg
        return {ERROR: errMsg}

    if role.startswith(AMQP_LB_COMPONENT):
        componentsToTest = [AMQP_COMPONENT + HA_PRIMARY, AMQP_COMPONENT + HA_SECONDARY]

        for key in componentsToTest:
            print 'Test AMQP %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in AMQP_PORTS:
                if ipKey in targetAMQP[COMPONENTS][AMQP_COMPONENT].keys():
                    result.append(testConnAndPrint(targetAMQP[COMPONENTS][AMQP_COMPONENT][ipKey], port, key, {REGION: targetAMQP[NAME]}))
                else:
                    result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))
    else:

        # We only need to test CCM and CCO connections for GUAC server, so if we have a dedicated guac server,
        # we don't test the ports for AMQP then
        if DEDICATED_GUAC_COMPONENT not in targetAMQP[COMPONENTS].keys():
            # Test CCM connection
            print 'Testing CCM ports from AMQP'
            CCMs = data[CCM_ELEMENT]
            mode = CCMs[MODE]
            componentsToTest = []

            if mode == HA_MODE:
                componentsToTest = [CCM_LB_COMPONENT]
            elif mode == NONE_HA_STANDALONE_MODE:
                componentsToTest = [CCM_SA_COMPONENT]
            else:
                componentsToTest = [CCM_COMPONENT]

            for key in componentsToTest:
                print 'Test CCM %s\'s Connection' % key
                ipKey = key + IP_KEY
                for port in CCM_PORTS:
                    if ipKey in CCMs.keys():
                        result.append(testConnAndPrint(CCMs[ipKey], port, key))
                    else:
                        result.append(testConnAndPrint(None, port, key))

            AMQPResult = {}
            #Test AMQP Connection
            CCO = targetAMQP[COMPONENTS][CCO_COMPONENT]
            mode = CCO[MODE]
            componentsToTest = []
            if mode == HA_MODE:
                comonentsTotTest = [CCO_LB_COMPONENT]
            else:
                comonentsTotTest = [CCO_COMPONENT]

            print 'Testing CCO ports from AMQP'
            for key in comonentsTotTest:
                print 'Test CCO %s\'s Connection' % key
                ipKey = key + IP_KEY
                for port in CCO_PORTS:
                    if ipKey in CCO.keys():
                        result.append(testConnAndPrint(CCO[ipKey], port, key, {REGION: targetAMQP[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))

        result += testPackageStore(data)

        #If it is HA mode, test amqp cluster port
        mode = targetAMQP[COMPONENTS][AMQP_COMPONENT][MODE]
        if mode == HA_MODE:
            print 'Testing AMQP cluster ports for AMQP', role
            amqp = targetAMQP[COMPONENTS][AMQP_COMPONENT]
            componentsToTest = [AMQP_COMPONENT + HA_PRIMARY, AMQP_COMPONENT + HA_SECONDARY]
            componentsToTest.remove(role)

            for key in componentsToTest:
                ipKey = key + IP_KEY
                for port in AMQP_CLUSTER_PORTS:
                    if ipKey in amqp.keys():
                        result.append(testConnAndPrint(amqp[ipKey], port, key, {REGION: targetAMQP[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))

    return result

def testAgent(data, role, region):
    if CLOUD_REGIONS_ELEMENT not in data.keys():
        errMsg = 'No CloudRegions element defined!'
        print errMsg
        return {ERROR : errMsg}

    AMQPs = data[CLOUD_REGIONS_ELEMENT]
    targetAMQP = None
    result = []

    for AMQP in AMQPs:
        for key in AMQP.keys():
            if key == 'name' and AMQP[key] == region:
                targetAMQP = AMQP
                break

    if targetAMQP is None:
        errMsg = 'AMQP belongs to the region %s cannot be found in the JSON file, please check the name provided' % (region,)
        print errMsg
        return {ERROR: errMsg}

    # Test AMQP Connection
    print 'Testing AMQP ports from Agent'
    amqp = targetAMQP[COMPONENTS][AMQP_COMPONENT]
    mode = amqp[MODE]
    componentsToTest = []

    if mode == HA_MODE:
        if (AMQP_LB_COMPONENT + IP_KEY) in amqp.keys():
            componentsToTest = [AMQP_LB_COMPONENT]
        else:
            componentsToTest = [AMQP_COMPONENT + HA_PRIMARY, AMQP_COMPONENT + HA_SECONDARY]
    else:
        componentsToTest = [AMQP_COMPONENT]

    for key in componentsToTest:
        print 'Test AMQP %s\'s Connection' % key
        ipKey = key + IP_KEY
        for port in AMQP_PORTS:
            if ipKey in amqp.keys():
                result.append(testConnAndPrint(amqp[ipKey], port, key, {REGION: targetAMQP[NAME]}))
            else:
                result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))

    print 'Testing Rev Connection ports from Agent'
    if DEDICATED_GUAC_COMPONENT in targetAMQP[COMPONENTS].keys():
        guac = targetAMQP[COMPONENTS][DEDICATED_GUAC_COMPONENT]
        mode = guac[MODE]

        if mode == HA_MODE:
            componentsToTest = [GUAC_COMPONENT + HA_PRIMARY, GUAC_COMPONENT + HA_SECONDARY, GUAC_LB_COMPONENT]
        else:
            componentsToTest = [GUAC_COMPONENT]

        for key in componentsToTest:
            print 'Test RevConnect %s\'s connection' % key
            ipKey = key + IP_KEY
            for port in REV_CONN_PORTS:
                if ipKey in guac.keys():
                    result.append(testConnAndPrint(guac[ipKey], port, key, {REGION: targetAMQP[NAME]}))
                else:
                    result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))

    else:
        for key in componentsToTest:
            print 'Test RevConnect %s\'s connection' % key
            ipKey = key + IP_KEY
            for port in REV_CONN_PORTS:
                if ipKey in amqp.keys():
                    result.append(testConnAndPrint(amqp[ipKey], port, key, {REGION: targetAMQP[NAME]}))
                else:
                    result.append(testConnAndPrint(None, port, key, {REGION: targetAMQP[NAME]}))

    result += testBundleStore(data)
    result += testPackageStore(data)

    return result

def testMON(data, role):
    if MONITOR_ELEMENT not in data.keys():
        errMsg = 'No MON element defined!'
        print errMsg
        return {ERROR : errMsg}
    
    MONs = data[MONITOR_ELEMENT]
    result = []

    if role.startswith(MON_LB_COMPONENT):
        componentsToTest = [MON_COMPONENT + HA_PRIMARY, MON_COMPONENT + HA_SECONDARY]

        for key in componentsToTest:
            print 'Test Monitor %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in set(CCM_TO_MON_PORTS + CCO_TO_MON_PORTS + CLIENT_TO_MON_PORTS):
                if ipKey in MONs.keys():
                    result.append(testConnAndPrint(MONs[ipKey], port, key))
                else:
                    result.append(testConnAndPrint(None, port, key))
    else:
        targetMONIP = None
        targetMONIPKey = role + '_IP'
        if targetMONIPKey in MONs.keys():
            targetMONIP = MONs[targetMONIPKey]

        if targetMONIP is None:
            errMsg = 'Montior %s cannot be found in the JSON file, please check the name provided' % (role,)
            print errMsg
            return {ERROR: errMsg}

        #Test All CCO first
        print 'Testing CCO ports from Monitor'
        cloudRegions = data[CLOUD_REGIONS_ELEMENT]

        for cloudRegion in cloudRegions:
            CCO = cloudRegion[COMPONENTS][CCO_COMPONENT]
            print 'Test CCO', cloudRegion[NAME]
            mode = CCO[MODE]
            testComponents = []

            if mode == HA_MODE:
                testComponents = [CCO_LB_COMPONENT, CCO_COMPONENT + HA_PRIMARY, CCO_COMPONENT + HA_SECONDARY]
            else:
                testComponents = [CCO_COMPONENT]

            for key in testComponents:
                ipKey = key + IP_KEY
                for port in CCO_PORTS:
                    if ipKey not in CCO.keys():
                        result.append(testConnAndPrint(None, port, key, {REGION: cloudRegion[NAME]}))
                    else:
                        result.append(testConnAndPrint(CCO[ipKey], port, key, {REGION: cloudRegion[NAME]}))

        # Test CCM connection
        print 'Testing CCM ports from Monitor'
        CCMs = data[CCM_ELEMENT]
        mode = CCMs[MODE]
        componentsToTest = []

        if mode == HA_MODE:
            componentsToTest = [CCM_SA_COMPONENT + HA_PRIMARY, CCM_SA_COMPONENT + HA_SECONDARY, CCM_LB_COMPONENT]
        elif mode == NONE_HA_STANDALONE_MODE:
            componentsToTest = [CCM_SA_COMPONENT]
        else:
            componentsToTest = [CCM_COMPONENT]

        for key in componentsToTest:
            print 'Test CCM %s\'s Connection' % key
            ipKey = key + IP_KEY
            for port in CCM_PORTS:
                if ipKey in CCMs.keys():
                    result.append(testConnAndPrint(CCMs[ipKey], port, key))
                else:
                    result.append(testConnAndPrint(None, port, key))

    result += testPackageStore(data)

    return result

def testClient(data):
    # Test CCM connection
    print 'Testing CCM ports from Client'
    CCMs = data[CCM_ELEMENT]
    mode = CCMs[MODE]
    componentsToTest = []
    result = []

    #Test connections to CCM
    if mode == HA_MODE:
        componentsToTest = [CCM_SA_COMPONENT + HA_PRIMARY, CCM_SA_COMPONENT + HA_SECONDARY, CCM_LB_COMPONENT]
    elif mode == NONE_HA_STANDALONE_MODE:
        componentsToTest = [CCM_SA_COMPONENT]
    else:
        componentsToTest = [CCM_COMPONENT]

    for key in componentsToTest:
        print 'Test CCM %s\'s Connection' % key
        ipKey = key + IP_KEY
        for port in CCM_ACCESS_PORTS:
            if ipKey in CCMs.keys():
                result.append(testConnAndPrint(CCMs[ipKey], port, key))
            else:
                result.append(testConnAndPrint(None, port, key))

    #Test connections to GUAC
    cloudRegions = data[CLOUD_REGIONS_ELEMENT]
    for cloudRegion in cloudRegions:

        if DEDICATED_GUAC_COMPONENT in cloudRegion[COMPONENTS].keys():
            guac = cloudRegion[COMPONENTS][DEDICATED_GUAC_COMPONENT]
            mode = guac[MODE]

            if mode == HA_MODE:
                componentsToTest = [GUAC_LB_COMPONENT]
            else:
                componentsToTest = [GUAC_COMPONENT]

            for key in componentsToTest:
                print 'Test Guacamole %s\'s connection' % key
                ipKey = key + IP_KEY
                for port in GUAC_ACCESS_PORTS:
                    if ipKey in guac.keys():
                        result.append(testConnAndPrint(guac[ipKey], port, key, {REGION: cloudRegion[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: cloudRegion[NAME]}))

        else:
            amqp = cloudRegion[COMPONENTS][AMQP_COMPONENT]
            mode = amqp[MODE]
            componentsToTest = []

            if mode == HA_MODE:
                if (AMQP_LB_COMPONENT + IP_KEY) in amqp.keys():
                    componentsToTest = [AMQP_LB_COMPONENT]
                else:
                    componentsToTest = [AMQP_COMPONENT + HA_PRIMARY, AMQP_COMPONENT + HA_SECONDARY]
            else:
                componentsToTest = [AMQP_COMPONENT]

            for key in componentsToTest:
                print 'Test Guacamole %s\'s connection' % key
                ipKey = key + IP_KEY
                for port in GUAC_ACCESS_PORTS:
                    if ipKey in amqp.keys():
                        result.append(testConnAndPrint(amqp[ipKey], port, key, {REGION: cloudRegion[NAME]}))
                    else:
                        result.append(testConnAndPrint(None, port, key, {REGION: cloudRegion[NAME]}))

    #Test conntections to Monitor
    MONs = data[MONITOR_ELEMENT]
    if MONs == None:
        MONs = {}
    mode = MONs[MODE]
    if mode == HA_MODE:
        testComponents = [MON_LB_COMPONENT]
    else:
        testComponents = [MON_COMPONENT]

    print 'Test Monitor connection from CCO'
    for key in testComponents:
        ipKey = key + IP_KEY
        for port in CLIENT_TO_MON_PORTS:
            if ipKey in MONs.keys():
                result.append(testConnAndPrint(MONs[ipKey], port, key))
            else:
                result.append(testConnAndPrint(None, port, key))

    return result


parser = argparse.ArgumentParser(description='Intelligent network requirement detection tool')
parser.add_argument('--role', dest='role', type=str, help='Role of the current host')
parser.add_argument('--region', dest='region', type=str, help='Region of the CCO/AMQP')
parser.add_argument('--deploymentDetails', dest='deploymentDetails', type=str, help='Location of the json file')
parser.add_argument('--postInstallMode', dest='postInstallMode', action='store_true', help='Location of the json file')
parser.add_argument('--out', dest='out', type=str, help='Location of the log file')
args = parser.parse_args()

if args.role is None:
    print 'Role must be provided in order to continue the test'
    exit(1)

if args.deploymentDetails is None:
    print 'You must provide the path to the json file in order too continue the test'
    exit(1)

if (args.role.startswith(CCO_COMPONENT) or args.role.startswith(AGENT_COMPONENT) or args.role.startswith(AMQP_COMPONENT) or args.role.startswith(DEDICATED_GUAC_COMPONENT)) and args.region is None:
    print 'Region must be provided for role', args.role
    exit(1)

data = jsonParser(os.path.abspath(args.deploymentDetails))[ROOT_ELEMENT]
outputFile = args.out
if outputFile is None:
    outputFile = DEFAULT_OUTPUT_FILE

result = None
if args.role.startswith(CCM_COMPONENT):
    result = testCCM(data, args.role)
elif args.role.startswith(CCO_COMPONENT):
    result = testCCO(data, args.role, args.region)
elif args.role.startswith(AMQP_COMPONENT):
    result = testAMQP(data, args.role, args.region)
elif args.role.startswith(MONITOR_ELEMENT):
    result = testMON(data, args.role)
elif args.role.startswith(AGENT_COMPONENT):
    result = testAgent(data, args.role, args.region)
elif args.role.startswith(CLIENT_COMPONENT):
    result = testClient(data)
elif args.role.startswith(DEDICATED_GUAC_COMPONENT):
    result = testGUAC(data, args.role, args.region)
else:
    print 'The role %s provided is not a recongized role, please check' % args.role

if result is not None:
    f = open(outputFile, 'w')
    json.dump(result, f)
    f.close()
