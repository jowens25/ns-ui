import asyncio
from dataclasses import asdict, field
from pprint import pprint
from typing import List, Optional
from nicegui import ui, app, binding
from commands import runCmd
from theme import init_colors
from rest_api import APIClient


from dbus_next.signature import Variant
from dbus_next.errors import DBusError
from dbus_next.aio.proxy_object import ProxyInterface
from dbus_next.aio import MessageBus
from dbus import dbus


#async def GetSnmp(bus: MessageBus):
#    introspection = await bus.introspect('com.novus.ns', '/com/novus/ns')
#    obj = bus.get_proxy_object('com.novus.ns', '/com/novus/ns', introspection)
#    return obj.get_interface('com.novus.ns.snmp')
#
#def GetDevice(bus: MessageBus, path : str):
#    file_name = 'org.freedesktop.NetworkManager.Device.xml'
#    with open("introspection/"+file_name, "r") as f:
#        introspection = f.read()
#    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
#    return obj.get_interface('org.freedesktop.NetworkManager.Device')

@binding.bindable_dataclass
class Service:
    Version:           Optional[str]  = ''
    Name:              Optional[str] = ''
    Description:       Optional[str] = ''
    Ports:             Optional[list[str]]  = field(default_factory=list)
    ModuleNames:       Optional[list[str]] = field(default_factory=list)
    Destinations:      Optional[dict] = field(default_factory=dict)
    Protocols:         Optional[list[str]] = field(default_factory=list)
    SourcePorts:       Optional[list[str]] = field(default_factory=list)
    Includes:          Optional[list[str]] = field(default_factory=list)
    Helpers:           Optional[list[str]] = field(default_factory=list)

@binding.bindable_dataclass
class Zone:
    Name:              Optional[str] = ''
    Services:          Optional[list[Service]] = field(default_factory=list)

@binding.bindable_dataclass
class Firewall:
    Enable:            Optional[bool] = False
    Status:            Optional[str] = ''
    ActiveZones:       Optional[dict[dict]] = field(default_factory=dict)
    AllowedAddresses:  Optional[list[str]] = field(default_factory=list)
    Services:          Optional[dict[dict]] = field(default_factory=dict)
    Zones:             Optional[dict[Zone]] = field(default_factory=dict)


async def GetFirewalld(bus: MessageBus):
    file_name = 'org.fedoraproject.FirewallD1.config.xml'
    introspection = await bus.introspect('org.fedoraproject.FirewallD1', '/org/fedoraproject/FirewallD1')
    #pprint(introspection.tostring())
    obj = bus.get_proxy_object('org.fedoraproject.FirewallD1', '/org/fedoraproject/FirewallD1', introspection)
    return obj.get_interface('org.fedoraproject.FirewallD1')

async def GetFirewalldConfig(bus: MessageBus):
    file_name = 'org.fedoraproject.FirewallD1.config.xml'
    introspection = await bus.introspect('org.fedoraproject.FirewallD1', '/org/fedoraproject/FirewallD1/config')
    #pprint(introspection.tostring())
    obj = bus.get_proxy_object('org.fedoraproject.FirewallD1', '/org/fedoraproject/FirewallD1/config', introspection)
    return obj.get_interface('org.fedoraproject.FirewallD1.config')


async def GetFirewalldZone(bus: MessageBus):
    file_name = 'org.fedoraproject.FirewallD1.zone.xml'
    introspection = await bus.introspect('org.fedoraproject.FirewallD1', '/org/fedoraproject/FirewallD1')
    #pprint(introspection.tostring())
    obj = bus.get_proxy_object('org.fedoraproject.FirewallD1', '/org/fedoraproject/FirewallD1', introspection)
    return obj.get_interface('org.fedoraproject.FirewallD1.zone')




def formatListToString(elements: list[str]) -> str:
    if len(elements) == 0:
        return None
    return ', '.join(elements) if elements else ''

def getZoneInfo(name :str, zone :dict) -> dict:

    interfaces = formatListToString(zone.get('interfaces', []))
    sources = formatListToString(zone.get('sources', []))

    return {'name':name, 'interfaces':interfaces, 'sources':sources}
        



# ====================================================================
# Firewall DAEMON
# ====================================================================
async def StopFirewalld():
    print("stoping... firewalld")
    await runCmd(["systemctl", "stop", "firewalld"])

async def StartFirewalld():
    print("starting... firewalld")
    await runCmd(["systemctl", "start", "firewalld"])

async def RestartFirewalld():
    print("restarting... firewalld")
    await runCmd(["systemctl", "restart", "firewalld"])
    
    
async def ResetFirewalld() -> str:
    print("ERROR firewalld not reset")
    return "firewalld not reset"


async def IsActiveFirewalld() -> bool:
    status = await runCmd(["sudo", "systemctl", "is-active", "firewalld"])
    if status.strip("\n") == "active":
        return True
    else:
        return False
    