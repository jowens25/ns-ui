from dataclasses import asdict
from pprint import pprint
from typing import List, Optional
from nicegui import ui, app, binding
from theme import init_colors
from rest_api import APIClient


from dbus_next.signature import Variant
from dbus_next.errors import DBusError
from dbus_next.aio.proxy_object import ProxyInterface
from dbus_next.aio import MessageBus
from dbus import dbus


def GetNetworkManager(bus: MessageBus):
    file_name = 'org.freedesktop.NetworkManager.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager', introspection)
    return obj.get_interface('org.freedesktop.NetworkManager')

def GetDevice(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Device.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Device')


def GetActiveConnection(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Connection.Active.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Connection.Active')


def GetIp4Config(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.IP4Config.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.IP4Config')

def GetIp6Config(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.IP6Config.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.IP6Config')


def GetSettingsManager(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Settings.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Settings')

def GetConnection(bus: MessageBus, path : str):
    file_name = 'org.freedesktop.NetworkManager.Settings.Connection.xml'
    with open("introspection/"+file_name, "r") as f:
        introspection = f.read()
    obj = bus.get_proxy_object('org.freedesktop.NetworkManager', path, introspection)
    return obj.get_interface('org.freedesktop.NetworkManager.Settings.Connection')



def addressDataToAddress(addressdata: list[dict]) -> list:
    formatted = []
    for addr in addressdata:
        address = addr.get('address')
        prefix = addr.get('prefix')
        if address and prefix:
            formatted.append(f"{address.value}/{prefix.value}")
    return formatted


def formatAddressString(addresses: list[str]) -> str:
    return ', '.join(addresses) if addresses else ' '

def formatInterfaceRow(interface :str, addresses: str):
    return {"name": interface, "addresses": addresses}


def addressDataToString(addressData):
    addresses = []
    addresses.extend(addressDataToAddress(addressData))
    return formatAddressString(addresses)

def dnsDataToString(dnsData):
    return formatAddressString(dnsData)


def processInterfaceFlags(flags: int) -> str:
    NM_DEVICE_INTERFACE_FLAG_NONE= 0 # an alias for numeric zero, no flags set. 
    NM_DEVICE_INTERFACE_FLAG_UP= 0x1 # the interface is enabled from the administrative point of view. Corresponds to kernel IFF_UP. 
    NM_DEVICE_INTERFACE_FLAG_LOWER_UP= 0x2 # the physical link is up. Corresponds to kernel IFF_LOWER_UP. 
    NM_DEVICE_INTERFACE_FLAG_PROMISC= 0x4 # receive all packets. Corresponds to kernel IFF_PROMISC. Since: 1.32. 
    NM_DEVICE_INTERFACE_FLAG_CARRIER= 0x10000 # the interface has carrier. In most cases this is equal to the value of @NM_DEVICE_INTERFACE_FLAG_LOWER_UP. However some devices have a non-standard carrier detection mechanism. 
    NM_DEVICE_INTERFACE_FLAG_LLDP_CLIENT_ENABLED= 0x20000 # the flag to indicate device LLDP status. Since: 1.32.
    """Convert interface flags to detailed status string"""
    
    if flags == 0:
        return "Interface disabled (no flags set)"
    
    status = []
    
    if flags & NM_DEVICE_INTERFACE_FLAG_UP:
        status.append("administratively up")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_LOWER_UP:
        status.append("physical link up")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_CARRIER:
        status.append("carrier detected")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_PROMISC:
        status.append("promiscuous mode")
    
    if flags & NM_DEVICE_INTERFACE_FLAG_LLDP_CLIENT_ENABLED:
        status.append("LLDP enabled")
    
    if not status:
        return f"Unknown flags: 0x{flags:x}"
    
    return " | ".join(status)


def combineAddresses(ipv4AddressData, ipv6AddressData) -> str:
    
    addresses = []
    addresses.extend(addressDataToAddress(ipv4AddressData))
    addresses.extend(addressDataToAddress(ipv6AddressData))
    return formatAddressString(addresses)


async def GetInterfacesAndAddresses() -> list:

    rows = []

    nm = GetNetworkManager(dbus.Bus)
    
    device_paths = await nm.call_get_devices()
    
    for devicePath in device_paths:

        device = GetDevice(dbus.Bus, devicePath)
        interface = await device.get_interface()

        ip4_config_path = await device.get_ip4_config()
        ip6_config_path = await device.get_ip6_config()
        if len(ip4_config_path) > 1:

            ip4Config = GetIp4Config(dbus.Bus, ip4_config_path)
            ip6Config = GetIp6Config(dbus.Bus, ip6_config_path)

            ip4AddressData = await ip4Config.get_address_data()
            ip6AddressData = await ip6Config.get_address_data()
    
            rows.append({'name': interface,'addresses': 
                combineAddresses(ip4AddressData, ip6AddressData)})
        
    return rows


async def on_row_selected(event):
    row = event.args[1] if event.args[1] else None
    if row:
        with ui.dialog() as interface_dialog, ui.card():
            ui.label(f"Interface Details: {row['name']}").classes("text-h6 mb-4")
            await interface_card(row["name"])
            ui.button("Close", on_click=interface_dialog.close).classes("bg-secondary")
        interface_dialog.open()
        

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
    autoConnect = await device.get_autoconnect()
    ip4_config_path = await device.get_ip4_config()
    ip6_config_path = await device.get_ip6_config()
    active_connection_path = await device.get_active_connection()

    carrier = processInterfaceFlags(flags)

    if len(active_connection_path) > 1:
        activeConnection = GetActiveConnection(dbus.Bus, active_connection_path)
        connection_path = await activeConnection.get_connection()
        connection = GetConnection(dbus.Bus, connection_path)
        #current_settings = await connection.call_get_settings()

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
                    #await nm.ActivateConnection(deviceProperties.ActiveConnection, devicePath, "/")
                    print()
                if result == "disable":
                    #await networkManager.DeactivateConnection(deviceProperties.ActiveConnection)
                    print()

            #ui.switch("Connected").on('click', lambda e: connection_sw_cb(e)).props("flat color=accent").bind_value_from(deviceProperties, "State", backward= lambda v: v==100)
            #print(deviceProperties.State)

        ui.separator()
        
        async def autoConnectCallback():
            await device.set("Autoconnect", 'b', autoConnect)

        with ui.column().classes("flex-1 gap-4"):  # Fixed width for labels
            with ui.row().classes("flex-1 gap-16"):    
                ui.label("Status").classes("font-bold w-8")
                ui.label(addresses)
                
            with ui.row().classes("flex-1 gap-16"):
                ui.label("Carrier").classes("font-bold w-8")
                ui.label(f"{carrier}")
                
            with ui.row().classes("flex-1 gap-16"):
                ui.label("General").classes("font-bold w-8")
                ui.checkbox('Connect automatically', on_change=autoConnectCallback).props(
                    "flat color=accent").props(
                            "dense")
            
            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv4").classes("font-bold w-8")
                ui.label(addressDataToString(ip4AddressData))
            
                

            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv6").classes("font-bold w-8")
                ui.label(addressDataToString(ip6AddressData))
                
            with ui.row().classes("flex-1 gap-16"):
                ui.button("Edit", on_click= lambda : edit_connection(device)).props("flat color=accent")
                
                

@binding.bindable_dataclass
class Ip4Address:
    Address: Optional[str] = None
    Prefix: Optional[int] = None

@binding.bindable_dataclass
class DnsServer:
    Server: Optional[str] = None

@binding.bindable_dataclass
class DnsSearch:
    Search: Optional[str] = None

@binding.bindable_dataclass
class Ip4Gateway:
    Address: Optional[str] = ''
    
def ip4_addresses_to_dbus(ip :list[Variant]):
    return Variant('aa{sv}', [{'address': Variant('s', i.Address), 'prefix': Variant('u', int(i.Prefix))} for i in ip])

def dns_servers_to_dbus(servers :list[str]):
    return Variant('as', servers)

def dns_searches_to_dbus(search: list[str]):
    return Variant('as', search)

def ip4_gateway_to_dbus(gw: str):
    return Variant('s', gw.Address)

def ipv4_method_to_dbus(method :str):
    return Variant('s', method)

async def edit_connection(device: ProxyInterface):

    active_connection_path = await device.get_active_connection()

    if len(active_connection_path) > 1:
        activeConnection = GetActiveConnection(dbus.Bus, active_connection_path)
        connection_path = await activeConnection.get_connection()
        connection = GetConnection(dbus.Bus, connection_path)
        settings = await connection.call_get_settings()
    
    print("INITIAL SETTINGS")
    pprint(settings)

    ip4Addresses: List[Ip4Address] = []
    ip4Gateway = Ip4Gateway()

    #dnsServers: List[str] = []
    #dnsSearch: List[str] = []


    def load_ip4_addresses(settings :dict):
        ipv4 = settings.get('ipv4')
        addrData = ipv4.get('address-data').value
        for addr in addrData:
            a = addr.get('address').value
            p = addr.get('prefix').value
            addr = Ip4Address(a, p)
            ip4Addresses.append(addr)
        ip_address_list.refresh()

    def add_ip_address(a:str=None, p:str=None, g:str=None):
        addr = Ip4Address(a, p)
        ip4Addresses.append(addr)
        ip_address_list.refresh()

    def remove_ip_address(addr):
        ip4Addresses.remove(addr)
        ip_address_list.refresh()

    @ui.refreshable
    def ip_address_list():
        for addr in ip4Addresses:
            with ui.row():
                ui.input(label="Address").props("dense").classes("flex-1").bind_value(addr, "Address")
                ui.input(label="Prefix or netmask").props("dense").classes("flex-1").bind_value(addr, "Prefix")
                ui.input(label="Gateway").props("dense").classes("flex-1").bind_value(ip4Gateway, "Address")
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
        set_ip4_method(e.value)
#
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

                ip_address_list()
               
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

                load_ip4_addresses(settings)

                #load_ip4_dns(settings)
#
                #load_ip4_dns_search(settings)

                #print(settings['ipv4']['dns-data'])

                address_mode.value = get_ip4_method()                           


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
