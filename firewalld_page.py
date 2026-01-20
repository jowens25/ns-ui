from nicegui import ui, app, binding
from networking_lib import *
from firewalld_lib import *
from firewalld_client import *
from dbus_next.signature import Variant
from dbus_next.errors import DBusError
from dbus_next.aio.proxy_object import ProxyInterface
from dbus import dbus





@ui.refreshable
async def firewall_status(on_network_page: bool):

    firewall = Firewall()
    fire = await GetFirewall(dbus.Bus)
    firewall.Enable = await fire.call_is_active()
    firewall.Status = "Enabled" if firewall.Enable else "Disabled"
    
    if firewall.Enable:
        zone = await GetFirewalldZone(dbus.Bus)
        firewall.ActiveZones = await zone.call_get_active_zones()
        
    with ui.row().classes("w-full items-center justify-between"):
        with ui.row().classes( "items-center"):
            ui.label("Firewall").classes("text-h6")

            async def fire_switch_cb(e):
                action = "enable" if  e.sender.value else "disable"
                with ui.dialog() as dialog, ui.card():
                    ui.label(f'Are you sure you want to {action} firewalld?')
                    with ui.row():
                        ui.button('Cancel', on_click=lambda: dialog.submit("Cancel")).props("flat color=accent align=left")
                        ui.button(f'{action}', on_click=lambda: dialog.submit(action)).props("flat color=accent align=left")
                result = await dialog
                active = await fire.call_is_active()
                if result == "enable" and not active:
                    await fire.call_start()
                if result == "disable" and active:
                    await fire.call_stop()

                await firewall_status.refresh()
            ui.switch(firewall.Status).on('click', lambda e: fire_switch_cb(e)
                ).props("flat color=accent align=left dense").bind_value(firewall, "Enable").bind_text
        
        if on_network_page:
            ui.button("Edit rules and zones", on_click=lambda e: ui.navigate.to('/networking/firewall')).props("flat color=accent align=left")
            #ui.link( '/networking/firewall').bind_text_from(firewall, "ActiveZones")

        else:
            ui.button("add new zone").props("color=accent align=left")

            #with ui.row().classes("w-full items-center justify-between"): 
            #zone_text = f'{len(firewall.ActiveZones)} active zones' if len(firewall.ActiveZones) != 1 else f'{len(firewall.ActiveZones)} active zone'
    



def formatInterfacesString(interfaces):
    interfaces = interfaces.split(",")
    return formatListToString(interfaces)
    
def formatSourcesString(sources):
    sources = sources.split(",")
    return formatListToString(sources)
    
    
    
def InterfaceText(zone):
    interfaces = zone.get('interfaces')
    
    if interfaces == None:
        return

    elif len(interfaces) == 1:
        l1 = ui.label("Interface:").classes("font-bold")
    else:
        l1= ui.label("Interfaces:").classes("font-bold")
    l2 = ui.label().bind_text_from(zone, "interfaces", backward=lambda i: formatInterfacesString(i))
    return (l1, l2)

def AllowedAddressText(zone):
    sources = zone.get('sources')
    print(sources)
    l1 = ui.label("Allowed Addresses:").classes("font-bold")

    if sources == None:
        l2 = ui.label("Entire subnet")
    else:
        l2 = ui.label().bind_text_from(zone, "sources", backward=lambda i: formatSourcesString(i))
        
    return (l1, l2)

# TODO get services with zone getServices
# TODO get service props with getServiceSettings2
def getUdpPorts(ports) -> list:
    out = []
    for p in ports:
        if p[1]=='udp':
            out.append(p[0])
    return out
    
def formatServicesInRows(services :Service):
    rows = []
    for s in services:
                    
        rows.append({"Service": s.Name})
                     #"UDP": getUdpPorts(s.Ports)})
    
    return rows

@ui.refreshable
async def firewall_table():
    
    firewall = Firewall()
    fire = await GetFirewall(dbus.Bus)
    firewall.Enable = await fire.call_is_active()
    firewall.Status = "Enabled" if firewall.Enable else "Disabled"
    
    if firewall.Enable:
        fire = await GetFirewalld(dbus.Bus)
        zone = await GetFirewalldZone(dbus.Bus)
        firewall.ActiveZonesNames = await zone.call_get_active_zones()
        
        for az in firewall.ActiveZonesNames:
            z = Zone(az)
            #print(az)
            services = await zone.call_get_services(az)
            for s in services:
                service = Service()
                service_settings = await fire.call_get_service_settings2(s)
                
                includes = service_settings.get('includes', False)
                if includes:
                    for i in includes.value:
                        ser = Service()
                        ser_set = await fire.call_get_service_settings2(i)
                        #ser.Name = ser_set.get('short', Variant('s', 'name not available')).value
                        service.Ports.extend(ser_set.get('ports', Variant('a(ss)', [['port not available', 'protocol not available']])).value)
                        #ser.Description = ser_set.get('description', Variant('s', 'Description not available')).value
                        #z.Services.append(ser)
                        
                #pprint(service_settings)
            
                service.Name = service_settings.get('short', Variant('s', 'name not available')).value
                service.Ports.extend(service_settings.get('ports', Variant('a(ss)', [['port not available', 'protocol not available']])).value)
                service.Description = service_settings.get('description', Variant('s', 'Description not available')).value
                z.Services.append(service)
                #pprint(service_settings)
                
            firewall.Zones.append(z)
    
    pprint(firewall) 
    async def zone_list():
        with ui.column():
            for zone in parseActiveZones(firewall.ActiveZonesNames):
                with ui.card().classes("w-full"):
                    with ui.column():
                        with ui.row().classes("w-full items-baseline justify-between"):

                            with ui.row().classes("items-baseline"):
                                ui.label().bind_text_from(zone, "zone", backward=lambda text: f'{text.capitalize()} zone').classes('text-h6')
                                InterfaceText(zone)

                            with ui.row():
                                AllowedAddressText(zone)

                            with ui.row():
                                ui.button("add services").props("color=accent align=left")
                                ui.button(icon="more_vert").props("flat color=accent align=left")
                            
                        services = formatServicesInRows(firewall.Zones[zone['zone']])
                        print(services)
                        service_table = ui.table(
                            #title="Interfaces",
                            rows=services,
                            #rows=[{'d':'v'}],
                            column_defaults={
                                "align": "left",
                                "headerClasses": "uppercase text-primary",
                            },
                        )

                        service_table.add_slot(
                            "body-cell-name",
                            """
                            <q-td :props="props">
                                <a :href="'/networking/' + props.row.name" 
                                   class="text-accent cursor-pointer hover:underline"
                                   >
                                    {{ props.value }}
                                </a>
                            </q-td>
                        """,
                        )
                        
                        service_table.add_slot(
                            "body-cell-addresses",
                            """
                            <q-td :props="props" class="font-bold text-sm">
                                {{ props.value }}
                            </q-td>
                        """,
                        )
                            
        
    await zone_list()


def daemon_cb(mystr):
    print(mystr)
    firewall_table.refresh()

async def firewall_page():
    
    
    fire = await GetFirewall(dbus.Bus)
    fire.on_daemon_changed(daemon_cb)

    with ui.card():
        with ui.row():
            ui.link("Networking", "/networking")
            ui.label(">")
            ui.label('firewall')
        await firewall_status(False)
        await firewall_table()