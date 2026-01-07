import asyncio
import ipaddress
import json
import os
import sys
import time
from nicegui import ui, app
from dataclasses import dataclass, asdict

from commands import runCmd

from typing import Dict, List, Optional

from dbus_next.service import ServiceInterface, method, dbus_property, signal, Variant
from dbus_next.aio import MessageBus
from dbus_next.constants import BusType

snmp_config_file = "/etc/snmp/snmpd.conf"
default_persistent_dir_path = "/var/lib/snmp"




USM_OID_MAP = {
    # Authentication Protocols (RFC 3414)
    "1.3.6.1.6.3.10.1.1.1": "NoAuth",
    ".1.3.6.1.6.3.10.1.1.2": "MD5", 
    ".1.3.6.1.6.3.10.1.1.3": "SHA",
    "1.3.6.1.6.3.10.1.1.4": "HMAC-SHA2-224",
    "1.3.6.1.6.3.10.1.1.5": "HMAC-SHA2-256",
    
    # Privacy Protocols (RFC 3414 + 3826)
    "1.3.6.1.6.3.10.1.2.1": "NoPriv",
    ".1.3.6.1.6.3.10.1.2.2": "DES",
    ".1.3.6.1.6.3.10.1.2.4": "AES",
    "1.3.6.1.6.3.10.1.2.5": "AES-192", 
    "1.3.6.1.6.3.10.1.2.6": "AES-256"
}


@dataclass
class Group:
    Permissions: Optional[str] = None
    Version: Optional[str] = None
    SecName: Optional[str] = None

@dataclass
class V3User:
    UserName: Optional[str] = None
    Version: Optional[str] = None
    AuthType: Optional[str] = None
    AuthPassphrase: Optional[str] = None
    PrivType: Optional[str] = None
    PrivPassphrase: Optional[str] = None
    Permissions: Optional[str] = None

@dataclass
class V2User:
    Community:Optional[str] = ''
    ComNumber:Optional[str] = ''
    Version:Optional[str] = ''
    Permissions:Optional[str] = ''
    Source:Optional[str] = ''
    SecName:Optional[str] = ''


def ReadSnmpGroupsFromFile() -> list[Group]:

    groups = []

    with open(snmp_config_file, "r") as f:
        content = f.readlines()
        
    for line in content:
        line = line.strip("\n")
        if line.startswith("group"):
            g = Group()
            fields = line.split(" ")
            if len(fields) == 4:
                g.Permissions = fields[1]
                g.Version = fields[2]
                g.SecName = fields[3]
                groups.append(g)
    pass #endfor  

    return groups

def ReadV2UsersFromFile() -> list[V2User]:

    v2s = []

    with open(snmp_config_file, "r") as f:
        content = f.readlines()

    for line in content:
        line = line.strip("\n")
        if line.startswith("com2sec"):
            v2 = V2User()
            fields = line.split(" ")
            if len(fields) == 4:
                v2.SecName = fields[1]
                v2.Source = fields[2]
                v2.Community = fields[3]
                v2s.append(v2)
    pass #endfor

    return v2s

def ReadV3UsersFromFile() -> list[V3User]:

    v3s = []
    try:
        with open(GetPersistentConfPath(), "r") as f:
            content = f.readlines()

        for line in content:
            line = line.strip("\n")
            if line.startswith("usmUser"):
                v3 = V3User()
                fields = line.split(" ")
                if len(fields) == 12:
                
                    v3.UserName = fields[4].strip('"')

                    v3.AuthType = USM_OID_MAP.get(fields[7], f"Unknown")
                    #v3.AuthPassphrase = fields[3]
                    v3.PrivType = USM_OID_MAP.get(fields[9], f"Unknown")
                    #v3.PrivPassphrase = fields[5]
                    v3s.append(v3)
        pass # endfor
    except FileNotFoundError:
        return v3s
    return v3s

def ReadV2Users() -> list[V2User]:
    groups = ReadSnmpGroupsFromFile()
    v2s = ReadV2UsersFromFile()
    g: Group
    for g in groups:
        v2: V2User
        for v2 in v2s:
            if g.SecName == v2.SecName:
                v2.SecName = g.SecName
                v2.Permissions = g.Permissions
                v2.Version = g.Version
        pass #endfor
    pass #endfor
    return v2s

def ReadV3Users() -> list[V3User]:
    groups = ReadSnmpGroupsFromFile()
    v3s = ReadV3UsersFromFile()
    g: Group
    for g in groups:
        v3: V3User
        for v3 in v3s:
            if g.SecName == v3.UserName:
                print(g.SecName)
                v3.Permissions = g.Permissions
                v3.Version = g.Version
        pass #endfor
    pass #endfor
    return v3s

def WriteV2User(user :V2User):
    '''add v2 user to file'''
    print("write v2 user")
    lineCount = 0
    userIndex = -1
    groupIndex = -1

    user.ComNumber = len(ReadV2Users())

    with open(snmp_config_file, "r") as f:
        content = f.readlines()
    
    for i, line in enumerate(content):
        line = line.strip("\n")
        if line.startswith("#com2sec"):
            userIndex = lineCount + 2
        if line.startswith("#group"):
            groupIndex = lineCount + 3
        
        lineCount = lineCount + 1
    pass # endfor 


    newUserLine = f"com2sec comuser_{user.ComNumber} {user.Source} {user.Community}\n"
    newGroupLine = f"group {user.Permissions} {user.Version} comuser_{user.ComNumber}\n"


    if userIndex < 0:
        content.append("#-------------------------------------------------------------------------------")
        content.append("#com2sec sec.name source community")
        content.append("#-------------------------------------------------------------------------------")
        content.append(newUserLine)
    else:
        content.insert(userIndex, newUserLine)

    if groupIndex < 0:
        content.append("#-------------------------------------------------------------------------------")
        content.append("#group  group name      sec.model  sec.name")
        content.append("#-------------------------------------------------------------------------------")
        content.append(newGroupLine)
    else:
        content.insert(groupIndex, newGroupLine)


    with open(snmp_config_file, "w") as f:
        f.writelines(content)
        #content = f.readlines()
    
def WriteV3UserCreateDirective(user: V3User):
    '''add v3 user to file'''
    print("write v3 user")

    lineCount = 0
    createUserIndex = -1
    groupIndex = -1

    with open(snmp_config_file, "r") as f:
        content = f.readlines()
    
    for i, line in enumerate(content):
        line = line.strip("\n")
        if line.startswith("#createUser"):
            createUserIndex = lineCount + 2
        if line.startswith("#group"):
            groupIndex = lineCount + 3
        
        lineCount = lineCount + 1
    pass # endfor 

    newUserLine = f"createUser {user.UserName} {user.AuthType} {user.AuthPassphrase} {user.PrivType} {user.PrivPassphrase}\n"
    newGroupLine = f"group {user.Permissions} {user.Version} {user.UserName}\n"


    if createUserIndex < 0:
        content.append("#-------------------------------------------------------------------------------")
        content.append("#createUser username [MD5|SHA] [passphrase] [DES] [passphrase]")
        content.append("#-------------------------------------------------------------------------------")
        content.append(newUserLine)
    else:
        content.insert(createUserIndex, newUserLine)

    if groupIndex < 0:
        content.append("#-------------------------------------------------------------------------------")
        content.append("#group  group name      sec.model  sec.name")
        content.append("#-------------------------------------------------------------------------------")
        content.append(newGroupLine)
    else:
        content.insert(groupIndex, newGroupLine)


    with open(snmp_config_file, "w") as f:
        f.writelines(content)
        #content = f.readlines()
    
def AddV3User(user: V3User):
    '''add v3 user'''
    print('add v3 dude')

    StopSnmpd()

    WriteV3UserCreateDirective(user)

    StartSnmpd() # real user created

    DeleteV3UserCreateDirective(user)

def AddV2User(user: V2User):
    '''add v2 user'''

    print("add a v2 user")
    StopSnmpd()

    WriteV2User(user)

    StartSnmpd()


def EditV2User(user: V2User):
    '''edit v2 user'''

    print("edit a v2 user")

    existingUser = GetV2UserBySecurityName(user)

    if not existingUser:
        print("USER NOT FOUND")
        sys.exit()

    StopSnmpd()

    DeleteV2User(existingUser)

    WriteV2User(user)

    StartSnmpd()
    



def EditV3User(inituser :V3User, finaluser: V3User):
    '''edit v3 user'''


    if not inituser:
        print("v3 USER NOT FOUND")
        sys.exit()

    StopSnmpd()

    DeleteV3UserFromStorage(inituser) # remove actual
    DeleteV3UserFromConfig(inituser) # remove group

    WriteV3UserCreateDirective(finaluser) # add grup and create
    
    StartSnmpd() # create
    
    DeleteV3UserCreateDirective(finaluser) # remove create dir


def DeleteV2User(user: V2User):
    '''delete v2 user'''
    print("del a v2 user")
    
    _user = [ user.SecName, user.Source, user.Community]
    _group = [ user.Permissions, user.Version, user.SecName]

    with open(snmp_config_file, "r") as f:
        content = f.readlines()

    for i, line in enumerate(content):
        if line.startswith("com2sec") and all(p in line for p in _user):
            content.remove(line)
        if line.startswith("group") and all(p in line for p in _group):
            content.remove(line)

    with open(snmp_config_file, "w") as f:
        f.writelines(content)



def DeleteV3UserFromStorage(user: V3User):
    '''delete v3 user from persistent storgage'''

    with open(GetPersistentConfPath()) as f:
        content = f.readlines()

    for i, line in enumerate(content):
        if line.startswith("usmUser"):

            fields = line.split(" ")
            temp_auth_type = USM_OID_MAP.get(fields[7], f"Unknown")
            temp_priv_type = USM_OID_MAP.get(fields[9], f"Unknown")

            if user.UserName in line and temp_auth_type == user.AuthType and temp_priv_type == user.PrivType:
                content.remove(line)

    with open(GetPersistentConfPath(), "w") as f:
        f.writelines(content)


def DeleteV3UserCreateDirective(user: V3User):
    _props  = [user.UserName, user.AuthType, user.AuthPassphrase, user.PrivType, user.PrivPassphrase]

    with open(snmp_config_file, "r") as f:
        content = f.readlines()

    for i, line in enumerate(content):
        if line.startswith("createUser") and all(p in line for p in _props):
            content.remove(line)

    with open(snmp_config_file, "w") as f:
        f.writelines(content)
        

def DeleteV3UserFromConfig(user: V3User):
    '''delete v3 user from /etc/snmp/snmpd.conf'''

    _props = [user.Permissions, user.Version, user.UserName]

    with open(snmp_config_file, "r") as f:
        content = f.readlines()
        
        for i, line in enumerate(content):
            if line.startswith("group") and all(p in line for p in _props):
                content.remove(line)

    with open(snmp_config_file, "w") as f:
        f.writelines(content)

def DeleteV3User(user: V3User):
    DeleteV3UserFromConfig(user)
    DeleteV3UserFromStorage(user)


def GetV2UserBySecurityName(user :V2User) -> V2User:
    '''look up v2 user'''
    u :V2User
    for u in ReadV2Users():
        if u.SecName == user.SecName:
            return u
    return None



def GetPersistentDir() -> str:

    with open(snmp_config_file, "r") as f:
        content = f.readlines()
        
    for i, line in enumerate(content):
        if line.startswith("persistentDir"): 
            fields = line.split(" ")
            if len(fields) == 2:
                return fields[1].strip("\n")
    pass #endfor

    return None

def SetPersistentDir(path):
    with open(snmp_config_file, "r") as f:
        content = f.readlines()
    
    for i, line in enumerate(content):
        if line.startswith("persistentDir"): 
            content[i] = f"persistentDir {path}\n"
            break
    with open(snmp_config_file, "w") as f:
        f.writelines(content)

        
def GetPersistentConfPath() -> str:
    persistentDir = GetPersistentDir()
    return os.path.join(persistentDir, "snmpd.conf")    
        
def DeletePersistentDir():
    runCmd(['rm', '-rf', GetPersistentDir()])
    
def MakeEmptyPersistentDirConf():
    perDir = GetPersistentDir()
    runCmd(['touch', os.path.join(perDir, "snmpd.conf")])

    
def OverWriteWithDefaultSnmpConf():
    runCmd(['cp', './configs/snmpd.conf', '/etc/snmp/snmpd.conf'])

#@require_service_management
def StopSnmpd():
    print("stoping... snmpd")

    runCmd(["systemctl", "stop", "snmpd"])

#@require_service_management
def StartSnmpd():
    print("starting... snmpd")
    runCmd(["systemctl", "start", "snmpd"])

#@require_service_management
def RestartSnmpd():
    print("restarting... snmpd")

    runCmd(["systemctl", "restart", "snmpd"])
    
    
def ResetSnmpd():
    
    # 1. Stop Snmp
    StopSnmpd()
    # 2. Remove Persistent Dir
    DeletePersistentDir()
    # 3. Reset Main Config
    OverWriteWithDefaultSnmpConf()
    # 4. Set Tmp Path for Persistent Dir
    SetPersistentDir("/var/lib/tmp")
    # 5. Start Snmp
    StartSnmpd()
    # 6. Stop Snmp
    StopSnmpd()
    # 7. Remove Temp Persistent Dir
    DeletePersistentDir()
    # 8. Set Real Path for Persistent Dir
    SetPersistentDir("/var/lib/snmp")
    # 9. Start Snmp
    StartSnmpd()



    

def IsActiveSnmpd() -> bool:
    status = runCmd(["sudo", "systemctl", "is-active", "snmpd"])
    if status.strip("\n") == "active":
        return True
    else:
        return False





class SnmpInterface(ServiceInterface):
    def __init__(self, name):
        super().__init__(name)


    @method()
    def GetV2Users(self) -> 'aa{ss}':
        return [asdict(u) for u in ReadV2Users()]

    

async def main():
    bus = await MessageBus(bus_type=BusType.SYSTEM).connect()
    interface = SnmpInterface('test.interface')
    bus.export('/test/path', interface)
    print("Start PAM Service")
    await bus.request_name('test.name')
    await asyncio.Event().wait()

asyncio.run(main())
