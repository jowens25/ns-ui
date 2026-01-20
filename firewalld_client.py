from pprint import pprint
from dbus_next.aio import MessageBus

import asyncio

loop = asyncio.get_event_loop()
from dbus_next.constants import BusType

from firewalld_lib import *

async def GetFirewall(bus: MessageBus):
    introspection = await bus.introspect('com.novus.ns', '/com/novus/ns')
    obj = bus.get_proxy_object('com.novus.ns', '/com/novus/ns', introspection)
    return obj.get_interface('com.novus.ns.firewall')

async def test_snmp_client():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()

    snmp = await GetFirewalldConfig(bus)
    snmp = await GetFirewalld(bus)

    print(await snmp.call_get_v2_user_by_security_name('comuser_3'))

    await loop.create_future()


if __name__ == "__main__":
    loop.run_until_complete(test_snmp_client())