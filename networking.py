from nicegui import ui, app
from theme import init_colors
from rest_api import APIClient
from dbus_next.aio import MessageBus
from dbus_next import BusType
from org_freedesktop_NetworkManager import NetworkManager
from org_freedesktop_NetworkManager_Device import Device

from org_freedesktop_NetworkManager import NetworkManager
from jeepney.wrappers import Properties
from jeepney.io.asyncio import Proxy

from dbus import dbus





async def GetAllDevices() -> str:
    nm_prox = Proxy(Properties(NetworkManager()), dbus.Router)
    device_paths = await nm_prox.get("AllDevices")
    return device_paths[0][1]

async def GetInterface(d :Device):
    device_proxy = Proxy(Properties(Device(d)), dbus.Router)
    interface = await device_proxy.get("Interface")
    return interface[0][1]


async def GetInterfaces():
    for d in await GetAllDevices():
        print(await GetInterface(d))


def update_dhcp_mode(dhcp_value):  # Receives the selected value
    print(f"Selected DHCP mode: {dhcp_value}")


def format_interfaces(result):
    table_rows = []
    for iface in result["interfaces"]:
        addresses_str = (
            ", ".join(iface.get("addresses", [])) if iface.get("addresses") else "None"
        )
        table_rows.append({"name": iface["name"], "addresses": addresses_str})
    return table_rows


async def get_interfaces_and_addresses() -> list:


    await GetInterfaces()


    proxy_object = Proxy(NetworkManager(), dbus.Router)
    device_paths = await proxy_object.GetDevices()
    for path in device_paths[0]:
        
        prop_prox = Proxy(Properties(Device(path)), dbus.Router)
    
        other_devices = await prop_prox.get("Ip4Config")
        print(other_devices)

    table_rows = []

    #devices = await nm.method("get_devices")
#
    #for path in devices:
    #    address_data = []
#
    #    interface_name = await nm.device.property(path, "Interface")
#
    #    ipv4_conf = await nm.device.property(path, "Ip4Config")
    #    ipv6_conf = await nm.device.property(path, "Ip6Config")
#
    #    print(ipv4_conf)
#
    #    ip4_address_data = await nm.ipv4config.property(ipv4_conf, "AddressData")
        #ip6_address_data = await nm.ipv6config.property(ipv6_conf, "AddressData")
#
        #print(ip4_address_data)
#
        #address_data.extend(ip4_address_data)
#
        #
        #address_data.extend(ip6_address_data)
        #
        #address_string = ", ".join(
        #    f"{item['address'].value}/{item['prefix'].value}" 
        #    for item in address_data
        #)
#
        #table_rows.append({"name": interface_name, "addresses": address_string})






        #nm.introspection = await nm.bus.introspect('org.freedesktop.NetworkManager', path)
        #nm.object = nm.bus.get_proxy_object('org.freedesktop.NetworkManager', path, nm.introspection)
        #nm.interface = nm.object.get_interface('org.freedesktop.NetworkManager.Device')
        #nm.properties_interface = nm.object.get_interface('org.freedesktop.DBus.Properties')
#
#

        #bytes = await nm.device.property(path, "Statistics")

        #bytes = await nm.properties_interface.call_get(        
        #        "org.freedesktop.NetworkManager.Device.Statistics",   
        #        "TxBytes")  
        


       # print("bytes", bytes.value)

    


    return table_rows





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
        interfaces = await get_interfaces_and_addresses()

        #res = await nm.getNetworkManger()
        #print(res)
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

    '''

    nm.introspection = await nm.bus.introspect('org.freedesktop.NetworkManager', "/org/freedesktop/NetworkManager")
    nm.object = nm.bus.get_proxy_object('org.freedesktop.NetworkManager', "/org/freedesktop/NetworkManager", nm.introspection)
    nm.interface = nm.object.get_interface('org.freedesktop.NetworkManager')
    device = await nm.interface.call_get_device_by_ip_iface(iface)





    nm.introspection = await nm.bus.introspect('org.freedesktop.NetworkManager', device)
    nm.object = nm.bus.get_proxy_object('org.freedesktop.NetworkManager', device, nm.introspection)
    #nm.interface = nm.object.get_interface('org.freedesktop.NetworkManager.Device')
    nm.properties_interface = nm.object.get_interface('org.freedesktop.DBus.Properties')


    hwaddr = await nm.properties_interface.call_get(        
            "org.freedesktop.NetworkManager.Device.Wired",   
            "HwAddress")  


    hwaddr = await nm.properties_interface.call_get(        
            "org.freedesktop.NetworkManager.Device.Wired",   
            "HwAddress")  
    
    carrier = await nm.properties_interface.call_get(        
            "org.freedesktop.NetworkManager.Device.Wired",   
            "Carrier")  
    print((carrier.value))
    speed = await nm.properties_interface.call_get(        
            "org.freedesktop.NetworkManager.Device.Wired",   
            "Speed")  
   
    print(speed)
    driver = await nm.properties_interface.call_get(        
            "org.freedesktop.NetworkManager.Device",   
            "Driver")  
    

    id = await nm.properties_interface.call_get(        
            "org.freedesktop.NetworkManager.Device",   
            "PhysicalPortId")  

    print(driver.value)

    print(id.value)


    


    address_data = []
    ipv4_conf = await nm.properties_interface.call_get(        
        "org.freedesktop.NetworkManager.Device",   
        "Ip4Config")    
    
    ipv6_conf = await nm.properties_interface.call_get(        
        "org.freedesktop.NetworkManager.Device",   
        "Ip6Config")   
    nm.introspection = await nm.bus.introspect('org.freedesktop.NetworkManager', ipv4_conf.value)
    nm.object = nm.bus.get_proxy_object('org.freedesktop.NetworkManager', ipv4_conf.value, nm.introspection)
    nm.interface = nm.object.get_interface('org.freedesktop.NetworkManager.IP4Config')
    nm.properties_interface = nm.object.get_interface('org.freedesktop.DBus.Properties')
    ip4_address_data = await nm.properties_interface.call_get(        
        "org.freedesktop.NetworkManager.IP4Config",   
        "AddressData")    
    
    address_data.extend(ip4_address_data.value)
    nm.introspection = await nm.bus.introspect('org.freedesktop.NetworkManager', ipv6_conf.value)
    nm.object = nm.bus.get_proxy_object('org.freedesktop.NetworkManager', ipv6_conf.value, nm.introspection)
    nm.interface = nm.object.get_interface('org.freedesktop.NetworkManager.IP6Config')
    nm.properties_interface = nm.object.get_interface('org.freedesktop.DBus.Properties')
    ip6_address_data = await nm.properties_interface.call_get(        
        "org.freedesktop.NetworkManager.IP6Config",   
        "AddressData")    
    
    address_data.extend(ip6_address_data.value)
    
    address_string = ", ".join(
        f"{item['address'].value}/{item['prefix'].value}" 
        for item in address_data
    )

    


    with ui.card().classes("w-full"):
        # Header row
        with ui.row().classes("w-full items-center justify-between"):
            ui.label(iface).classes("text-h6")
            ui.label(f"{driver.value}").classes("text-h6")
            ui.label(f"{hwaddr.value}").classes("text-h6")
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
                ui.label(address_string)

                ui.label(f"{speed.value/1000} Gbps")
               
                ui.checkbox('Connect automatically').props("flat color=accent align=left").classes("w-full").props("dense")

                with ui.row():
                    ui.label(address_string), ui.link("edit")

                with ui.row():
                    ui.label(address_string), ui.link("edit")
                
                with ui.row():
                    ui.label(address_string), ui.link("edit")
         '''