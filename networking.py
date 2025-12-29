from dataclasses import asdict
from pprint import pprint
from nicegui import ui, app
from org_freedesktop_NetworkManager_IP6Config import IP6Config, IP6ConfigProperties
from theme import init_colors
from rest_api import APIClient
from dbus_next.aio import MessageBus
from dbus_next import BusType
from org_freedesktop_NetworkManager import NetworkManager, NetworkManagerProperties
from org_freedesktop_NetworkManager_Device import Device, DeviceProperties, Statistics, Wired
from org_freedesktop_NetworkManager_IP4Config import IP4Config, IP4ConfigProperties
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Settings_Connection import Connection, ConnectionProperties
from org_freedesktop_NetworkManager_Settings import Settings, SettingsProperties

from org_freedesktop_NetworkManager_ActiveConnection import ActiveConnection, ActiveConnectionProperties
from jeepney.wrappers import Properties
from jeepney.io.asyncio import Proxy

from dbus import dbus




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
        
        print(devicePath)
        pprint(asdict(deviceProperties))
        
        if deviceProperties.Ip6Config and deviceProperties.Ip4Config:
        
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
    
    ip4config = Proxy(IP4Config(deviceProperties.Ip4Config), dbus.Router)
    ip4configProperties = IP4ConfigProperties((await ip4config.get_all())[0])
    
    ip6config = Proxy(IP6Config(deviceProperties.Ip6Config), dbus.Router)
    ip6configProperties = IP6ConfigProperties((await ip6config.get_all())[0])

    
    addresses = combineAddresses(ip4configProperties, ip6configProperties)
    
    
    hwaddr = deviceProperties.HwAddress

    carrier = processInterfaceFlags((await device.get("InterfaceFlags"))[0][1])
    
    wired = Proxy(Wired(devicePath), dbus.Router)

    speed = (await wired.get("Speed"))[0][1]
    
    connectAutomatically = deviceProperties.Autoconnect


    #ip4addressString = await GetAddressString(ip4configPath, [])
    #ip6addressString = await GetAddressString([], ip6configPath)



    with ui.card().classes("w-full"):
        # Header row
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(iface).classes("text-h6")
            ui.label(f"{hwaddr}").classes("text-h6")
            ui.switch("Connected").props("disable")

        ui.separator()
        


        with ui.row().classes("w-full gap-4"):
            with ui.column().classes("w-32 items-start"):  # Fixed width for labels
               ui.label("Status").classes("font-bold")
               ui.label("Carrier").classes("font-bold")
               ui.label("General").classes("font-bold")
               ui.label("IPv4").classes("font-bold")
               ui.label("IPv6").classes("font-bold")
               ui.label("MTU").classes("font-bold")
    
            with ui.column().classes("flex-1 gap-4"):  # Flexible width for values
                ui.label(addresses)

                ui.label(f"{speed/1000} Gbps")

                ui.label(f"{carrier}")
               
                ui.checkbox('Connect automatically').props("flat color=accent align=left").classes("w-full").props("dense")

                #with ui.row():
                #    ui.label(ip4addressString), ui.link("edit")
#
                #with ui.row():
                #    ui.label(ip4addressString), ui.link("edit")
                #
                #with ui.row():
                #    ui.label(ip6addressString), ui.link("edit")

