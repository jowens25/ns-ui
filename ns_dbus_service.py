import asyncio

from dbus_next.aio import MessageBus
from dbus_next.constants import BusType

from snmp_interface import SnmpInterface
from pam_interface import PamInterface



snmpInterface = None
pamInterface = None
socketInterface = None

async def main():
    global snmpInterface, pamInterface, socketInterface

    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    
    snmpInterface = SnmpInterface('com.novus.ns.snmp')
    bus.export('/com/novus/ns', snmpInterface)

    pamInterface = PamInterface('com.novus.ns.pam')
    bus.export('/com/novus/ns', pamInterface)

    #socketInterface = SocketInterface('com.novus.ns.socket')
    #bus.export('/com/novus/ns', socketInterface)

    print("Starting ns service... com.novus.ns")
    
    await bus.request_name('com.novus.ns')
    await asyncio.Event().wait()



asyncio.run(main())
