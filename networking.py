from nicegui import ui, app
from org_freedesktop_NetworkManager_IP6Config import IP6Config
from theme import init_colors
from rest_api import APIClient
from dbus_next.aio import MessageBus
from dbus_next import BusType
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Device import Device, DeviceProperties
from org_freedesktop_NetworkManager_IP4Config import IP4Config, IP4ConfigProperties
from org_freedesktop_NetworkManager import NetworkManager
from jeepney.wrappers import Properties
from jeepney.io.asyncio import Proxy

from dbus import dbus




async def GetDevices() -> list[str]:
    nm_prox = Proxy(NetworkManager(), dbus.Router)
    return (await nm_prox.GetDevices())[0]


async def GetInterface(device_path: str) -> str:
    device = Proxy(Device(device_path), dbus.Router)
    return (await device.get("Interface"))[0][1]

#async def GetIp4Config(device)


async def GetDeviceProperties(device_path :str) -> DeviceProperties:
    devicePropProx = Proxy(Properties(Device(device_path)), dbus.Router)
    data = (await devicePropProx.get_all())[0]

    deviceProps = DeviceProperties.from_dict(data)

    return deviceProps

async def GetIp4Config(config_path :str) -> IP4Config:
    configPropProx = Proxy(Properties(IP4Config(config_path)), dbus.Router)
    #data = (await devicePropProx.get_all())[0]

#async def GetInterfaceAndAddressData() -> list[str]:
#
#    row = []
#
#    nm = Proxy(NetworkManager(), dbus.Router)
#
#    for i in GetInterfaces():
#        device_path = (await nm.GetDeviceByIpIface(i))[0]
#        device_prox = Proxy(Properties(Device(device_path)), dbus.Router)
#
#        cfg_path = (await device_prox.get("Ip4Config"))[0][1]
#
#        if cfg_path != "/":
#
#            config_proxy = Proxy(Properties(IP4Config(cfg_path)), dbus.Router)
#
#            addressData = (await config_proxy.get("AddressData"))[0][1]
#
#            
#
#        row.append({"name": i, "address": f"{addressData.get(address)}/{}"})


def formatAddress(addressData: dict)-> list[str]:
    addresses = []
    
    for address in addressData:
        addr = address.get("address")[1]
        prefix = address.get("prefix")[1]
        addresses.append(f"{addr}/{prefix}")
    return addresses

def formatInterfaceRow(interface, addresses: list[str]):
    return {"name": interface, "addresses": formatAddressString(addresses)}


def formatAddressString(addresses: list[str]) -> str:
    return ', '.join(addresses) if addresses else ' '

NM_DEVICE_INTERFACE_FLAG_NONE= 0 # an alias for numeric zero, no flags set. 
NM_DEVICE_INTERFACE_FLAG_UP= 0x1 # the interface is enabled from the administrative point of view. Corresponds to kernel IFF_UP. 
NM_DEVICE_INTERFACE_FLAG_LOWER_UP= 0x2 # the physical link is up. Corresponds to kernel IFF_LOWER_UP. 
NM_DEVICE_INTERFACE_FLAG_PROMISC= 0x4 # receive all packets. Corresponds to kernel IFF_PROMISC. Since: 1.32. 
NM_DEVICE_INTERFACE_FLAG_CARRIER= 0x10000 # the interface has carrier. In most cases this is equal to the value of @NM_DEVICE_INTERFACE_FLAG_LOWER_UP. However some devices have a non-standard carrier detection mechanism. 
NM_DEVICE_INTERFACE_FLAG_LLDP_CLIENT_ENABLED= 0x20000 # the flag to indicate device LLDP status. Since: 1.32.

def processInterfaceFlags(flags: int) -> str:
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


async def GetAddressString(ip4configPath, ip6configPath)-> str:
    addresses = []
    if len(ip4configPath) > 1:
        ip4config = Proxy(IP4Config(ip4configPath), dbus.Router)
        ip4addresses = formatAddress((await ip4config.get("AddressData"))[0][1])
        addresses.extend(ip4addresses)
    if len(ip6configPath) > 1:
        ip6config = Proxy(IP6Config(ip6configPath), dbus.Router)
        ip6addresses = formatAddress((await ip6config.get("AddressData"))[0][1])
        addresses.extend(ip6addresses)

    return formatAddressString(addresses)


async def GetInterfacesAndAddresses() -> list:

    rows = []

    for devicePath in await GetDevices():
    
        device = Proxy(Device(devicePath), dbus.Router)
        interface = (await device.get("Interface"))[0][1]
        ip4configPath = (await device.get("Ip4Config"))[0][1]
        ip6configPath = (await device.get("Ip6Config"))[0][1]


        addresses = await GetAddressString(ip4configPath, ip6configPath)

        rows.append(formatInterfaceRow(interface, addresses))

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


async def interface_page(interface_name: str):

    with ui.row():
        ui.link('Networking', '/networking')
        ui.label('>')
        ui.label(interface_name)

        await interface_card(interface_name)



async def interface_card(iface :str ):

    nm_prox = Proxy(NetworkManager(), dbus.Router)
    devicePath = (await nm_prox.GetDeviceByIpIface(iface))[0]
    device = Proxy(Device(devicePath), dbus.Router)

    ip4configPath = (await device.get("Ip4Config"))[0][1]
    ip6configPath = (await device.get("Ip6Config"))[0][1]

    hwaddr = (await device.get("HwAddress"))[0][1]

    carrier = processInterfaceFlags((await device.get("InterfaceFlags"))[0][1])
    

    speed = 16000

    driver = (await device.get("Driver"))[0][1]




    ip4addressString = await GetAddressString(ip4configPath, [])
    ip6addressString = await GetAddressString([], ip6configPath)



    with ui.card().classes("w-full"):
        # Header row
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(iface).classes("text-h6")
            ui.label(f"{driver}").classes("text-h6")
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
                ui.label(ip4addressString + ", "+ ip6addressString)

                ui.label(f"{speed/1000} Gbps")

                ui.label(f"{carrier}")
               
                ui.checkbox('Connect automatically').props("flat color=accent align=left").classes("w-full").props("dense")

                with ui.row():
                    ui.label(ip4addressString), ui.link("edit")

                with ui.row():
                    ui.label(ip4addressString), ui.link("edit")
                
                with ui.row():
                    ui.label(ip6addressString), ui.link("edit")

