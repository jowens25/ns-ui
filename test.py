import asyncio
from dataclasses import dataclass, fields
import time
from typing import Any, Optional, Type, TypeVar
from dbus import dbus
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Device import Device, DeviceProperties
from org_freedesktop_NetworkManager_IP4Config import IP4Config, IP4ConfigProperties
from jeepney.wrappers import MessageGenerator, new_method_call, Message, Properties
from jeepney.io.asyncio import open_dbus_router, Proxy, DBusRouter, DBusConnection, open_dbus_connection
from org_freedesktop_NetworkManager_DHCP4Config import DHCP4Config
from typing import Self # Recommended for type hinting in Python 3.11+




async def getAllProperties(cls :dataclass, router, path: str = ''):
    prox = Proxy(Properties(cls(path)), router)
    all_properties = (await prox.get_all())[0]
    if all_properties:
        return cls.from_dict(all_properties)



async def help_me():
    conn = await open_dbus_connection(bus="SYSTEM")
    router = DBusRouter(conn)
    proxy_object = Proxy(NetworkManager(), router)
    device_paths = await proxy_object.GetDevices()
    
    for path in device_paths[0]:

        device_prox = Proxy(Properties(Device(path)), router)

        all_device_props = (await device_prox.get_all())[0]

        dev = DeviceProperties.from_dict(all_device_props)


        if dev.Interface == 'wlp1s0':

            print(dev.AvailableConnections)

            print(dev.Ip4Config)


            config_prox = Proxy(Properties(IP4Config(dev.Ip4Config)), router)

            all_config_data = (await config_prox.get_all())[0]

            cfg = IP4ConfigProperties.from_dict(all_config_data)

            print(cfg.AddressData)

        
        #print(res2)
        
    await conn.close()

asyncio.run(help_me())
