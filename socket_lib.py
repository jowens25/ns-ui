import os
import socket
import time
from dataclasses import dataclass, asdict
import asyncio
from nicegui import Event, app




class Socket:
    def __init__(self):
        self.reader = None
        self.writer = None
        self.socket_received = Event()


    async def setup(self):
        try: 
            self.reader, self.writer = await asyncio.open_unix_connection("/tmp/serial.sock")
            print("SOCKET OPENED")

        except FileNotFoundError:
            print("SOCKET NOT AVAILABLE")
            self.socket_received.emit("Socket Not Available")
            raise 

        except asyncio.CancelledError:
            print("SOCKET LISTENER CANCELLED")
            raise

        finally:
            await self.cleanup()
        
    async def cleanup(self):
        print("SOCKET LISTENER CLOSED")
        if self.writer:
            self.writer.close()
            await self.writer.wait_closed()

        
    async def listen(self):
        while True:
            data = await self.reader.read(128)
            if data:
                self.socket_received.emit(data.decode('utf-8', errors='ignore'))
            else:
                break
        

    async def write(self, command: str):
        command = command+"\r\n"
        self.writer.write(command.encode())
        await self.writer.drain()


    async def read_until_response(self) -> str:
        response_received = asyncio.Event()

        while True:
            data = await self.reader.read(128)
            if data:
                lines = data.decode('utf-8', errors='ignore').splitlines()
                for line in lines:
                    if any(marker in line for marker in ["$ER", "$RR", "$WR", "$GPNTL"]):
                        return line
            try:
                await asyncio.wait_for(response_received.wait(), timeout=2.0)
            except asyncio.TimeoutError:
                return "timeout waiting for response"

    async def writeRead(self, command: str) -> str:
        await self.write(command)





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