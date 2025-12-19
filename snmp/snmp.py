import json
from nicegui import ui, app
from dataclasses import dataclass, asdict

from typing import Optional


snmp_config_file = "/etc/snmp/snmpd.conf"

@dataclass
class Group:
    GroupName: Optional[str] = None
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
    GroupName: Optional[str] = None

@dataclass
class V2User:
    Community:Optional[str] = None
    ComNumber:Optional[str] = None
    Version:Optional[str] = None
    GroupName:Optional[str] = None
    Source:Optional[str] = None
    SecName:Optional[str] = None

def GetUsers() -> tuple[list[V2User], list[V3User]]:

    groups = []
    v2s = []
    v3s = []

    with open(snmp_config_file, "r") as f:
        content = f.readlines()

    for line in content:
        line = line.strip("\n")
        if line.startswith("group"):
            g = Group()
            fields = line.split(" ")
            if len(fields) == 4:
                g.GroupName = fields[1]
                g.Version = fields[2]
                g.SecName = fields[3]
                groups.append(g)
      
        if line.startswith("com2sec"):
            v2 = V2User()
            fields = line.split(" ")
            if len(fields) == 4:
                v2.SecName = fields[1]
                v2.Source = fields[2]
                v2.Community = fields[3]
                v2s.append(v2)

        if line.startswith("createUser"):
            v3 = V3User()
            fields = line.split(" ")
            if len(fields) == 6:
                v3.UserName = fields[1]
                v3.AuthType = fields[2]
                v3.AuthPassphrase = fields[3]
                v3.PrivType = fields[4]
                v3.PrivPassphrase = fields[5]
                v3s.append(v3)
    pass # for

    g: Group
    for g in groups:
        v2: V2User
        for v2 in v2s:
            if g.SecName == v2.SecName:
                v2.SecName = g.SecName
                v2.GroupName = g.GroupName
                v2.Version = g.Version
        
        v3: V3User
        for v3 in v3s:
            if g.SecName == v3.UserName:
                v3.GroupName = g.GroupName
                v3.Version = g.Version
    pass

    return v2s, v3s


def GetV3Users():
    _, v3s = GetUsers()
    return v3s

def GetV2Users():
    v2s, _ = GetUsers()
    return v2s

def GetUsersDict(users):
    return [asdict(i) for i in users]


def GetV3UsersDict():
    return GetUsersDict(GetV3Users())

def GetV2UsersDict():
    return GetUsersDict(GetV2Users())


def IsV2User(community: str) -> bool:
    return any(u.Community == community for u in GetV2Users())

def IsV3User(username: str) -> bool:
    return any(u.UserName == username for u in GetV3Users())


def GetV2User(community: str) -> V2User:
    u :V2User
    for u in GetV2Users():
        if u.Community == community:
            return u
    return None

def GetV3User(username: str) -> V3User:
    u :V3User
    for u in GetV3Users():
        if u.UserName == username:
            return u
    return None


def add_v2_dialog():
    with ui.dialog() as dialog:
        with ui.card():
            ui.label("add a v2 dude")
    return dialog


def add_v3_dialog():
    with ui.dialog() as dialog:
        with ui.card():
            ui.label("add a v3 dude")
    return dialog

def table(tab_title :str, row_elements, col_param, dialog):

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
    
    with table.add_slot('top-right'):
        ui.button(icon="add", on_click = dialog.open).props(
            "flat color=accent align=left").classes("w-full").props("dense")
    



        

async def snmp_page():
    with ui.column():

        ui.label("SNMP").classes("text-h5")
     
        table("V2 Users", GetV2UsersDict(), "Community", add_v2_dialog())
     
        table("V3 Users", GetV3UsersDict(), "UserName", add_v3_dialog())




async def snmp_user_page(user: str):

    with ui.row():
        ui.link('SNMP', '/snmp')
        ui.label('>')
        ui.label(user)

        if IsV2User(user):
            await edit_delete_v2_user_card(user)
        
        if IsV3User(user):
            await user_card(user, "v3")



def enable_group(flag :bool, fields):
    for f in fields:
        f.enabled = flag

async def edit_delete_v2_user_card(community):
    user = GetV2User(community)
    with ui.card().classes("w-full"):
        with ui.column().classes("w-full"):
            version = ui.select(label="Version", options=["v2c", "v1"], value=user.Version).classes("w-full")
            permissions = ui.select(label="Permissions", options=['rwnoauthgroup', 'ronoauthgroup'], value=user.GroupName).classes("w-full")
            community = ui.input("Community", value=user.Community).classes("w-full")
            source = ui.input("Source / IP Address", value=user.Source).classes("w-full")

            with ui.row():
                edit_button = ui.button("edit", on_click=lambda: enable_group(True, fields)).props("flat color=accent align=left")

                save_button = ui.button("save", on_click=lambda: enable_group(False, fields)).props("flat color=accent align=left")

            fields = [community, source, version, permissions, save_button]

            enable_group(False, fields)





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