from pprint import pprint
from dbus_next.aio import MessageBus
from dbus_next import message, Message

import asyncio

loop = asyncio.get_event_loop()
from dbus_next.constants import BusType

from systemd_lib import *

async def test_snmp_client():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    
    service  = 'snmpd.service'
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
    
    await systemd.on_job_removed(on_job_removed)
    
    systemd.off_job_removed(on_job_removed)

    await loop.create_future()


if __name__ == "__main__":
    loop.run_until_complete(test_snmp_client())