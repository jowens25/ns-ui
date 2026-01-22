

import asyncio
from dataclasses import asdict, field
from pprint import pprint
from typing import List, Optional
from nicegui import ui, app, binding
from commands import runCmd
from theme import init_colors
from rest_api import APIClient
from dbus_next.service import ServiceInterface, method


from dbus_next.signature import Variant
from dbus_next.errors import DBusError
from dbus_next.aio.proxy_object import ProxyInterface
from dbus_next.aio import MessageBus
from dbus_next import Message
from dbus import dbus


async def getUnitInterface(bus: MessageBus, unit:str) -> ProxyInterface:
    
    unitPath =  await getUnitPath(bus, unit)
    
    introspection = await bus.introspect('org.freedesktop.systemd1', unitPath)
    #pprint(introspection.tostring())
    obj = bus.get_proxy_object('org.freedesktop.systemd1', unitPath, introspection)
    
    return obj.get_interface('org.freedesktop.systemd1.Manager')





async def getSystemdManager(bus: MessageBus) -> ProxyInterface:
    introspection = await bus.introspect('org.freedesktop.systemd1', '/org/freedesktop/systemd1')
    obj = bus.get_proxy_object('org.freedesktop.systemd1', '/org/freedesktop/systemd1', introspection)
    return obj.get_interface('org.freedesktop.systemd1.Manager')


    



async def systemd_start(bus: MessageBus, service: str):
    
    systemd = await getSystemdManager(bus)
    
    await systemd.call_subscribe()

    print(systemd)
    
    jobPath = await systemd.call_start_unit(service, 'replace')

    
    
    def on_job_removed(id, job_path, unit, result):
        print("CB???")
        if job_path == jobPath:
            if result != 'done':
                print('done')
                #future.set_exception(Exception(f"Job failed: {result}"))
            else:
                print('else???')
                #future.set_result(None)
    
    systemd.on_job_removed(on_job_removed)
    
    systemd.off_job_removed(on_job_removed)
    

    
    ### print('systemd start: ', service)
    ### rsp = await bus.call(
    ###     Message(
    ###         destination='org.freedesktop.systemd1',
    ###         path='/org/freedesktop/systemd1',
    ###         interface='org.freedesktop.systemd1.Manager',
    ###         member='StartUnitWait',
    ###         signature='ss',
    ###         body=[service, 'replace']
    ###     )
    ### )
    ### if rsp.body:
    ###     print(rsp.body[0])
    ###     
    ### print(await isActive(bus, service))
    
async def systemd_stop(bus: MessageBus, service: str):
    print('systemd stop: ', service)
    jobPath = await bus.call(
        Message(
            destination='org.freedesktop.systemd1',
            path='/org/freedesktop/systemd1',
            interface='org.freedesktop.systemd1.Manager',
            member='StopUnitWait',
            signature='ss',
            body=[service, 'replace']
        )
    )
    
    #if rsp.body:
    #    print(rsp.body[0])
        
    print(await isActive(bus, service))
    

    
    

async def getUnitInterface(bus: MessageBus, unit:str) -> ProxyInterface:
    
    unitPath =  await getUnitPath(bus, unit)
    
    introspection = await bus.introspect('org.freedesktop.systemd1', unitPath)
    #pprint(introspection.tostring())
    obj = bus.get_proxy_object('org.freedesktop.systemd1', unitPath, introspection)
    
    return obj.get_interface('org.freedesktop.DBus.Properties')



async def getUnitPath(bus: MessageBus, service: str) -> str:
    rsp = await bus.call(
        Message(
            destination='org.freedesktop.systemd1',
            path='/org/freedesktop/systemd1',
            interface='org.freedesktop.systemd1.Manager',
            member='GetUnit',
            signature='s',
            body=[service]
        )
    )
    
    unitPath = rsp.body[0]
    
    return unitPath



async def getUnitProperties(bus: MessageBus, unitPath: str) -> dict:
        
    rsp = await bus.call(
    Message(
        destination='org.freedesktop.systemd1',
        path=unitPath,
        interface='org.freedesktop.DBus.Properties',
        member='GetAll',
        signature='s',
        body=['org.freedesktop.systemd1.Unit']
    )
)
    
    unitProps = rsp.body[0]
    return unitProps
    
async def getServiceState(bus: MessageBus, service: str) -> str:

    path = await getUnitPath(bus, service)
    
    props = await getUnitProperties(bus, path)
    
    return props.get("ActiveState", Variant('s', 'StateNotFound')).value



async def isActive(bus: MessageBus, service: str) -> bool:
    
    state = await getServiceState(bus, service)
    print('is active? ', state)
    if state == 'active':
        return True
    else:
        return False