import asyncio
import os
import time
from icmplib import ping


async def ping_it():

    while True:

        yield ping('192.168.0.100', count=1)

        await asyncio.sleep(60)

async def main():
    global path

    async for host in ping_it():
        print(host)
        if host.is_alive:
        
            with open(path, 'a') as f:
                f.write(f"{time.time()},{host.rtts[0]}\r\n")
                f.close()

if __name__ == "__main__":
    global path
    try:
        path = os.path.join("network_delay_data",str(time.time()).replace(".","_")+".csv")

        with open(path, 'x') as f:
            f.write(f"ts, rtt\r\n")
            f.close()

        asyncio.run(main())
    except asyncio.CancelledError:
        print("Main completed and tasks cancelled.")