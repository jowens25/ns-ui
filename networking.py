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

async def GetDevices(nm: Proxy) -> list[str]:
    return (await nm.GetDevices())[0]


async def GetInterface(device :Proxy) -> str:
    return (await device.get("Interface"))[0][1]


def formatAddress(addressData: dict)-> list[str]:
    addresses = []
    for address in addressData:
        addr = address.get("address")[1]
        prefix = address.get("prefix")[1]
        addresses.append(f"{addr}/{prefix}")
    return addresses

def formatAddressString(addresses: list[str]) -> str:
    return ', '.join(addresses) if addresses else ' '

def formatInterfaceRow(interface :str, addresses: str):
    return {"name": interface, "addresses": addresses}


def addressDataToString(addressData):
    addresses = []
    addresses.extend(formatAddress(addressData))
    return formatAddressString(addresses)



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


def combineAddresses(ip4configProps: IP4ConfigProperties, ip6configProps: IP6ConfigProperties) -> str:
    
    addresses = []
    addresses.extend(formatAddress(ip4configProps.AddressData))
    addresses.extend(formatAddress(ip6configProps.AddressData))
    return formatAddressString(addresses)


async def GetInterfacesAndAddresses() -> list:

    rows = []
    
    networkManager = Proxy(NetworkManager(), dbus.Router)
    networkManagerProperties = NetworkManagerProperties((await networkManager.get_all())[0])
    
    for devicePath in networkManagerProperties.Devices:
    
        device = Proxy(Device(devicePath), dbus.Router)
        deviceProperties = DeviceProperties((await device.get_all())[0])

        
        
        #print(devicePath)
        #pprint(asdict(deviceProperties))
        
        if len(deviceProperties.Ip6Config) > 1 and len(deviceProperties.Ip4Config) >1:
        
            ip4config = Proxy(IP4Config(deviceProperties.Ip4Config), dbus.Router)
            ip4configProperties = IP4ConfigProperties((await ip4config.get_all())[0])

            ip6config = Proxy(IP6Config(deviceProperties.Ip6Config), dbus.Router)
            ip6configProperties = IP6ConfigProperties((await ip6config.get_all())[0])

            rows.append({'name': deviceProperties.Interface,'addresses': 
                combineAddresses(ip4configProperties, ip6configProperties)})
        
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




        

async def interface_card(iface :str ):
    
    networkManager = Proxy(NetworkManager(), dbus.Router)
    networkManagerProperties = NetworkManagerProperties((await networkManager.get_all())[0])
    devicePath = (await networkManager.GetDeviceByIpIface(iface))[0]
    
    device = Proxy(Device(devicePath), dbus.Router)    
    deviceProperties = DeviceProperties((await device.get_all())[0])
    
    speed = 0
    if deviceProperties.DeviceType == 1: # ethernet
        wired = Proxy(Wired(devicePath), dbus.Router)
        speed = (await wired.get("Speed"))[0][1]
    

    ip4config = Proxy(IP4Config(deviceProperties.Ip4Config), dbus.Router)
    ip4configProperties = IP4ConfigProperties((await ip4config.get_all())[0])
    
    
    ip6config = Proxy(IP6Config(deviceProperties.Ip6Config), dbus.Router)
    ip6configProperties = IP6ConfigProperties((await ip6config.get_all())[0])

    
    addresses = combineAddresses(ip4configProperties, ip6configProperties)
    
    
    hwaddr = deviceProperties.HwAddress

    carrier = processInterfaceFlags((await device.get("InterfaceFlags"))[0][1])
    



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
                    await networkManager.ActivateConnection(deviceProperties.ActiveConnection, devicePath, "/")
                if result == "disable":
                    await networkManager.DeactivateConnection(deviceProperties.ActiveConnection)

            ui.switch("Connected").on('click', lambda e: connection_sw_cb(e)).props("flat color=accent").bind_value_from(deviceProperties, "State", backward= lambda v: v==100)
            #print(deviceProperties.State)

        ui.separator()
        
        async def autoConnectCallback():
            await device.set("Autoconnect", 'b', deviceProperties.Autoconnect)

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
                            "dense").bind_value(deviceProperties, 'Autoconnect')
            
            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv4").classes("font-bold w-8")
                ui.label(addressDataToString(ip4configProperties.AddressData))
                

            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv6").classes("font-bold w-8")
                ui.label(addressDataToString(ip6configProperties.AddressData))
                
            with ui.row().classes("flex-1 gap-16"):
                ui.button("Edit", on_click=edit_connection).props("flat color=accent")
                
                






def edit_connection():
    
    
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
    
    def add_ip_address_box():
        with address_section:
            with ui.row() as ip_box:
                ui.input(label="Address").props("dense").classes("flex-1")
                ui.input(label="Prefix or netmask").props("dense").classes("flex-1")
                ui.input(label="Gateway").props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda: remove_ip_address_box(ip_box)).props("flat color=accent").props("dense")
                
    def add_dns_server():
        with dns_section:
            with ui.row() as dns_box:
                ui.input(label="Server").props("dense").classes("flex-1")
                ui.button(icon="delete", on_click=lambda: remove_dns_server_box( dns_box)).props("flat color=accent").props("dense")
                
    def add_dns_search():
        with dns_search_section:
            with ui.row() as dns_search_box:
                ui.input(label="Search domain").props("dense").classes("flex-1")
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
                ## DNS
                #with ui.row().classes("w-full items-center justify-between"):
                #    ui.label("DNS")
                #    ui.switch().props("flat color=accent").props("align=right")
                #    ui.button(icon="add", on_click=add_ip_address_box).props("flat color=accent").props("align=right")
                #    
                #ui.separator()
                ## DNS search
                #with ui.row().classes("w-full justify-between"):
                #    ui.label("DNS search domains")
                #    ui.switch().props("flat color=accent")
                #    ui.button(icon="add", on_click=add_ip_address_box).props("flat color=accent")
                #    
                #ui.separator()
                ## Routes 
                #with ui.row().classes("w-full items-center justify-between"):
                #    ui.label("Routes")
                #    ui.switch().props("flat color=accent")
                #    ui.button(icon="add", on_click=add_ip_address_box).props("flat color=accent")
                
              
                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    def on_save_cb():

                
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
