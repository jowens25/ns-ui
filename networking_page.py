import asyncio
from dataclasses import asdict
from pprint import pprint
from typing import List, Optional
from nicegui import ui, app, binding
from networking_lib import *

from dbus_next.signature import Variant
from dbus_next.errors import DBusError
from dbus_next.aio.proxy_object import ProxyInterface
from dbus import dbus


async def network_page():

    with ui.column():

        interfaces = await GetInterfacesAndAddresses()

        ui.label("Networking").classes("text-h5")

        interface_table = ui.table(
            title="Interfaces",
            rows=interfaces,
            #rows=[{'d':'v'}],
            column_defaults={
                "align": "left",
                "headerClasses": "uppercase text-primary",
            },
        )


        interface_table.add_slot('body-cell-name', '''
            <q-td :props="props">
                <a :href="'/networking/' + props.row.name" 
                   class="text-accent cursor-pointer hover:underline"
                   >
                    {{ props.value }}
                </a>
            </q-td>
        ''')
        
        interface_table.add_slot('body-cell-addresses', '''
            <q-td :props="props" class="font-bold text-sm">
                {{ props.value }}
            </q-td>
        ''')


async def interface_page(interface_name: str):

    nm = GetNetworkManager(dbus.Bus)

    with ui.row():
        ui.link('Networking', '/networking')
        ui.label('>')
        ui.label(interface_name)
        await interface_card(nm, interface_name)

    def state_changed(u):
        print(u)
        interface_card.refresh()

    nm.on_state_changed(state_changed)


@ui.refreshable
async def interface_card(nm :ProxyInterface, iface :str):


    device_path = await nm.call_get_device_by_ip_iface(iface)
    device = GetDevice(dbus.Bus, device_path)

    hwaddr = await device.get_hw_address()
    flags = await device.get_interface_flags()
    #print(flags)
    carrier = processInterfaceFlags(flags)

    #autoConnect = await device.get_autoconnect()
    #state = await device.get_state()
    state = await device.get_state()
    BindState = {"state": state}
    deviceState = processDeviceState(state)
    ip4_config_path = await device.get_ip4_config()
    ip6_config_path = await device.get_ip6_config()
    active_connection_path = await device.get_active_connection()

    autoconnect = {"auto": False}

    if len(active_connection_path) > 1:
        activeConnection = GetActiveConnection(dbus.Bus, active_connection_path)
        connection_path = await activeConnection.get_connection()
        connection = GetConnection(dbus.Bus, connection_path)

        settings = await connection.call_get_settings()
        autoconnect["auto"] = GetAutoConnect(settings)
        
        pprint(settings)

    #dev = Device(autoConnect, state)

    if len(ip4_config_path) > 1:
        ip4Config = GetIp4Config(dbus.Bus, ip4_config_path)
        ip6Config = GetIp6Config(dbus.Bus, ip6_config_path)
        ip4AddressData = await ip4Config.get_address_data()
        ip6AddressData = await ip6Config.get_address_data()
        addresses = combineAddresses(ip4AddressData, ip6AddressData)

    with ui.card().classes("w-full"):
    
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(iface).classes("text-h6")
            ui.label(f"{hwaddr}").classes("text-h6")

            async def connection_sw_cb(e):
                action = "enable" if  e.sender.value else "disable"
                with ui.dialog() as dialog, ui.card():
                    ui.label(f'Are you sure you want to {action} this connection?')
                    with ui.row():
                        ui.button('Cancel', on_click=lambda: dialog.submit("Cancel")).props("flat color=accent align=left")
                        ui.button(f'{action}', on_click=lambda: dialog.submit(action)).props("flat color=accent align=left")
                result = await dialog
                if result == "enable":
                    await nm.call_activate_connection("/", device_path, "/")

                if result == "disable":
                    await nm.call_deactivate_connection(active_connection_path)



            ui.switch("Connected").on('click', lambda e: connection_sw_cb(e)).props("flat color=accent").bind_value_from(BindState, "state", backward= lambda v: v==100)


        ui.separator()
        
        async def autoConnectCallback(e):
            #settings = await GetSettings(device)
            settings['connection']['autoconnect'] = Variant('b', e.value)
            await connection.call_update2(settings, 0x1, {})
            #await device.call_reapply(settings, 0, 0)


        with ui.column().classes("flex-1 gap-4"):  # Fixed width for labels
            with ui.row().classes("flex-1 gap-16"):    
                ui.label("Status").classes("font-bold w-8")
                ui.label(addresses)

            with ui.row().classes("flex-1 gap-16"):    
                ui.label("State").classes("font-bold w-8")
                ui.label(deviceState)
                
            with ui.row().classes("flex-1 gap-16"):
                ui.label("Carrier").classes("font-bold w-8")
                ui.label(f"{carrier}")
                
            with ui.row().classes("flex-1 gap-16"):
                ui.label("General").classes("font-bold w-8")
                
                ui.checkbox('Connect automatically', on_change=autoConnectCallback).props(
                    "flat color=accent").props(
                            "dense").bind_value(autoconnect, "auto")
      
            
            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv4").classes("font-bold w-8")
                ui.label(addressDataToString(ip4AddressData))                
                ui.label("Edit").classes("text-accent cursor-pointer hover:underline").on('click', lambda: edit_ip4_connection(device))

                

            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv6").classes("font-bold w-8")
                ui.label(addressDataToString(ip6AddressData))
                ui.label("Edit").classes("text-accent cursor-pointer hover:underline").on('click', lambda: edit_ip4_connection(device))
    with ui.card():
        ui.label("SETTINGS JSON: ").classes("h5-text")
        with ui.row().classes("w-full"):
            ui.json_editor({'content': {'json': settings_to_dict(settings)}} ).classes("w-full")
        #terminal = ui.xterm()
        #ui.timer(0, lambda: terminal.write(str(settings)), once=True)


def settings_to_dict(obj):
    """Recursively convert dbus_next Variant objects to Python types."""
    
    # Handle Variant objects
    if isinstance(obj, Variant):
        return settings_to_dict(obj.value)
    
    # Handle dictionaries
    elif isinstance(obj, dict):
        return {key: settings_to_dict(val) for key, val in obj.items()}
    
    # Handle lists
    elif isinstance(obj, list):
        return [settings_to_dict(item) for item in obj]
    
    # Handle tuples (like in the 'addresses' field)
    elif isinstance(obj, tuple):
        return tuple(settings_to_dict(item) for item in obj)
    
    # Base case: return the object as-is (str, int, bool, bytes, etc.)
    else:
        return obj

async def edit_ip4_connection(device: ProxyInterface):

    settings = await GetSettings(device)

    ipv4 = Ip4(

    )

    ipv4.AddressData = GetIp4Addresses(settings)

    ipv4.Addresses = None
    ipv4.Dns
    ipv4.DnsData
    ipv4.DnsSearch
    ipv4.Gateway
    ipv4.IgnoreAutoDns
    ipv4.IgnoreAutoRoutes
    ipv4.Method
    ipv4.RouteData
    ipv4.Routes

    connection = await GetConnectionFromDevice(device)

    method = GetIp4Method(settings)
    gateway = GetIp4Gateway(settings)
    addresses = GetIp4Addresses(settings)
    dnsServers = GetIp4DnsServers(settings)
    dnsSearches = GetIp4DnsSearches(settings)
    routes = GetIp4Routes(settings)
    dnsMethod = GetIp4DnsMethod(settings)
    routeMethod = GetIp4RouteMethod(settings)


    def add_ip_address(a:str=None, p:str=None, g:str=None):
        addr = Ip4Address(a, p)
        addresses.append(addr)
        ip_address_list.refresh()

    def remove_ip_address(addr):
        addresses.remove(addr)
        ip_address_list.refresh()


    def add_dns_server(dns :str=None):
        dnsServers.append(Ip4DnsServer(dns))
        dns_server_list.refresh()

    def remove_dns_server(dns):
        dnsServers.remove(dns)
        dns_server_list.refresh()


    def add_dns_search(search :str=None):
        dnsSearches.append(Ip4DnsSearch(search))
        dns_search_list.refresh()

    def remove_dns_search(search):
        dnsSearches.remove(search)
        dns_search_list.refresh()

    
    def add_route(Address :str=None, Prefix :str=None, NextHop :str=None, Metric :str=None):
        routes.append(Ip4Route(Address, Prefix, NextHop, Metric))
        route_list.refresh()
    
    def remove_route(route):
        routes.remove(route)
        route_list.refresh()




    @ui.refreshable
    async def ip_address_list():
        for addr in addresses:
            with ui.row():
                ui.input(label="Address").props("dense").classes("flex-1").bind_value(addr, "Address")
                ui.input(label="Prefix or netmask").props("dense").classes("flex-1").bind_value(addr, "Prefix")
                ui.input(label="Gateway").props("dense").classes("flex-1").bind_value(gateway, "Address")
                ui.button(icon="delete", on_click=lambda a=addr: remove_ip_address(a)).props("flat color=accent").props("dense")
    
    @ui.refreshable
    async def dns_server_list():
        for dns in dnsServers:
            with ui.row():
                ui.input(label="Server").props("dense").classes("flex-1").bind_value(dns, "Server")
                ui.button(icon="delete", on_click=lambda d=dns: remove_dns_server(d)).props("flat color=accent").props("dense")
    
    @ui.refreshable
    async def dns_search_list():
        for search in dnsSearches:
            with ui.row():
                ui.input(label="Server").props("dense").classes("flex-1").bind_value(search, "Search")
                ui.button(icon="delete", on_click=lambda d=search: remove_dns_search(d)).props("flat color=accent").props("dense")
    
    @ui.refreshable
    async def route_list():
        for route in routes:
            with ui.row():
                ui.input(label="Server").props("dense").classes("flex-1").bind_value(route, "Dest")
                ui.input(label="Prefix or netmask").props("dense").classes("flex-1").bind_value(route, "Prefix")
                ui.input(label="Next Hop").props("dense").classes("flex-1").bind_value(route, "NextHop")
                ui.input(label="Metric").props("dense").classes("flex-1").bind_value(route, "Metric")

                ui.button(icon="delete", on_click=lambda d=route: remove_route(d)).props("flat color=accent").props("dense")


    ###
    with ui.dialog() as dialog:
        with ui.card().classes("w-full self-start max-h-[90vh] overflow-y-auto"):
            ui.label("IPv4 settings").classes("text-h5")
            with ui.column().classes("w-full"):

                ### ADDRESSES
                with ui.row().classes("w-full justify-between"):  
                    ui.label("Addresses")
                    with ui.row():

                        def on_method_change(e):
                            SetIp4Method(settings, e.value)

                        ui.select(options=["disabled", "auto", "manual"], on_change=on_method_change).props("dense").classes("w-24").bind_value(method, "Method")

                        ip_address_button = ui.button( icon="add", on_click=add_ip_address).props("flat color=accent").props("dense")
                        
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await ip_address_list()
                    print()
                ###

                ### DNS SERVER
                ui.separator()
                with ui.row().classes("w-full justify-between"):
                    ui.label("DNS Servers")
                    with ui.row():
                        dns_server_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24").bind_value(dnsMethod, "Auto")
                        dns_server_button = ui.button(
                            icon="add",
                            on_click=add_dns_server,
                        ).props("flat color=accent").props("dense")
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await dns_server_list()
                ###

                ### DNS SEARCH
                ui.separator()
                with ui.row().classes("w-full justify-between"):
                    ui.label("DNS Searches")
                    with ui.row():
                        dns_search_button = ui.button(
                            icon="add",
                            on_click=add_dns_search,
                        ).props("flat color=accent").props("dense")
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await dns_search_list()
                ###

                ### ROUTES
                ui.separator()
                with ui.row().classes("w-full justify-between"):
                    ui.label("Routes")
                    with ui.row():
                        route_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24").bind_value(routeMethod, "Auto")
                        route_button = ui.button(icon="add", on_click=add_route).props("flat color=accent").props("dense")
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await route_list()
                ###

                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    async def on_save_cb():

                        try:

                            apply_settings(settings)

                            try:
                                await connection.call_update2(settings, 0x1, {})
                                await device.call_reapply(settings, 0, 0)

                            except DBusError as e:
                                ui.notify(e, type='negative')


                            print("FINAL SETTINGS")
                            pprint(settings)

            
                            dialog.close()
                        except Exception as e:
                            print(e)
                            ui.notify("Please correct the errors", type='negative')

                    def on_cancel_cb():
                        dialog.close()

                    save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                    cancel_button = ui.button("cancel", on_click=on_cancel_cb).props("flat color=accent align=left")
    await dialog
