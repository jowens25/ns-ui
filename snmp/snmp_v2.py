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
class V2User:
    Community:Optional[str] = None
    ComNumber:Optional[str] = None
    Version:Optional[str] = None
    Permissions:Optional[str] = None
    Source:Optional[str] = None
    SecName:Optional[str] = None

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
    

def DeleteV2User(user: V2User):
    '''delete v2 user'''

    print("del a v2 user")


    userLineToDelete = f"com2sec {user.SecName} {user.Source} {user.Community}\n"
    groupLineToDelete = f"group {user.Permissions} {user.Version} {user.SecName}\n"


    with open(snmp_config_file, "r") as f:
        content = f.readlines()

    content.remove(userLineToDelete)
    content.remove(groupLineToDelete)

    with open(snmp_config_file, "w") as f:
        f.writelines(content)


def GetV2UserBySecurityName(user :V2User) -> V2User:
    '''look up v2 user'''
    u :V2User
    for u in ReadV2Users():
        if u.SecName == user.SecName:
            return u
    return None



def GetV2UsersDict():
    return GetUsersDict(ReadV2Users())



def IsV2User(community: str) -> bool:
    return any(u.Community == community for u in ReadV2Users())


def GetV2UserByCommunity(community: str) -> V2User:
    u :V2User
    for u in ReadV2Users():
        if u.Community == community:
            return u
    return None


