import asyncio
import ipaddress
import json
import os
import sys
import time
from nicegui import ui, app
from dataclasses import dataclass, asdict

from commands import runCmd

from typing import Optional

from dbus import dbus
from snmp_client import GetSnmp


snmp_config_file = "/etc/snmp/snmpd.conf"
default_persistent_dir_path = "/var/lib/snmp"



from snmp_lib import V3User, V2User


    
def _getUsersDict(users):
    return [asdict(i) for i in users]
    

def _isValidNetwork(v :str) -> bool:
    try:
        ipaddress.ip_network(v)
        return True
    except ValueError:
        return False

def _isValidIp(v: str) -> bool:
    try:
        ipaddress.ip_address(v)
        return True
    except ValueError:
        return False
    
def _isValidNetworkOrIp(v :str) -> bool:
    return _isValidIp(v) or _isValidNetwork(v)



def IsV2User(community: str) -> bool:
    return any(u.Community == community for u in ReadV2Users())

def IsV3User(username: str) -> bool:
    return any(u.UserName == username for u in ReadV3Users())






def validate_group(group: list):
    return [x.validate() for x in group]






def add_v2_dialog():
    v2 = V2User()
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

def table(tab_title :str, row_elements, col_param, dialog, visible_cols :str, card):

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
                <a :href="'/snmp/'+ props.row.{col_param}" class="text-accent cursor-pointer hover:underline"> {{{{ props.value }}}} </a>
            </q-td>
        ''')
    
    with table.add_slot(f'body-cell-{col_param}'):
        # Dynamic text from cell value, styled as perfect link
        ui.button(
            {{'props.value'}},  # Shows the actual cell content
            on_click=lambda: card({'props.row[col_param]'})
        ).props(
            "flat dense color=primary no-caps unelevated round borderless"
        ).classes(
            "text-primary no-shadow no-outline hover:underline hover:text-accent"
            " text-sm font-medium cursor-pointer no-padding"
        ).style("text-decoration: none")

    #ith table.add_slot(f'body-cell-{{{{ props.value }}}}'):
    #   #ui.link(col_param).classes("text-accent cursor-pointer hover:underline")
    #   ui.label(col_param).classes("text-accent cursor-pointer hover:underline").on('click', lambda: card())

    
    table.props(f'visible-columns={visible_cols}')  # Only show these
    
    with table.add_slot('top-right'):
        ui.button(icon="add", on_click = dialog.open).props(
            "flat color=accent align=left").classes("w-full").props("dense")
    



        

async def snmp_page():

    snmp = await GetSnmp(dbus.Bus)

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
            active = await snmp.call_is_active()
            
            if result == "enable" and not active:
                await snmp.call_start()
            
            if result == "disable" and active:
                await snmp.call_stop()

            e.sender.value = await snmp.call_is_active()

        async def snmp_reset_cb(e):
            with ui.dialog() as dialog, ui.card():
                ui.label(f'Are you sure you want to reset snmp?')
                with ui.row():
                    ui.button('Cancel', on_click=lambda: dialog.submit("Cancel")).props("flat color=accent align=left")
                    ui.button('Reset', on_click=lambda: dialog.submit("reset")).props("flat color=accent align=left")    
            if await dialog == "reset":
                await snmp.call_reset()
            
        
        with ui.card().classes("w-full"):
            snmp_service_switch = ui.switch("SNMPD Status").on('click', lambda e: snmp_switch_cb(e)).props("flat color=accent align=left dense")
            snmp_service_switch.value = await snmp.call_is_active()
            ui.button("Reset SNMPD Config", on_click=snmp_reset_cb).props("flat color=accent align=left dense")


        v2Users = await snmp.call_get_v2_users()
        v3Users = await snmp.call_get_v3_users()
     
        table("V2 Users", v2Users, "Community", add_v2_dialog(), "Community,Version,Source,GroupName", edit_delete_v2_user_card)  # Only show these
        table("V3 Users", v3Users, "UserName", add_v3_dialog(), "UserName,Version,GroupName,AuthType,PrivType", edit_delete_v3_user_card)
        


async def snmp_user_page(user: str):

    snmp = await GetSnmp(dbus.Bus)


    with ui.row():
        ui.link('SNMP', '/snmp')
        ui.label('>')
        ui.label(user)

        user = await snmp.call_

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
            source = ui.input("Source / IP Address", validation={"Please enter a valid ip address or valid cidr address": lambda value: _isValidNetworkOrIp(value)}, value=user.Source).classes("w-full")
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


