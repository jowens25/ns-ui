from dbus_next.aio import MessageBus
from dbus_next import BusType, proxy_object

import asyncio




from dasbus.connection import SystemMessageBus

def test_network():
    bus = SystemMessageBus()

    proxy = bus.get_proxy(
        "org.freedesktop.NetworkManager",
        "/org/freedesktop/NetworkManager"
    )



    devices = proxy.GetDevices()
    
    print(devices)


#/org/freedesktop/NetworkManager
#/org/freedesktop/NetworkManager/AgentManage
#/org/freedesktop/NetworkManager/DnsManage
#/org/freedesktop/NetworkManager/Setting
#/org/freedesktop/NetworkManager/Settings/*
#/org/freedesktop/NetworkManager/Devices/*
#/org/freedesktop/NetworkManager/ActiveConnection/*
#/org/freedesktop/NetworkManager/IP4Config/*
#/org/freedesktop/NetworkManager/IP6Config/*
#/org/freedesktop/NetworkManager/DHCP4Config/*
#/org/freedesktop/NetworkManager/DHCP4Config/*
#/org/freedesktop/NetworkManager/AccessPoint/*
#/org.freedesktop.NetworkManager.WifiP2PPeer/*
#/org/freedesktop/NetworkManager/Checkpoint/*








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


    '''get a prop'''
    async def get_prop(self, _bus_path, _name, _property):

        await self.introspect(_bus_path)
        self.get_object(_bus_path)
        self.get_interface(self.generic_property_name)
        var = await self.interface.call_get(_name, _property)
        return var.value
    
    async def call(self, _bus_path, _name, _method, *args):

        await self.introspect(_bus_path)
        self.get_object(_bus_path)
        self.get_interface(_name)
        method = getattr(self.interface, _method)
        return await method(*args)

    async def method(self, _method, *args):
        return await nm.call('/org/freedesktop/NetworkManager', 'org.freedesktop.NetworkManager',  _method, *args)

    async def property(self, _property):
        return await nm.get_prop('/org/freedesktop/NetworkManager','org.freedesktop.NetworkManager', _property)


    class device:
        async def method( _path, _method, *args):
            return await nm.call(_path, 'org.freedesktop.NetworkManager.Device',  _method, *args)
        async def property(_path, _property):
            return await nm.get_prop(_path,'org.freedesktop.NetworkManager.Device', _property)

    class ipv4config:
        async def method( _path, _method, *args):
            return await nm.call(_path, 'org.freedesktop.NetworkManager.IP4Config',  _method, *args)
        async def property(_path, _property):
            return await nm.get_prop(_path,'org.freedesktop.NetworkManager.IP4Config', _property)

    class ipv6config:
        async def method( _path, _method, *args):
            return await nm.call(_path, 'org.freedesktop.NetworkManager.IP6Config',  _method, *args)
        async def property(_path, _property):
            return await nm.get_prop(_path,'org.freedesktop.NetworkManager.IP6Config', _property)



    
    
nm = NetworkManager()