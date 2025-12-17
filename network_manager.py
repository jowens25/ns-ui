from dbus_next.aio import MessageBus
from dbus_next import BusType
import asyncio



#class Device:
#
#    def __init__(self):
#        self.path = '/org/freedesktop/NetworkManager/Device'
#
    #intr = await self.bus.introspect('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')
    #obj = self.bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', intr)
    #self.interface = obj.get_interface('org.freedesktop.NetworkManager')

    #def Reapply(self):
#
    #def GetAppliedConnection(self):
#
    #def Disconnect(self):
#
    #def Delete(self):

class NetworkManager2:
    def __init__(self):
        self.bus = None
        self.introspection =  None
        self.object =  None
        self.interface = None
        self.properties_interface = None # implements
        self.properties = None


    async def connect(self):
        loop = asyncio.get_running_loop()
        self.bus = MessageBus(bus_type=BusType.SYSTEM)
        self.bus._loop = loop
        self.bus = await self.bus.connect()

    async def setup(self):
        self.introspection = await self.bus.introspect('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')
        self.object = self.bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', self.introspection)
        self.interface = self.object.get_interface('org.freedesktop.NetworkManager')
        self.properties_interface = self.object.get_interface('org.freedesktop.DBus.Properties')
        self.properties = await self.properties_interface.call_get_all('org.freedesktop.NetworkManager')



    def disconnect(self):
        self.bus.disconnect()

    
    #async def print_props(self):
    #    introspection = await self.bus.introspect('org.freedesktop.NetworkManager.Device', '/org/freedesktop/NetworkManager')
#
    #    device_object = self.bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager/Device', introspection)
#
    #    device_interface = self.object.get_interface('org.freedesktop.NetworkManager.Device')
    #    print(await device_interface.call_get_all('org.freedesktop.NetworkManager.Devices'))
           
    
    #async def GetAllDevices(self, ):            
    #async def GetDeviceByIpIface(self, ):                             
    #async def ActivateConnection(self, ):                                              
    #async def AddAndActivateConnection(self, ):                                             
    #async def DeactivateConnection(self, ):     
    #async def Sleep(self, ):                    
    #async def Enable(self, ):                   
    #async def GetPermissions(self, ):               
    #async def SetLogging(self, ):                                     
    #async def GetLogging(self, ):                                      
    #async def CheckConnectivity(self, ):        
    #async def state(self, ):                    


class NetworkManager:

    def __init__(self):
        self.bus = None
        self.networkmanager = None
        self.properties = None


    async def connect(self):
        loop = asyncio.get_running_loop()
        self.bus = MessageBus(bus_type=BusType.SYSTEM)
        self.bus._loop = loop
        self.bus = await self.bus.connect()


    def disconnect(self):
        self.bus.disconnect()


    '''exposes the methods'''
    async def getNetworkMangerMethods(self):
        intr = await self.bus.introspect('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')
        obj = self.bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', intr)
        self.interface = obj.get_interface('org.freedesktop.NetworkManager')
        # await interface.call_get('org.freedesktop.NetworkManager')
        #return ret

    async def getNetworkManagerProperties(self):
        intr =  await self.bus.introspect('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')
        obj = self.bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', intr)
        self.props = obj.get_interface('org.freedesktop.DBus.Properties')


nm = NetworkManager2()

