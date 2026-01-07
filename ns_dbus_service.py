import asyncio

from dbus_next.aio import MessageBus
from dbus_next.constants import BusType

from snmp_interface import SnmpInterface
from pam_interface import PamInterface


async def main():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()

    snmp = SnmpInterface('com.novus.ns.snmp')
    bus.export('/com/novus/ns', snmp)

    pam = PamInterface('com.novus.ns.pam')
    bus.export('/com/novus/ns', pam)

    print("Starting ns service... com.novus.ns")
    await bus.request_name('com.novus.ns')
    await asyncio.Event().wait()

asyncio.run(main())
