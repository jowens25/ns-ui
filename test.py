import asyncio
import time
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Device import Device
from org_freedesktop_NetworkManager_IP4Config import IP4Config
from jeepney.wrappers import MessageGenerator, new_method_call, Message, Properties
from jeepney.io.asyncio import open_dbus_router, Proxy, DBusRouter, DBusConnection, open_dbus_connection
from org_freedesktop_NetworkManager_DHCP4Config import DHCP4Config

async def help_me():
    conn = await open_dbus_connection(bus="SYSTEM")
    router = DBusRouter(conn)
    proxy_object = Proxy(NetworkManager(), router)
    device_paths = await proxy_object.GetDevices()
    
    for path in device_paths[0]:
        device_prox = Proxy(Properties(Device(path)), router)
    
        #print(await prop_prox.get("ActiveConnection"))
        
        dhcp_path = (await device_prox.get("Dhcp4Config"))[0][1]
        
        dhcp_proxy = Proxy(Properties())
        
        res = await device_prox.get("Ip4Config")
        ipconfig_path = res[0][1]
        
        ipconfig_proxy = Proxy(Properties(IP4Config(ipconfig_path)), router)
        
        res2 = await ipconfig_proxy.get_all()
        
        #print(res2)
        
    await conn.close()

asyncio.run(help_me())
