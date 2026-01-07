import pam
p = pam.pam()



from dbus_next.service import ServiceInterface, method, dbus_property, signal, Variant
from dbus_next.aio import MessageBus
from dbus_next.constants import BusType

import asyncio



class ExampleInterface(ServiceInterface):
    def __init__(self, name):
        super().__init__(name)
        self.i = 0
    @method()
    def Authenticate(self, username: 's', password: 's') -> 'b':
        if p.authenticate(username, password, print_failure_messages=True):
            print("authentication successful")
            return True
        else:
            print("authentication failed")

            return False



async def main():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    interface = ExampleInterface('test.interface')
    bus.export('/test/path', interface)
    print("Start PAM Service")
    await bus.request_name('test.name')
    await asyncio.Event().wait()

asyncio.run(main())