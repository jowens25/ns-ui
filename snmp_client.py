from pprint import pprint
from dbus_next.aio import MessageBus

import asyncio

loop = asyncio.get_event_loop()
from dbus_next.constants import BusType

async def main():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    # the introspection xml would normally be included in your project, but
    # this is convenient for development
    introspection = await bus.introspect('com.novus.ns', '/com/novus/ns')

    obj = bus.get_proxy_object('com.novus.ns', '/com/novus/ns', introspection)
    snmp = obj.get_interface('com.novus.ns.snmp')
    #properties = obj.get_interface('org.freedesktop.DBus.Properties')

    ## call methods on the interface (this causes the media player to play)
    resp = await snmp.call_is_active()
    print(resp)


    await loop.create_future()

loop.run_until_complete(main())