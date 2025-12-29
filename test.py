import asyncio
from dataclasses import dataclass, fields
import time
from typing import Any, Optional, Type, TypeVar
from dbus import dbus
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Device import Device
from org_freedesktop_NetworkManager_IP4Config import IP4Config, IP4ConfigProperties
from jeepney.wrappers import MessageGenerator, new_method_call, Message, Properties
from jeepney.io.asyncio import open_dbus_router, Proxy, DBusRouter, DBusConnection, open_dbus_connection
from org_freedesktop_NetworkManager_DHCP4Config import DHCP4Config
from typing import Self # Recommended for type hinting in Python 3.11+




async def GetProperties(proxy):
    data = (await proxy.get_all())[0]
    for f in fields(proxy):
        if f.name in data:
            prop_data = data[f.name]
            if isinstance(prop_data, tuple) and len(prop_data) == 2:
               setattr(proxy, f.name, prop_data[1])
            else:
                setattr(proxy, f.name, prop_data)



async def getAllProperties(cls :dataclass, router, path: str = ''):
    prox = Proxy(Properties(cls(path)), router)
    all_properties = (await prox.get_all())[0]
    if all_properties:
        return cls.from_dict(all_properties)




def from_dict(obj, instance, data: dict[str, tuple[str, Any]]) -> Self:
    """Convert from dict of {'Prop': ('s', value)} or similar into structured props."""
    for f in fields(obj):
        if f.name in data:
            prop_data = data[f.name]
            if isinstance(prop_data, tuple) and len(prop_data) == 2:
                #filtered[f.name] = prop_data[1]
                setattr(instance, f.name, prop_data[1])
            else:
                print("from dict ERROR")
                #filtered[f.name] = prop_data
                setattr(instance, f.name, prop_data)
    #return cls(**filtered)

async def help_me():
    conn = await open_dbus_connection(bus="SYSTEM")
    
    router = DBusRouter(conn)
    
    
    
    #nm = Proxy(NetworkManager(), router)
    #device_paths = await nm.GetDevices()
    #
    #for path in device_paths[0]:
#
#
#
    #    deviceProxy = Proxy(Device(path), router) # holds methods
    #    properties = await deviceProxy.get_all() # gets all props





        #print(await deviceProxy.GetAppliedConnection(flags=0))
        #devicePropsProxy = Proxy(Properties(Device(path)), router) # holds properties

        #print(await devicePropsProxy.get_all()) # gets all props

        #await deviceProxy.SomeMethod() # calls some method

        


        #print(await dev.get("Interface"))
#
        #deviceProperties = (await dev.get_all())[0]
#
        #devProps = DeviceProperties.from_dict(deviceProperties)
#
        #print(devProps.ActiveConnection)

#
#        if device.Interface == 'wlp1s0':
#
#            print(device.AvailableConnections)
#
#            print(device.Ip4Config)
#
#
#            config_prox = Proxy(Properties(IP4Config(device.Ip4Config)), router)
#
#            all_config_data = (await config_prox.get_all())[0]
#
#            cfg = IP4ConfigProperties.from_dict(all_config_data)
#
#            print(cfg.AddressData)
#
        
        #print(res2)
        
    await conn.close()

asyncio.run(help_me())
