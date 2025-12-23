import ipaddress
import json
import os
import sys
import time
from nicegui import ui, app
from dataclasses import dataclass, asdict

from commands import runCmd

from typing import Optional


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
    Community:Optional[str] = None
    ComNumber:Optional[str] = None
    Version:Optional[str] = None
    Permissions:Optional[str] = None
    Source:Optional[str] = None
    SecName:Optional[str] = None


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

def StopSnmpd():
    print("stoping... snmpd")

    runCmd(["systemctl", "stop", "snmpd"])

def StartSnmpd():
    print("starting... snmpd")
    runCmd(["systemctl", "start", "snmpd"])

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

def IsValidNetwork(v :str) -> bool:
    try:
        ipaddress.ip_network(v)
        return True
    except ValueError:
        return False

def IsValidIp(v: str) -> bool:
    try:
        ipaddress.ip_address(v)
        return True
    except ValueError:
        return False
    
def IsValidNetworkOrIp(v :str) -> bool:
    return IsValidIp(v) or IsValidNetwork(v)




def GetUsersDict(users):
    return [asdict(i) for i in users]


def GetV2UsersDict():
    return GetUsersDict(ReadV2Users())

def GetV3UsersDict():
    return GetUsersDict(ReadV3Users())




def IsV2User(community: str) -> bool:
    return any(u.Community == community for u in ReadV2Users())

def IsV3User(username: str) -> bool:
    return any(u.UserName == username for u in ReadV3Users())


def GetV2UserByCommunity(community: str) -> V2User:
    u :V2User
    for u in ReadV2Users():
        if u.Community == community:
            return u
    return None

def GetV3UserByUsername(username: str) -> V3User:
    u :V3User
    for u in ReadV3Users():
        if u.UserName == username:
            return u
    return None


def validate_group(group: list):
    return [x.validate() for x in group]

def add_v2_dialog():

    with ui.dialog() as dialog:
        with ui.card().classes("w-full"):
            with ui.column().classes("w-full"):
                version = ui.select(label="Version", options=["v2c", "v1"], value="v2c").classes("w-full")
                permissions = ui.select(label="Permissions", options=['rwnoauthgroup', 'ronoauthgroup'], value="rwnoauthgroup").classes("w-full")
                community = ui.input("Community", validation={'Community required': lambda value: len(value) > 0}).classes("w-full")
                source = ui.input("Source / IP Address", value=None, validation={"Please enter a valid ip address or valid cidr address": lambda value: IsValidNetworkOrIp(value)}).classes("w-full")

                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    def on_save_cb():
                        user = V2User()
                        user.Version = version.value
                        user.Permissions = permissions.value
                        user.Source = source.value
                        user.Community = community.value
                        if all(validate_group([version, permissions, community, source])):
                            AddV2User(user)
                            dialog.close()
                        else:
                            ui.notify("Please correct the errors", type='negative')
                            

                    def on_cancel_cb():
                        dialog.close()

                    save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                    cancel_button = ui.button(icon="cancel", on_click=on_cancel_cb).props("flat color=accent align=left")
    return dialog



        
def add_v3_dialog():
    with ui.dialog() as dialog:
        with ui.card().classes("w-full"):
            with ui.column().classes("w-full"):
                version = ui.input(label="Version", value="usm").classes("w-full")
                username = ui.input(label="Username", validation={"Please enter a username": lambda value: len(value) > 0}).classes("w-full")
                permissions = ui.select(label="Permissions", options=["roprivgroup", "rwprivgroup"], value="rwprivgroup").classes("w-full")
                auth_type = ui.select(label="Auth Alg", options=['SHA', 'MD5'], value="SHA").classes("w-full")
                auth_pass = ui.input(label="Auth Passphrase", validation={"Passphrase must be at least 8 characters": lambda value: len(value) >= 8}).classes("w-full")
                priv_type = ui.select(label="Priv Alg", options=["AES", "DES"], value="AES").classes("w-full")
                priv_pass = ui.input(label="Auth Passphrase", validation={"Passphrase must be at least 8 characters": lambda value: len(value) >= 8}).classes("w-full")

                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    def on_save_cb():
                        user = V3User(
                            Version=version.value,
                            UserName=username.value,
                            Permissions=permissions.value,
                            AuthType=auth_type.value,
                            AuthPassphrase=auth_pass.value,
                            PrivType=priv_type.value,
                            PrivPassphrase=priv_pass.value
                        )
                
                        if all(validate_group([version, username, permissions, auth_type, auth_pass, priv_type, priv_pass])):
                            AddV3User(user)
                            dialog.close()
                        else:
                            ui.notify("Please correct the errors", type='negative')

                    def on_cancel_cb():
                        dialog.close()

                    save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                    cancel_button = ui.button(icon="cancel", on_click=on_cancel_cb).props("flat color=accent align=left")
    return dialog

def table(tab_title :str, row_elements, col_param, dialog, visible_cols :str):

    table = ui.table(
            title=tab_title,
            rows=row_elements,
            column_defaults={
                "align": "left",
                "headerClasses": "uppercase text-primary",
            },
        ).classes("w-full")
    
    table.add_slot(f'body-cell-{col_param}', f'''
            <q-td :props="props">
                <a :href="'/snmp/' + props.row.{col_param}" 
                   class="text-accent cursor-pointer hover:underline"
                   >
                    {{{{ props.value }}}}
                </a>
            </q-td>
        ''')
    
    table.props(f'visible-columns={visible_cols}')  # Only show these
    
    with table.add_slot('top-right'):
        ui.button(icon="add", on_click = dialog.open).props(
            "flat color=accent align=left").classes("w-full").props("dense")
    



        

async def snmp_page():
    with ui.column():

        ui.label("SNMP").classes("text-h5")
        
        async def snmp_switch_cb(e):
            action = "enable" if  e.sender.value else "disable"
            with ui.dialog() as dialog, ui.card():
                ui.label(f'Are you sure you want to {action} snmp?')
                with ui.row():
                    ui.button('Cancel', on_click=lambda: dialog.submit("Cancel")).props("flat color=accent align=left")
                    ui.button(f'{action}', on_click=lambda: dialog.submit(action)).props("flat color=accent align=left")
        
            result = await dialog
            
            if result == "enable" and not IsActiveSnmpd():
                StartSnmpd()
            
            if result == "disable" and IsActiveSnmpd():
                StopSnmpd()
            
            e.sender.value = IsActiveSnmpd()

        async def snmp_reset_cb(e):
            with ui.dialog() as dialog, ui.card():
                ui.label(f'Are you sure you want to reset snmp?')
                with ui.row():
                    ui.button('Cancel', on_click=lambda: dialog.submit("Cancel")).props("flat color=accent align=left")
                    ui.button('Reset', on_click=lambda: dialog.submit("reset")).props("flat color=accent align=left")    
            if await dialog == "reset":
                ResetSnmpd()
            

            
        
        with ui.card().classes("w-full"):
            snmp_service_switch = ui.switch("SNMPD Status").on('click', lambda e: snmp_switch_cb(e)).props("flat color=accent align=left dense")
            snmp_service_switch.value = IsActiveSnmpd()
            ui.button("Reset SNMPD Config", on_click=snmp_reset_cb).props("flat color=accent align=left dense")
     
        table("V2 Users", GetV2UsersDict(), "Community", add_v2_dialog(), "Community,Version,Source,GroupName")  # Only show these
     
        table("V3 Users", GetV3UsersDict(), "UserName", add_v3_dialog(), "UserName,Version,GroupName,AuthType,PrivType")
        
        #ui.button("Reset SNMP Config", on_click=ResetSnmpConfig)




async def snmp_user_page(user: str):

    with ui.row():
        ui.link('SNMP', '/snmp')
        ui.label('>')
        ui.label(user)

        if IsV2User(user):
            await edit_delete_v2_user_card(user)
        
        if IsV3User(user):
            #await user_card(user, "v3")
            await edit_delete_v3_user_card(user)



def enable_group(fields):
    for f in fields:
        f.enabled = True

def disable_group(fields):
    for f in fields:
        f.enabled = False









async def edit_delete_v2_user_card(community):
    user = GetV2UserByCommunity(community)
    with ui.card().classes("w-full"):
        with ui.column().classes("w-full"):
            version = ui.select(label="Version", options=["v2c", "v1"], value=user.Version).classes("w-full")
            permissions = ui.select(label="Permissions", options=['rwnoauthgroup', 'ronoauthgroup'], value=user.Permissions).classes("w-full")
            community = ui.input("Community", validation={'Community required': lambda value: len(value) > 0}, value=user.Community).classes("w-full")
            source = ui.input("Source / IP Address", validation={"Please enter a valid ip address or valid cidr address": lambda value: IsValidNetworkOrIp(value)}, value=user.Source).classes("w-full")
            with ui.row().classes("items-center justify-between gap-4 w-full"):

                def on_save_cb():
                    disable_group(group)
                    save_button.enabled = False
                    edit_button.enabled = True
                    user.Community = community.value
                    user.Version = version.value
                    user.Permissions = permissions.value
                    user.Source = source.value
                    EditV2User(user)
                    ui.navigate.back()

                def on_edit_cb():
                    enable_group(group)
                    edit_button.enabled = False
                    save_button.enabled = True

                async def on_delete_cb():
                    with ui.dialog() as dialog, ui.card():
                        ui.label(f'Are you sure you want to delete {user.Community}?')
                        with ui.row():
                            ui.button('Yes', on_click=lambda: dialog.submit(True)).props("flat color=accent align=left")
                            ui.button('No', on_click=lambda: dialog.submit(False)).props("flat color=accent align=left")
                    result = await dialog
                    if result:
                        DeleteV2User(user)
                        ui.navigate.back()
                        ui.notify(f'User {user.Community} deleted...')
                    else:
                        dialog.close()

                edit_button = ui.button("edit", on_click= on_edit_cb).props("flat color=accent align=left")
                save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                delete_button = ui.button(icon="delete", on_click=on_delete_cb).props("flat color=accent align=left")

                group = [community, source, version, permissions]

                disable_group(group)
                edit_button.enabled = True
                save_button.enabled = False




    
async def edit_delete_v3_user_card(username):
    inituser = GetV3UserByUsername(username)

    with ui.card().classes("w-full"):
        with ui.column().classes("w-full"):

            version = ui.input(label="Version", value="usm").classes("w-full")
            username = ui.input(label="Username", value=inituser.UserName, validation={"Please enter a username": lambda value: len(value) > 0}).classes("w-full")
            permissions = ui.select(label="Permissions", value=inituser.Permissions, options=["roprivgroup", "rwprivgroup"]).classes("w-full")
            auth_type = ui.select(label="Auth Alg", value=inituser.AuthType, options=['SHA', 'MD5']).classes("w-full")
            auth_pass = ui.input(label="Auth Passphrase", validation={"Passphrase must be at least 8 characters": lambda value: len(value) >= 8}).classes("w-full")
            priv_type = ui.select(label="Priv Alg", value=inituser.PrivType, options=["AES", "DES"]).classes("w-full")
            priv_pass = ui.input(label="Auth Passphrase", validation={"Passphrase must be at least 8 characters": lambda value: len(value) >= 8}).classes("w-full")

            with ui.row().classes("items-center justify-between gap-4 w-full"):

                def on_save_cb():
                        disable_group(group)
                        save_button.enabled = False
                        edit_button.enabled = True
                        finaluser = V3User(
                            Version=version.value,
                            UserName=username.value,
                            Permissions=permissions.value,
                            AuthType=auth_type.value,
                            AuthPassphrase=auth_pass.value,
                            PrivType=priv_type.value,
                            PrivPassphrase=priv_pass.value
                            )

                        if all(validate_group([version, username, permissions, auth_type, auth_pass, priv_type, priv_pass])):
                            EditV3User(inituser, finaluser)
                            ui.navigate.back()
                        else:
                            ui.notify("Please correct the errors", type='negative')


                def on_edit_cb():
                    enable_group(group)
                    edit_button.enabled = False
                    save_button.enabled = True


                async def on_delete_cb():
                    with ui.dialog() as dialog, ui.card():
                        ui.label(f'Are you sure you want to delete {inituser.UserName}?')
                        with ui.row():
                            ui.button('Yes', on_click=lambda: dialog.submit(True)).props("flat color=accent align=left")
                            ui.button('No', on_click=lambda: dialog.submit(False)).props("flat color=accent align=left")
                    result = await dialog
                    if result:
                        DeleteV3User(inituser)
                        ui.navigate.back()
                        ui.notify(f'User {inituser.UserName} deleted...')
                    else:
                        dialog.close()

                edit_button = ui.button("edit", on_click= on_edit_cb).props("flat color=accent align=left")
                save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                delete_button = ui.button(icon="delete", on_click=on_delete_cb).props("flat color=accent align=left")

                group = [permissions, username, auth_type,auth_pass,priv_type,priv_pass]

                disable_group(group)
                edit_button.enabled = True
                save_button.enabled = False


