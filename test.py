import asyncio
from dataclasses import dataclass, fields
import time
from typing import Any, Optional, Type, TypeVar
from dbus import dbus
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Device import Device
from org_freedesktop_NetworkManager_IP4Config import IP4Config
from jeepney.wrappers import MessageGenerator, new_method_call, Message, Properties
from jeepney.io.asyncio import open_dbus_router, Proxy, DBusRouter, DBusConnection, open_dbus_connection
from org_freedesktop_NetworkManager_DHCP4Config import DHCP4Config
from typing import Self # Recommended for type hinting in Python 3.11+



@dataclass
class DeviceProp:
    Udi                   : Optional [str] = None        #    s
    Path                  : Optional [str] = None        #    s
    Interface             : Optional [str] = None        #    s
    IpInterface           : Optional [str] = None        #    s
    Driver                : Optional [str] = None        #    s
    DriverVersion         : Optional [str] = None        #    s
    FirmwareVersion       : Optional [str] = None        #    s
    Capabilities          : Optional [int] = None        #    u
    Ip4Address            : Optional [int] = None        #    u
    State                 : Optional [int] = None        #    u
    StateReason           : Optional [int] = None        #    (uu)
    ActiveConnection      : Optional [str] = None        #    o
    Ip4Config             : Optional [str] = None        #    o
    Dhcp4Config           : Optional [str] = None        #    o
    Ip6Config             : Optional [str] = None        #    o
    Dhcp6Config           : Optional [str] = None        #    o
    Managed               : Optional [bool] = None       #    b
    Autoconnect           : Optional [bool] = None       #    b
    FirmwareMissing       : Optional [bool] = None       #    b
    NmPluginMissing       : Optional [bool] = None       #    b
    DeviceType            : Optional [int] = None        #    u
    AvailableConnections  : Optional [list[str]] = None  #    ao
    PhysicalPortId        : Optional [str] = None        #    s
    Mtu                   : Optional [int] = None        #    u
    Metered               : Optional [int] = None        #    u
    LldpNeighbors         : Optional [list[str]] = None  #    aa{sv}
    Real                  : Optional [bool] = None       #    b
    Ip4Connectivity       : Optional [int] = None        #    u
    Ip6Connectivity       : Optional [int] = None        #    u
    InterfaceFlags        : Optional [int] = None        #    u
    HwAddress             : Optional [str] = None        #    s
    Ports                 : Optional [list[str]] = None  #    ao


    @classmethod
    def from_dict(cls, data: dict[str, tuple[str, Any]]) -> Self:
        """Convert from dict of {'Prop': ('s', value)} or similar into structured props."""
        filtered = {}
        for f in fields(cls):
            if f.name in data:
                prop_data = data[f.name]
                if isinstance(prop_data, tuple) and len(prop_data) == 2:
                    filtered[f.name] = prop_data[1]
                else:
                    print("from dict ERROR")
                    filtered[f.name] = prop_data
        return cls(**filtered)
    



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


        #devProps = await getAllProperties(Device, router, path)

        #print(devProps)
        device_prox = Proxy(Properties(Device(path)), router)

        all_device_props = (await device_prox.get_all())[0]

        dev = DeviceProp.from_dict(all_device_props)


        print(dev.Interface)

        print(dev.AvailableConnections)

        print(dev.Ip4Config)




        #print(all_device_props)

    
     
        
        res = await device_prox.get("Ip4Config")
        ipconfig_path = res[0][1]
        
        ipconfig_proxy = Proxy(Properties(IP4Config(ipconfig_path)), router)
        
        res2 = await ipconfig_proxy.get_all()
        
        #print(res2)
        
    await conn.close()

asyncio.run(help_me())
