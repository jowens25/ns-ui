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
    with ui.row():
        ui.link('Networking', '/networking')
        ui.label('>')
        ui.label(interface_name)
        await interface_card(interface_name)


async def interface_card(iface :str):


    nm = GetNetworkManager(dbus.Bus)

    device_path = await nm.call_get_device_by_ip_iface(iface)
    device = GetDevice(dbus.Bus, device_path)

    hwaddr = await device.get_hw_address()
    flags = await device.get_interface_flags()
    carrier = processInterfaceFlags(flags)

    autoConnect = await device.get_autoconnect()
    state = await device.get_state()
    deviceState = processDeviceState(state)
    ip4_config_path = await device.get_ip4_config()
    ip6_config_path = await device.get_ip6_config()
    active_connection_path = await device.get_active_connection()

    dev = Device(autoConnect, state)

    if len(ip4_config_path) > 1:
        ip4Config = GetIp4Config(dbus.Bus, ip4_config_path)
        ip6Config = GetIp6Config(dbus.Bus, ip6_config_path)
        ip4AddressData = await ip4Config.get_address_data()
        ip6AddressData = await ip6Config.get_address_data()
        addresses = combineAddresses(ip4AddressData, ip6AddressData)


    with ui.card().classes("w-full"):
        # Header row
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

            
            ui.switch("Connected").on('click', lambda e: connection_sw_cb(e)).props("flat color=accent").bind_value_from(dev, "State", backward= lambda v: v==100)
            print(dev.State)

        ui.separator()
        
        async def autoConnectCallback(e):
            dev.AutoConnect = e.value
            print(dev.AutoConnect)
            await device.set_autoconnect(dev.AutoConnect)
            print(dev.AutoConnect)
            #await asyncio.sleep(1)
            dev.AutoConnect = await device.get_autoconnect()
            print(dev.AutoConnect)

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
                            "dense").bind_value(dev, "AutoConnect")
            
            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv4").classes("font-bold w-8")
                ui.label(addressDataToString(ip4AddressData))                
                ui.label("Edit").classes("text-accent cursor-pointer hover:underline").on('click', lambda: edit_connection(device))

                

            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv6").classes("font-bold w-8")
                ui.label(addressDataToString(ip6AddressData))
                ui.label("Edit").classes("text-accent cursor-pointer hover:underline").on('click', lambda: edit_connection(device))

                
                

async def edit_connection(device: ProxyInterface):


    ip6Addresses: List[Ipv6Address] = []
   
    settings = await GetSettings(device)
    connection = await GetConnectionFromDevice(device)

    ip4Addresses = await GetIp4Addresses(settings)
    ip4Gateway = GetIp4Gateway(settings)

    #dnsServers: List[str] = []
    #dnsSearch: List[str] = []

    def add_ip_address(a:str=None, p:str=None, g:str=None):
        addr = Ip4Address(a, p)
        ip4Addresses.append(addr)
        ip_address_list.refresh()

    def remove_ip_address(addr):
        ip4Addresses.remove(addr)
        ip_address_list.refresh()

    def get_ip4_method():
        ipv4 = settings.get('ipv4')
        method = ipv4.get('method')
        if method:
            return method.value
        else:
            return ''
    
    def set_ip4_method(method):
        options=["disabled", "auto", "manual", "link-local"]
        if method in options:
            settings['ipv4']['method'] = Variant('s', method)


    @ui.refreshable
    async def ip_address_list():
        for addr in ip4Addresses:
            with ui.row():
                ui.input(label="Address").props("dense").classes("flex-1").bind_value(addr, "Address")
                ui.input(label="Prefix or netmask").props("dense").classes("flex-1").bind_value(addr, "Prefix")
                ui.input(label="Gateway",value=ip4Gateway).props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda a=addr: remove_ip_address(a)).props("flat color=accent").props("dense")
    
    @ui.refreshable
    async def dns_list():
        for dns in ip4Addresses:
            with ui.row():
                ui.input(label="Address").props("dense").classes("flex-1").bind_value(addr, "Address")
                ui.input(label="Gateway",value=settings['ipv4']['gateway'].value).props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda a=addr: remove_ip_address(a)).props("flat color=accent").props("dense")
    


    #def load_ip4_dns(settings :dict):
    #    ipv4 = settings.get('ipv4')
    #    dnsData = ipv4.get('dns-data')
    #    if dnsData:
    #        for dns in dnsData.value:
    #            dnsServers.append(dns)
    #    dns_server_list.refresh()
#
    #@ui.refreshable
    #def dns_server_list():
    #    with dns_section:
    #        for dns in dnsServers:
    #            with ui.row():
    #                ui.input(label="Server").props("dense").classes("flex-1").bind_value(dns, "Server")
    #                ui.button(icon="delete", on_click=lambda: remove_dns_server_box(dns)).props("flat color=accent").props("dense")
#
#
    #def load_ip4_dns_search(settings :dict):
    #    ipv4 = settings.get('ipv4')
    #    dnsSearch = ipv4.get('dns-search')
    #    if dnsSearch:
    #        for dns in dnsSearch.value:
    #            add_dns_search(dns)

    #
    def on_method_change(e):
    #    match e.value:
    #        case "disabled":                
    #            ip_address_button.disable()
    #            dns_switch.disable()
    #            dns_button.disable()
    #            search_switch.disable()
    #            search_button.disable()
    #            route_switch.disable()
    #            route_button.disable()
    #            dns_switch.value = False
    #            search_switch.value = False
    #            route_switch.value = False
    #            
    #        case "auto":
    #            ip_address_button.enable()
    #            dns_switch.enable()
    #            dns_button.enable()
    #            search_switch.enable()
    #            search_button.enable()
    #            route_switch.enable()
    #            route_button.enable()
    #            
    #            dns_switch.value = True
    #            search_switch.value = True
    #            route_switch.value = True
    #            
    #        case "manual":
    #            ip_address_button.enable()
    #            dns_switch.disable()
    #            dns_button.enable()
    #            search_switch.disable()
    #            search_button.enable()
    #            route_switch.disable()
    #            route_button.enable()
    #            
    #            dns_switch.value = False
    #            search_switch.value = False
    #            route_switch.value = False
#
    #        case "link-local":
    #            ip_address_button.disable()
    #            dns_switch.disable()
    #            dns_button.disable()
    #            search_switch.disable()
    #            search_button.disable()
    #            route_switch.disable()
    #            route_button.enable()
    #            
    #            dns_switch.value = False
    #            search_switch.value = False
    #            route_switch.value = False
#
    #        
    #        case _:
    #            print("default")
#
        SetIp4Method(settings, e.value)
#

    
    #def remove_dns_server_box(item):
    #    dns_section.remove(item)
    #    
    #def remove_dns_search_box(item):
    #    dns_search_section.remove(item)
    #
    #def remove_route_box(item):
    #    route_section.remove(item)


    #def add_dns_server(s:str=None):
    #    server = DnsServer(s)
    #    with dns_section:
    #        with ui.row() as dns_box:
    #            ui.input(label="Server").props("dense").classes("flex-1").bind_value(server, "Server")
    #            ui.button(icon="delete", on_click=lambda: remove_dns_server_box( dns_box)).props("flat color=accent").props("dense")
    #            
    #def add_dns_search(s:str=None):
    #    with dns_search_section:
    #        with ui.row() as dns_search_box:
    #            ui.input(label="Search domain", value=s).props("dense").classes("flex-1")
    #            ui.button(icon="delete", on_click=lambda: remove_dns_search_box( dns_search_box)).props("flat color=accent").props("dense")  
    #                   
    #def add_route():
    #    with route_section:
    #        with ui.row() as route_box:
    #            ui.input(label="Address").props("dense").classes("flex-1")
    #            ui.input(label="Prefix or netmask").props("dense").classes("flex-1")
    #            ui.input(label="Gateway").props("dense").classes("flex-1")
    #            ui.input(label="Metric").props("dense").classes("flex-1")
#
    #            ui.button(icon="delete", on_click=lambda: remove_route_box(route_box)).props("flat color=accent").props("dense")
                
    

    with ui.dialog() as dialog:
        with ui.card().classes("w-full self-start max-h-[90vh] overflow-y-auto"):
            ui.label("IPv4 settings").classes("text-h5")
            with ui.column().classes("w-full"):
                with ui.row().classes("w-full justify-between"):
                    ui.label("Addresses")

                    with ui.row():
                        address_mode = ui.select(
                            options=["disabled", "auto", "manual"], 
                            on_change=on_method_change).props("dense").classes("w-24")
                            #on_change=print("nothing")).props("dense").classes("w-24")


                        ip_address_button = ui.button(
                            icon="add",
                            on_click=add_ip_address,
                        ).props("flat color=accent").props("dense")
                        
                address_section = ui.column().classes("items-center justify-between gap-4 w-full")
                await ip_address_list()


                #conn = Connection(Autoconnect=True)
#
                #conn.to_dbus()
               
                ui.separator()
                
                #with ui.row().classes("w-full justify-between"):
                #    ui.label("DNS")
                #    with ui.row():
                #        #ui.select(options=["Automatic", "Manual"], value="Automatic").props("dense").classes("w-24")
                #        dns_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24")
                #        dns_button = ui.button(
                #            icon="add",
                #            on_click=add_dns_server,
                #        ).props("flat color=accent").props("dense")
                #dns_section = ui.column().classes("items-center justify-between gap-4 w-full")
                #ui.separator()
                #
                #with ui.row().classes("w-full justify-between"):
                #    ui.label("DNS search domains")
                #    with ui.row():
                #        #ui.select(options=["Automatic", "Manual"], value="Automatic").props("dense").classes("w-24")
                #        search_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24")
                #        search_button = ui.button(
                #            icon="add",
                #            on_click=add_dns_search,
                #        ).props("flat color=accent").props("dense")
                #dns_search_section = ui.column().classes("items-center justify-between gap-4 w-full")
                #ui.separator()
                
                
                #with ui.row().classes("w-full justify-between"):
                #    ui.label("Routes")
                #    with ui.row():
                #        #ui.select(options=["Automatic", "Manual"], value="Automatic").props("dense").classes("w-24")
                #        route_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24")
                #        route_button = ui.button(
                #            icon="add",
                #            on_click=add_route,
                #        ).props("flat color=accent").props("dense")
                #route_section = ui.column().classes("items-center justify-between gap-4 w-full")
                #ui.separator()

                #load_ip4_addresses(settings)

                #load_ip4_dns(settings)
#
                #load_ip4_dns_search(settings)

                #print(settings['ipv4']['dns-data'])

                address_mode.value = GetIp4Method(settings)                           

                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    async def on_save_cb():

                        if True:

                            if address_mode.value == 'auto':
                                settings['ipv4']['method'] = ipv4_method_to_dbus(address_mode.value)
                                settings['ipv4'].pop('address-data', None)
                                settings['ipv4'].pop('routes', None)
                                settings['ipv4'].pop('addresses', None)
                                settings['ipv4'].pop('gateway', None)

                            
                            if address_mode.value == 'manual':
                                settings['ipv4']['method'] = ipv4_method_to_dbus(address_mode.value)
                                settings['ipv4']['gateway'] = ip4_gateway_to_dbus(ip4Gateway)
                                settings['ipv4']['address-data'] = ip4_addresses_to_dbus(ip4Addresses)
                                settings['ipv4'].pop('addresses', None)
                                settings['ipv4'].pop('routes', None)

                            if address_mode.value == 'disabled':
                                settings['ipv4']['method'] = ipv4_method_to_dbus(address_mode.value)
                                settings['ipv4'].pop('address-data', None)
                                settings['ipv4'].pop('routes', None)
                                settings['ipv4'].pop('addresses', None)
                                settings['ipv4'].pop('gateway', None)
                                settings['ipv4'].pop('dns-data', None)
                                settings['ipv4'].pop('dns-search', None)
                                settings['ipv4'].pop('route-data', None)
                                settings['ipv4'].pop('dns', None)

                            try:
                                await connection.call_update2(settings, 0x1, {})
                                await device.call_reapply(settings, 0, 0)

                            except DBusError as e:
                                ui.notify(e, type='negative')


                            print("FINAL SETTINGS")
                            pprint(settings)

            
                            #AddV3User(user)
                            dialog.close()
                        else:
                            ui.notify("Please correct the errors", type='negative')

                    def on_cancel_cb():
                        dialog.close()

                    save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                    cancel_button = ui.button("cancel", on_click=on_cancel_cb).props("flat color=accent align=left")
    await dialog
