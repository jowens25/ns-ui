from dbus_next import BusType
from dbus_next.aio import MessageBus

global Bus

async def setup():
    global Bus
    Bus = await MessageBus(bus_type=BusType.SYSTEM).connect()

async def cleanup():
    global Bus
    Bus.disconnect()

