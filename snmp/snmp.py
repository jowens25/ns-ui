import ipaddress
import json
import os
import sys
from nicegui import ui, app
from dataclasses import dataclass, asdict

from commands import runCmd

from typing import Optional

from .snmp_v2 import *
from .snmp_v3 import *


snmp_config_file = "/etc/snmp/snmpd.conf"
snmp_storage_file = "/var/lib/snmp/snmpd.conf"



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
    


def WriteV3User(user: V3User):
    '''add v3 user to file'''



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
    
def StopSnmpd():
    runCmd(["sudo", "systemctl", "stop", "snmpd"])

def StartSnmpd():
    runCmd(["sudo", "systemctl", "start", "snmpd"])

def RestartSnmpd():
    runCmd(["sudo", "systemctl", "restart", "snmpd"])

def IsActiveSnmpd() -> bool:
    status = runCmd(["sudo", "systemctl", "is-active", "snmpd"])
    if status.strip("\n") == "active":
        return True
    else:
        return False


def EditV3User(user: V3User):
    '''edit v3 user'''

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


def DeleteV3User(user: V3User):
    '''delete v3 user'''


def GetV2UserBySecurityName(user :V2User) -> V2User:
    '''look up v2 user'''
    u :V2User
    for u in ReadV2Users():
        if u.SecName == user.SecName:
            return u
    return None




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
        with ui.card():
            ui.label("add a v3 dude")
    return dialog

def table(tab_title :str, row_elements, col_param, dialog, visible_cols :str):

    table = ui.table(
            title=tab_title,
            rows=row_elements,
            column_defaults={
                "align": "left",
                "headerClasses": "uppercase text-primary",
            },
        )
    
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
     
        table("V2 Users", GetV2UsersDict(), "Community", add_v2_dialog(), "Community,Version,Source,GroupName")  # Only show these
     
        table("V3 Users", GetV3UsersDict(), "UserName", add_v3_dialog(), "UserName,Version,GroupName,AuthType,PrivType")




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
    user = GetV3UserByUsername(username)
    with ui.card().classes("w-full"):
        with ui.column().classes("w-full"):
            version = ui.select(label="Version", value=user.Version).classes("w-full")
            permissions = ui.select(label="Permissions", options=['roauthgroup','rwauthgroup','roprivgroup','rwprivgroup'], value=user.Permissions).classes("w-full")
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




async def user_card(user :str, label: str):


    with ui.card().classes("w-full"):
        # Header row
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(user).classes("text-h6")
            ui.label("driver info").classes("text-caption")
            ui.label("control info").classes("text-caption")
            ui.link("mac address", "#")
            ui.switch("Connected").props("disable")

            ui.label(label)

        ui.separator()

        # Main content
        with ui.column().classes("w-full gap-2"):
            with ui.row().classes("items-center gap-4"):
                ui.label("Status:").classes("font-bold")
                ui.label("Active").classes("text-positive")

            with ui.row().classes("items-center gap-4"):
                ui.label("IP Address:").classes("font-bold")
                ui.label("192.168.1.100")

            with ui.row().classes("items-center gap-4"):
                ui.label("Connection:").classes("font-bold")
                ui.select(
                    ["DHCP", "MANUAL", "Static"],
                    value="DHCP",
                    #on_change=update_dhcp_mode,
                )

            with ui.row().classes("items-center gap-4"):
                ui.label("DNS:").classes("font-bold")
                ui.input(placeholder="8.8.8.8").classes("flex-grow")