from dataclasses import asdict
from pprint import pprint
from nicegui import ui, app
from org_freedesktop_NetworkManager_IP6Config import IP6Config, IP6ConfigProperties
from theme import init_colors
from rest_api import APIClient

from org_freedesktop_NetworkManager import NetworkManager, NetworkManagerProperties
from org_freedesktop_NetworkManager_Device import Device, DeviceProperties, Statistics, Wired
from org_freedesktop_NetworkManager_IP4Config import IP4Config, IP4ConfigProperties
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Settings_Connection import Connection, ConnectionProperties
from org_freedesktop_NetworkManager_Settings import Settings, SettingsProperties
from dbus_next.signature import Variant, SignatureTree, SignatureType

from org_freedesktop_NetworkManager_ActiveConnection import ActiveConnection, ActiveConnectionProperties
from jeepney.wrappers import Properties
from jeepney.io.asyncio import Proxy

from dbus_next import BusType
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
        current_settings = await connection.call_get_settings()

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
                ui.button("Edit", on_click=lambda: edit_connection(current_settings)).props("flat color=accent")
                
                


class Ip4Address:
    def __init__(self, a, p, g):
        with ui.row() as ip_box:
            self.address = ui.input(label="Address", value=a).props("dense").classes("flex-1")
            self.prefix = ui.input(label="Prefix", value=p).props("dense").classes("flex-1")
            self.gateway = ui.input(label="Gateway", value=g).props("dense").classes("flex-1")

    def to_dbus(self):
        addressDataEntry = Variant('aa{sv}', [
            {
                'address': Variant('s', self.address.value),
                'prefix': Variant('u', self.prefix.value)
            }
        ])
        return addressDataEntry

#class Ip4AddressSection:
#
#    def __init__(self, settings):
#        self.settings = settings
#        self.ipv4 = self.settings.get('ipv4')
#        self.section = None
#        self.addresses = []
#
#        self.get_address()
#
#    def build(self):
#        self.section = ui.column().classes("items-center justify-between gap-4 w-full")
#        return self.section
#    
#    def build_addresses(self):
#        with self.section:
#            for addr in self.addresses:
#                with ui.row():
#                    addr
#
#    def get_address(self):
#        addrData = self.ipv4.get('address-data')
#        if addrData:
#            g = self.ipv4.get('gateway').value if self.ipv4.get('gateway') else ''
#            for addr in addrData.value:
#                a = addr.get('address').value
#                p = addr.get('prefix').value
#                self.addresses.append(Ip4Address(a,p,g))
#            return 
#
#    def load_addresses_from_card():
#        return
#    
#    def display_addresses():
#        return
#    
#
#    #def load_ip4_addresses(self):
#    #       addrData = self.ipv4.get('address-data').value
##
#    #       for addr in addrData:
#    #           print(addr)
#    #           a = addr.get('address').value
#    #           p = addr.get('prefix').value
#    #           g = self.ipv4.get('gateway').value
#    #           self.add_ip_address_box(a,p,g)
##
#    #def show_ip4_addresses(self):
##
##
#    def add_ip_address_box(self, a:str=None, p:str=None, g:str=None):
#        with self.section:
#            with ui.row() as ip_box:
#                #self.addresses
#                #ui.input(label="Address", value=a).props("dense").classes("flex-1")
#                #ui.input(label="Prefix", value=p).props("dense").classes("flex-1")
#                #ui.input(label="Gateway", value=g).props("dense").classes("flex-1")
#                ui.button(icon="delete", on_click=lambda: self.remove_ip_address_box(ip_box)).props("flat color=accent").props("dense")
#            #ui_addresses.append(ip_box)
##
    #def remove_ip_address_box(self, item):
    #    self.section.remove(item)
#
    #def write_addresses_to_connection(self):
    #    for addr in self.addresses:
    #        print() #self.settings['ipv4']['address-data'] = 



def edit_connection(settings :dict):


    def get_ip4_mode(settings :dict):
        


    ui_addresses = []


    def load_ip4_addresses(settings :dict):
           ipv4 = settings.get('ipv4')
           addrData = ipv4.get('address-data').value

           gw = ipv4.get('gateway').value if ipv4.get('gateway') else ''


           for addr in addrData:
               a = addr.get('address').value
               p = addr.get('prefix').value
               g = gw
               add_ip_address_box(a,p,g)
    
    def load_ip4_dns(settings :dict):
        ipv4 = settings.get('ipv4')
        dnsData = ipv4.get('dns-data')
        if dnsData:
            for dns in dnsData.value:
                add_dns_server(dns)

    def load_ip4_dns_search(settings :dict):
        ipv4 = settings.get('ipv4')
        dnsSearch = ipv4.get('dns-search')
        if dnsSearch:
            for dns in dnsSearch.value:
                add_dns_search(dns)

    
    pprint(settings)
    def on_mode_change(e):
        print("did it work?")
        #match e.value:
        #    case "Disabled":                
        #        ip_address_button.disable()
        #        dns_switch.disable()
        #        dns_button.disable()
        #        search_switch.disable()
        #        search_button.disable()
        #        route_switch.disable()
        #        route_button.disable()
        #        dns_switch.value = False
        #        search_switch.value = False
        #        route_switch.value = False
        #        
        #    case "Automatic":
        #        ip_address_button.enable()
        #        dns_switch.enable()
        #        dns_button.enable()
        #        search_switch.enable()
        #        search_button.enable()
        #        route_switch.enable()
        #        route_button.enable()
        #        
        #        dns_switch.value = True
        #        search_switch.value = True
        #        route_switch.value = True
        #        
        #    case "Shared":
        #        ip_address_button.disable()
        #        dns_switch.disable()
        #        dns_button.disable()
        #        search_switch.disable()
        #        search_button.disable()
        #        route_switch.disable()
        #        route_button.enable()
        #    
        #    case _:
        #        print("default")
            
    
    def remove_ip_address_box(item):
        address_section.remove(item)
        
    def remove_dns_server_box(item):
        dns_section.remove(item)
        
    def remove_dns_search_box(item):
        dns_search_section.remove(item)
    
    def remove_route_box(item):
        route_section.remove(item)



    
    def add_ip_address_box(a:str=None, p:str=None, g:str=None):
        with address_section:
            with ui.row() as ip_box:
                ui.input(label="Address", value=a).props("dense").classes("flex-1")
                ui.input(label="Prefix", value=p).props("dense").classes("flex-1")
                ui.input(label="Gateway", value=g).props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda: remove_ip_address_box(ip_box)).props("flat color=accent").props("dense")
            ui_addresses.append(ip_box)

    def add_dns_server(s:str=None):
        with dns_section:
            with ui.row() as dns_box:
                ui.input(label="Server", value=s).props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda: remove_dns_server_box( dns_box)).props("flat color=accent").props("dense")
                
    def add_dns_search(s:str=None):
        with dns_search_section:
            with ui.row() as dns_search_box:
                ui.input(label="Search domain", value=s).props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda: remove_dns_search_box( dns_search_box)).props("flat color=accent").props("dense")  
                       
    def add_route():
        with route_section:
            with ui.row() as route_box:
                ui.input(label="Address").props("dense").classes("flex-1")
                ui.input(label="Prefix or netmask").props("dense").classes("flex-1")
                ui.input(label="Gateway").props("dense").classes("flex-1")
                ui.input(label="Metric").props("dense").classes("flex-1")

                ui.button(icon="delete", on_click=lambda: remove_route_box(route_box)).props("flat color=accent").props("dense")
                
    

    with ui.dialog() as dialog:
        with ui.card().classes("w-full self-start max-h-[90vh] overflow-y-auto"):
            ui.label("IPv4 settings").classes("text-h5")
            with ui.column().classes("w-full"):
                with ui.row().classes("w-full justify-between"):
                    ui.label("Addresses")

                    with ui.row():
                        address_mode = ui.select(
                            options=["Automatic", "Link Local", "Manual", "Shared", "Disabled"], 
                            on_change=on_mode_change ,value="Automatic").props("dense").classes("w-24")
                                        

                        ip_address_button = ui.button(
                            icon="add",
                            on_click=add_ip_address_box,
                        ).props("flat color=accent").props("dense")
                    

                address_section = ui.column().classes("items-center justify-between gap-4 w-full")

                load_ip4_addresses(settings)

                ui.separator()
                
                with ui.row().classes("w-full justify-between"):
                    ui.label("DNS")
                    with ui.row():
                        #ui.select(options=["Automatic", "Manual"], value="Automatic").props("dense").classes("w-24")
                        dns_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24")
                        dns_button = ui.button(
                            icon="add",
                            on_click=add_dns_server,
                        ).props("flat color=accent").props("dense")
                dns_section = ui.column().classes("items-center justify-between gap-4 w-full")
                load_ip4_dns(settings)
                ui.separator()
                
                with ui.row().classes("w-full justify-between"):
                    ui.label("DNS search domains")
                    with ui.row():
                        #ui.select(options=["Automatic", "Manual"], value="Automatic").props("dense").classes("w-24")
                        search_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24")
                        search_button = ui.button(
                            icon="add",
                            on_click=add_dns_search,
                        ).props("flat color=accent").props("dense")
                dns_search_section = ui.column().classes("items-center justify-between gap-4 w-full")
                load_ip4_dns_search(settings)
                ui.separator()
                
                
                with ui.row().classes("w-full justify-between"):
                    ui.label("Routes")
                    with ui.row():
                        #ui.select(options=["Automatic", "Manual"], value="Automatic").props("dense").classes("w-24")
                        route_switch = ui.switch("Automatic").props("flat color=accent").props("dense").classes("w-24")
                        route_button = ui.button(
                            icon="add",
                            on_click=add_route,
                        ).props("flat color=accent").props("dense")
                route_section = ui.column().classes("items-center justify-between gap-4 w-full")
                ui.separator()

                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    def on_save_cb():

                        print(ui_addresses)
                
                        if True:
                            #AddV3User(user)
                            dialog.close()
                        else:
                            ui.notify("Please correct the errors", type='negative')

                    def on_cancel_cb():
                        dialog.close()

                    save_button = ui.button("save", on_click= on_save_cb).props("flat color=accent align=left") 
                    cancel_button = ui.button("cancel", on_click=on_cancel_cb).props("flat color=accent align=left")
    return dialog
