#################################################################################################################
# A10 Networks
#
# Script of examples for using a10sdk
#
#
#C:\Python27\Lib\site-packages
#C:\Users\misty.jones.WAR-EAGLE\AppData\Local\Programs\Python\Python36-32\Scripts\
#python -m pip install a10sdk
#
#################################################################################################################
#Initializations
#
#__file__=a10sdk_base_trj.py

import json

from a10sdk.common.device_proxy import DeviceProxy
dp = DeviceProxy(host="192.168.0.153", port="80", username="admin", password="a10", use_https=False)

#################################################################################################################
#Create() calls

#Health Monitor (not finished)
#from a10sdk.core.health_monitor import HealthMonitor
#hm = HealthMonitor(name="HM_TEST",method={http,url_type=GET},DeviceProxy=dp)

'''
This section is all working. Will generate a new working VIP based on inputs

#Create a Server
from a10sdk.core.slb.slb_server import Server
rs = Server(name="s_NEW_PYTHON_SRVR",host="10.1.30.8",DeviceProxy=dp)
rs.create()

#Add a real port to new server
from a10sdk.core.slb.slb_server_port import Port
rp = Port(port_number="80",protocol="tcp",DeviceProxy=dp)
rp.create(name="s_NEW_PYTHON_SRVR")

#Create a new service group
from a10sdk.core.slb.slb_service_group import ServiceGroup
sg = ServiceGroup(name="sg_NEW_PYTHON_SERVICE_GROUP",protocol="tcp",DeviceProxy=dp)
sg.create()

#Add new member to new service group
from a10sdk.core.slb.slb_service_group_member import Member
sgmem = Member(name="s_NEW_PYTHON_SRVR",port="80",DeviceProxy=dp)
sgmem.create(name="sg_NEW_PYTHON_SERVICE_GROUP")

#Create new VIP with new sg
from a10sdk.core.slb.slb_virtual_server import VirtualServer
vs = VirtualServer(name="NEW_PYTHON_VIP_01", ip_address="1.1.1.1", DeviceProxy=dp)
vs.create()

#Add a vport to the new VIP
from a10sdk.core.slb.slb_virtual_server_port import Port
vs_port = Port(protocol="http",port_number="80",service_group="sg_NEW_PYTHON_SERVICE_GROUP",DeviceProxy=dp)
vs_port.create(name="NEW_PYTHON_VIP_01")
'''


#################################################################################################################
#DELETE() calls
'''
This section is all working. It will take the name of the object ({name}) and delete it.

#Delete VIP == VirutalServer.name
from a10sdk.core.slb.slb_virtual_server import VirtualServer
vs = VirtualServer(DeviceProxy=dp)
vs.delete(name="NEW_VIP_01")

#Delete service group
from a10sdk.core.slb.slb_service_group import ServiceGroup
sg = ServiceGroup(DeviceProxy=dp)
sg.delete(name="sg_NEW_PYTHON_SERVICE_GROUP")

#Delete a Server
from a10sdk.core.slb.slb_server import Server
rs = Server(DeviceProxy=dp)
rs.delete(name="s_NEW_PYTHON_SRVR")
'''

#################################################################################################################
#GET() calls

'''
This section works. It will print out the configuration of the heirarchy level.
'''

#Management
from a10sdk.core.interface.interface_management import Management
mgmt = Management(DeviceProxy=dp).get()
print json.dumps(mgmt.__json__(mgmt),indent=4,sort_keys=True)

#SLB Server
from a10sdk.core.slb.slb_server import Server
realserver = Server(DeviceProxy=dp).get(name="s_NEW_PYTHON_SRVR")
print "The port_list is: ",realserver.port_list[0].port_number
print json.dumps(realserver.__json__(realserver),indent=4,sort_keys=True)

#SLB Service-Group
from a10sdk.core.slb.slb_service_group import ServiceGroup
sg =  ServiceGroup(DeviceProxy=dp).get(name="sg_NEW_PYTHON_SERVICE_GROUP")
print json.dumps(sg.__json__(sg),indent=4,sort_keys=True)


#SLB virtual-server
from a10sdk.core.slb.slb_virtual_server import VirtualServer
vpo = VirtualServer(DeviceProxy=dp).get(name="NEW_PYTHON_VIP_01")
print json.dumps(vpo.__json__(vpo),indent=4,sort_keys=True)

#################################################################################################################
#Operational Stats

'''
Not complete. This section will get the operational statistics for an object.


#/slb/switch/stats
from a10sdk.core.slb.slb_switch_stats import Switch
sw = Switch(a10_url="/axapi/v3/slb/switch",DeviceProxy=dp)
#print json.dumps(sw.get_stats(a10_url="/axapi/v3/slb/switch"),indent=4,sort_keys=True)

#/health/monitor
from a10sdk.core.health.health_monitor import Monitor
hm = Monitor(a10_url="/axapi/v3/health/",DeviceProxy=dp)
print "hm.b_key = ",hm.b_key
print "hm.a10_url = ",hm.a10_url
print "hm.depth_finder = ",hm.depth_finder.im_func.func_defaults
print "hm.name = ",hm.name
print "hm._required = ",hm.required
print "hm.DeviceProxy = ",hm.DeviceProxy
print "hm.ERROR_MSG = ",hm.ERROR_MSG
print "hm.__json__(hm) = ", hm.__json__.im_class.mro.__get__.__str__
print 

#/slb/server
#from a10sdk.core.slb.slb_server_oper import Server
#vpo = Server(a10_url="/axapi/v3/slb/server",DeviceProxy=dp)
#print json.dumps(vpo.get_stats(a10_url="/axapi/v3/slb/server/"),indent=4,sort_keys=True)

#/slb/service-group
from a10sdk.core.slb.slb_service_group_member_oper import Member
sg = Member(a10_url="/axapi/v3/slb/service-group/", DeviceProxy=dp)
#print json.dumps(sg.get_stats(a10_url="/axapi/v3/slb/service-group/"),indent=4,sort_keys=True)

#/slb/virtual-server
from a10sdk.core.slb.slb_virtual_server_oper import Oper
vpo = Oper(a10_url="/axapi/v3/slb/virtual-server/",DeviceProxy=dp)
#print json.dumps(vpo.get_stats(a10_url="/axapi/v3/slb/virtual-server"),indent=4,sort_keys=True)
'''

#################################################################################################################

