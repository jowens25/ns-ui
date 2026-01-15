

'''import asyncio
#sock = Socket()
async def test():
    await sock.setup()

    print(await sock.writeRead("$BAUDNV"))



#asyncio.run(test())

#sock.cleanup()
'''



from pprint import pprint
from dbus_next.aio import MessageBus

import asyncio

from dbus_next.constants import BusType

from socket_lib import *

async def test_snmp_client():

    print(await sendCommands(["$GPNTL,15,0,?"], True))


    #def rx_callback(msg):
    #    print(msg)
        
    #sock.on_rx(rx_callback)

    #while True:
    #    await asyncio.sleep(0.1)

    #await asyncio.wait()


if __name__ == "__main__":
    asyncio.run(test_snmp_client())