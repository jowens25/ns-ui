from dbus_next.aio import MessageBus
from dbus_next import BusType, proxy_object

import asyncio





class NetworkManager:
    def __init__(self):
        self.bus = None
        self.root = '/org/freedesktop/NetworkManager'
        self.name = 'org.freedesktop.NetworkManager'
        self.generic_property_name = 'org.freedesktop.DBus.Properties'

        self.introspection = []
        self.object = None
        
    '''connect to provided dbus'''
    async def connect(self, bus: MessageBus):
        self.bus = await bus.connect()

    '''disconnect from dbus'''
    def disconnect(self):
        self.bus.disconnect()

    async def introspect(self, path):
        self.introspection = await self.bus.introspect(self.name, path)

    def get_object(self, path):
        self.object = self.bus.get_proxy_object(self.name, path, self.introspection)

    def get_interface(self, name):
        self.interface = self.object.get_interface(name)


    '''get a value'''
    async def property(self, _bus_path, _name, _property):

        #_bus_path = "/org/freedesktop/"+_bus_path
        #_name = "org.freedesktop."+_name

        await self.introspect(_bus_path)
        self.get_object(_bus_path)
        self.get_interface(self.generic_property_name)
        var = await self.interface.call_get(_name, _property)
        return var.value
    
    async def call(self, _bus_path, _name, _method, *args):

        #_bus_path = "/org/freedesktop/"+_bus_path
        #_name = "org.freedesktop."+_name

        await self.introspect(_bus_path)
        self.get_object(_bus_path)
        self.get_interface(_name)
        method = getattr(self.interface, _method)
        return await method(*args)

    async def nm_method(self, _method, *args):
        return await nm.call('/org/freedesktop/NetworkManager', 'org.freedesktop.NetworkManager',  _method, *args)

    async def nm_property(self, _property):
        return await nm.property('/org/freedesktop/NetworkManager','org.freedesktop.NetworkManager', _property)
    
    async def device_method(self, _path, _method, *args):
        return await nm.call(_path, 'org.freedesktop.NetworkManager.Device',  _method, *args)
    

    async def device_property(self,_path, _property):
        return await nm.property(_path,'org.freedesktop.NetworkManager.Device', _property)
    
    #async def device_property(self,_path, _property):
    #    return await nm.property(_path,'org.freedesktop.NetworkManager', _property)
#
    #async def device(self, _path, _method, *args):
    #    return await nm.call(_path, 'org.freedesktop.NetworkManager.Device',  _method, *args)
    
nm = NetworkManager()