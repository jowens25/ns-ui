import socket
import time
from dataclasses import dataclass, asdict
import asyncio
from asyncio import StreamWriter, StreamReader
from typing import Optional, Required


MODULES  = {
 1:"ConfSlave", 
 2:"ClkClock", 
 3:"ClkSignalGenerator", 
 4:"ClkSignalTimestamper", 
 5:"IrigSlave", 
 6:"IrigMaster", 
 7:"PpsSlave", 
 8:"PpsMaster", 
 9:"PtpOrdinaryClock", 
10:"PtpTransparentClock", 
11:"PtpHybridClock", 
12:"RedHsrPrp", 
13:"RtcSlave", 
14:"RtcMaster", 
15:"TodSlave", 
16:"TodMaster", 
17:"TapSlave", 
18:"DcfSlave", 
19:"DcfMaster", 
20:"RedTsn", 
21:"TsnIic", 
22:"NtpServer", 
23:"NtpClient", 
25:"ClkFrequencyGenerator", 
26:"SynceNode", 
27:"PpsClkToPps", 
28:"PtpServer", 
29:"PtpClient", 
}


@dataclass
class NtpServerProps:
    Index:                Optional[int] = 22
    version:              Optional[int] = 0
    status:               Optional[int] = 1
    ipmode:               Optional[int] = 2
    ipaddress:            Optional[int] = 3
    macaddress:           Optional[int] = 4
    vlanstatus:           Optional[int] = 5
    vlanaddress:          Optional[int] = 6
    unicastmode:          Optional[int] = 7
    multicastmode:        Optional[int] = 8
    broadcastmode:        Optional[int] = 9
    precisionvalue:       Optional[int] = 10
    pollintervalvalue:    Optional[int] = 11
    stratumvalue:         Optional[int] = 12
    referenceid:          Optional[int] = 13
    smearingstatus:       Optional[int] = 14
    leap61inprogress:     Optional[int] = 15
    leap59inprogress:     Optional[int] = 16
    leap61status:         Optional[int] = 17
    leap59status:         Optional[int] = 18
    utcoffsetstatus:      Optional[int] = 19
    utcoffsetvalue:       Optional[int] = 20
    requestsvalue:        Optional[int] = 21
    responsesvalue:       Optional[int] = 22
    requestsdroppedvalue: Optional[int] = 23
    broadcastsvalue:      Optional[int] = 24
    clearcountersstatus:  Optional[int] = 25

ntp = NtpServerProps()

@dataclass
class PpsSlaveProps:
    Index:           Optional[int] = 7
    Version:         Optional[int] = 0
    EnableStatus:    Optional[int] = 1
    Polarity:        Optional[int] = 2
    InputOkStatus:   Optional[int] = 3
    PulsewidthValue: Optional[int] = 4
    CableDelayValue: Optional[int] = 5
    
pps = PpsSlaveProps()

async def ListenSocket(term):
    try: 
        reader, writer = await asyncio.open_unix_connection("/tmp/serial.sock")

    #print(f'Send: {message!r}')
    #writer.write(message.encode())
    #await writer.drain()
        while True:

            data = await reader.read(100)
            term.write(data)
            #print(f'Received: {data.decode()!r}')
            
    finally:

        #print('Close the connection')
        writer.close()
        await writer.wait_closed()

    

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