import socket
from dataclasses import dataclass, asdict
import asyncio
from nicegui import Event, app

from dbus_next.service import ServiceInterface, method, signal
from dbus_next.aio import MessageBus



async def socket_stream(self):
    try: 
        reader, writer = await asyncio.open_unix_connection("/tmp/serial.sock")
        print("SOCKET OPENED")
        while True:
            line = (await reader.readline()).decode('utf-8', errors='ignore')
            if line:
                yield line
            else:
                break
    except FileNotFoundError:
        print("SOCKET NOT AVAILABLE")
        #self.socket_received.emit("Socket Not Available")
        raise 
    except asyncio.CancelledError:
        print("SOCKET LISTENER CANCELLED")
        if writer:
            writer.close()
            await writer.wait_closed()
        raise
    finally:
        print("SOCKET LISTENER CLOSED")
        if writer:
            writer.close()
            await writer.wait_closed()
        
 


async def sendCommands(commands: list[str], get_responses :bool = False) -> list[str]:
    rx = asyncio.Event()
    reader, writer = await asyncio.open_unix_connection("/tmp/serial.sock")
    responses = []
    for command in commands:
        command = command+"\r\n"
        writer.write(command.encode())
        await writer.drain()

        if get_responses:
            try:
                #await asyncio.wait_for(rx, 2.0)

                while True:
                    line = (await reader.readline()).decode('utf-8', errors='ignore')
                    if line:
                        if any(line.startswith(marker) for marker in ["$ER", "$RR", "$WR", "$GPNTL", "$BAUD"]):
                            responses.append(line)
                            break
                            #rx.set()

                    #await rx.wait()

                
            except TimeoutError:
                responses.append("TimeoutError: no response?")

    writer.close()
    await writer.wait_closed()  

    return responses

        



#class SocketInterface(ServiceInterface):
#    def __init__(self, name):
#        super().__init__(name)
#
#        self.socket = Socket()
#
#        asyncio.create_task(self._setup_and_listen())
#
#    async def _setup_and_listen(self):
#
#        try:
#
#            await self.socket.setup()
#
#            async for line in self.socket.listen():
#                self.Rx(line)
#
#        except Exception as e:
#            print(f"Socket error: {e}")
#        finally:
#            await self.socket.cleanup()
#    
#
#    @method()
#    async def WriteReadCommand(self, cmd :'s') -> 's':
#        return await self.socket.writeRead(cmd)
#    
#
#
#    @signal()
#    def Rx(self, msg :'s') -> 's':
#        return msg
#
#    #@signal()
#
    
#async def GetSocket(bus: MessageBus):
#    #introspection = await bus.introspect('com.novus.ns', '/com/novus/ns')
#    with open("socket.xml", "r") as f:
#        introspection = f.read()
#    obj = bus.get_proxy_object('com.novus.ns', '/com/novus/ns', introspection)
#    return obj.get_interface('com.novus.ns.socket')



def record_data(data):
    latest = data.decode('utf-8', errors='ignore')
    with open("data.txt", "a") as f:
        f.writelines(latest)
    
    with open("data.txt", "r+") as f:
        lines = f.readlines()
        n = len(lines)
        if n >= 10000:
            lines = lines[n-10000:]
            f.seek(0)       # go to start of file
            f.truncate() 
            f.writelines(lines)







def ReadWriteSocket(command: str) -> str:
    command = command + "\r\n"
    
    try:
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect("/tmp/serial.sock")
        sock.settimeout(4.0)  # 4 second timeout
        
        try:
            sock.sendall(command.encode('utf-8'))
            sock_file = sock.makefile('r')
            
            while True:
                line = sock_file.readline()
                    
                if any(marker in line for marker in ["$ER", "$RR", "$WR", "$GPNTL"]):
                    return line, None
            
        finally:
            sock.close()
            
    except socket.timeout:
        return "timeout"
    except ConnectionRefusedError as e:
        print("socket error?")
        return "port open error"
    except Exception as e:
        print(e)
        return "port write error"





def ReadNtlProperty(module: int, property :int) -> list[str]:
    return ReadWriteSocket(f"$GPNTL,{module},{property},?")

def WriteNtlProperty(module: int, property :int, value :str):
    return ReadWriteSocket(f"$GPNTL,{module},{property},{value}")

def ParseNtlResponse(response :str)->str:
    fields = response.split(",")
    if len(fields) == 4:
        module = fields[1]
        property = fields[2]
        value = fields[3]
        return value
              


def LoadConfig(file_name: str):

    print("LOADING CONFIG...")
    
    try:
        with open(file_name, 'r') as f:
            data = f.read()
    except Exception as err:
        print(f"file err: {err}")
        return
    
    for line in data.split('\n'):
        # Skip comments
        if "--" in line:
            continue
        
        # Process $WC commands
        if "$WC" in line:
            line = line.strip()  # Remove whitespace and newlines
            
            rsp, err = ReadWriteSocket(line)
            
            if rsp.startswith("$ER"):
                print("config load err")
                return
            
            if err is not None:
                print("config error")
                return
            
            print(rsp)


