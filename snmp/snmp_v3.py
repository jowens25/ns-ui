import ipaddress
import json
import os
import sys
from nicegui import ui, app
from dataclasses import dataclass, asdict

from commands import runCmd

from typing import Optional

from .snmp import *


@dataclass
class V3User:
    UserName: Optional[str] = None
    Version: Optional[str] = None
    AuthType: Optional[str] = None
    AuthPassphrase: Optional[str] = None
    PrivType: Optional[str] = None
    PrivPassphrase: Optional[str] = None
    Permissions: Optional[str] = None



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



def ReadV3UsersFromFile() -> list[V3User]:

    v3s = []
    with open(snmp_storage_file, "r") as f:
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
    return v3s



def ReadV3Users() -> list[V3User]:
    groups = ReadSnmpGroupsFromFile()
    v3s = ReadV3UsersFromFile()
    g: Group
    for g in groups:
        v3: V3User
        for v3 in v3s:
            if g.SecName == v3.UserName:
                v3.Permissions = g.Permissions
                v3.Version = g.Version
        pass #endfor
    pass #endfor

    return v3s


    


def WriteV3User(user: V3User):
    '''add v3 user to file'''


def EditV3User(user: V3User):
    '''edit v3 user'''


def DeleteV3User(user: V3User):
    '''delete v3 user'''


def GetV3UsersDict():
    return GetUsersDict(ReadV3Users())


def IsV3User(username: str) -> bool:
    return any(u.UserName == username for u in ReadV3Users())


def GetV3UserByUsername(username: str) -> V3User:
    u :V3User
    for u in ReadV3Users():
        if u.UserName == username:
            return u
    return None


def validate_group(group: list):
    return [x.validate() for x in group]




def add_v3_dialog():
    with ui.dialog() as dialog:
        with ui.card():
            ui.label("add a v3 dude")
    return dialog



     