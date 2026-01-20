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


async def GetSnmp(bus: MessageBus):
    introspection = await bus.introspect('com.novus.ns', '/com/novus/ns')
    obj = bus.get_proxy_object('com.novus.ns', '/com/novus/ns', introspection)
    return obj.get_interface('com.novus.ns.snmp')

def GetDevice(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Device.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Device')




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







# ====================================================================
# Firewall DAEMON
# ====================================================================
async def StopFirewalld():
    print("stoping... snmpd")
    await runCmd(["systemctl", "stop", "firewalld"])

async def StartFirewalld():
    print("starting... snmpd")
    await runCmd(["systemctl", "start", "firewalld"])

async def RestartFirewalld():
    print("restarting... snmpd")
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
    