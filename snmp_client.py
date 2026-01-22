from pprint import pprint
from dbus_next.aio import MessageBus
from dbus_next import Message
import asyncio

loop = asyncio.get_event_loop()
from dbus_next.constants import BusType


async def GetSnmp(bus: MessageBus):
    introspection = await bus.introspect('com.novus.ns', '/com/novus/ns')
    obj = bus.get_proxy_object('com.novus.ns', '/com/novus/ns', introspection)
    return obj.get_interface('com.novus.ns.snmp')


async def snmp_call(bus: MessageBus, member: str, signature:str, body):

    rsp = await bus.call(
        Message(
            destination='com.novus.ns',
            path='/com/novus/ns',
            interface='com.novus.ns.snmp',
            member=member,
            signature=signature,
            body=[body]
        )
    )

    return rsp.body[0]

async def test_snmp_client():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()

    snmp = await GetSnmp(bus)

    print(await snmp.call_get_v2_user_by_security_name('comuser_3'))

    await loop.create_future()


if __name__ == "__main__":
    loop.run_until_complete(test_snmp_client())