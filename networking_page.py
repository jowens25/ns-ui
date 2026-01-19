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
            # rows=[{'d':'v'}],
            column_defaults={
                "align": "left",
                "headerClasses": "uppercase text-primary",
            },
        )

        interface_table.add_slot(
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

        interface_table.add_slot(
            "body-cell-addresses",
            """
            <q-td :props="props" class="font-bold text-sm">
                {{ props.value }}
            </q-td>
        """,
        )


async def interface_page(interface_name: str):
    nm = GetNetworkManager(dbus.Bus)
    
    dev_path = await nm.call_get_device_by_ip_iface(interface_name)

    device = GetDevice(dbus.Bus, dev_path)
    
    interface = await GetInterfaceData(nm, interface_name)


    def state_changed_cb(u):
        status.refresh()
    nm.on_state_changed(state_changed_cb)
    
    #async def edit_and_refresh(version):
    #    await edit_ip_connection(version, device)
    #    status.refresh()
        
    
    @ui.refreshable
    async def header():
        #interface = await GetInterfaceData(nm, interface_name)

        with ui.row():
            ui.link("Networking", "/networking")
            ui.label(">")
            ui.label(interface.Name)
            
            with ui.row().classes("w-full items-center justify-between"):
                    ui.label().classes("text-h6").bind_text(interface, "Name")
                    ui.label().classes("text-h6").bind_text(interface, "HardwareAddress")

                    async def connection_sw_cb(e):
                        action = "enable" if e.sender.value else "disable"
                        with ui.dialog() as dialog, ui.card():
                            ui.label(f"Are you sure you want to {action} this connection?")
                            with ui.row():
                                ui.button(
                                    "Cancel", on_click=lambda: dialog.submit("Cancel")
                                ).props("flat color=accent align=left")
                                ui.button(
                                    f"{action}", on_click=lambda: dialog.submit(action)
                                ).props("flat color=accent align=left")
                        result = await dialog
                        if result == "enable":
                            await nm.call_activate_connection("/", interface._dev_path, "/")
                        elif result == "disable":
                            await nm.call_deactivate_connection(interface._act_con_path)
                        
                        #header.refresh()
                        return None
                    
                    ui.switch("Connected").on("click", lambda e: connection_sw_cb(e)).props(
                    "flat color=accent"
                ).bind_value(interface, "Active")
                    

    @ui.refreshable
    async def status():
        interface = await GetInterfaceData(nm, interface_name)

        with ui.column().classes("flex-1 gap-4"):
            with ui.row().classes("flex-1 gap-16"):
                ui.label("Status").classes("font-bold w-8")
                ui.label().bind_text_from(interface, "Status")
            with ui.row().classes("flex-1 gap-16"):
                ui.label("State").classes("font-bold w-8")
                ui.label().bind_text_from(interface, "StateString")
            with ui.row().classes("flex-1 gap-16"):
                ui.label("Carrier").classes("font-bold w-8")
                ui.label().bind_text_from(interface, "Carrier")
            with ui.row().classes("flex-1 gap-16"):
                ui.label("General").classes("font-bold w-8")
                async def auto_connect_cb(e):
                    return
                    device = GetDevice(dbus.Bus, interface._dev_path)
                    settings = await GetSettings(device)
                    settings["connection"]["autoconnect"] = Variant(
                        "b", e.value
                    )
                    # await connection.call_update2(settings, 0x1, {})
                    # await device.call_reapply(settings, 0, 0)
                ui.checkbox(
                    "Connect automatically", on_change=auto_connect_cb
                ).props("flat color=accent dense").bind_value(
                    interface, "AutoConnect"
                )
                
                
            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv4").classes("font-bold w-8")
                ui.label().bind_text_from(interface, "Ip4")
                ui.label("Edit").classes(
                    "text-accent cursor-pointer hover:underline"
                ).on("click", lambda: edit_and_refresh('ipv4'))
                
                
            with ui.row().classes("flex-1 gap-16"):
                ui.label("IPv6").classes("font-bold w-8")
                ui.label().bind_text_from(interface, "Ip6")
                ui.label("Edit").classes(
                    "text-accent cursor-pointer hover:underline"
                ).on("click", lambda: edit_and_refresh('ipv6'))
    

    with ui.card() as interface_card:
        await header()
        ui.separator()
        await status()        
        
    return interface_card
    
    #    
#
    #async def interface_card():
    #    
    #    interface = await GetInterfaceData(nm, interface_name)
#
    #    with ui.card().classes("w-full"):
    #        
#
    #            ui.separator()
#
    #            with ui.column().classes("flex-1 gap-4"):  # Fixed width for labels
    #                with ui.row().classes("flex-1 gap-16"):
    #                    ui.label("Status").classes("font-bold w-8")
    #                    ui.label().bind_text_from(interface, "Status")
    #                with ui.row().classes("flex-1 gap-16"):
    #                    ui.label("State").classes("font-bold w-8")
    #                    ui.label().bind_text_from(interface, "StateString")
    #                with ui.row().classes("flex-1 gap-16"):
    #                    ui.label("Carrier").classes("font-bold w-8")
    #                    ui.label().bind_text_from(interface, "Carrier")
    #                with ui.row().classes("flex-1 gap-16"):
    #                    ui.label("General").classes("font-bold w-8")
#
    #                    async def auto_connect_cb(e):
    #                        return
    #                        device = GetDevice(dbus.Bus, interface._dev_path)
    #                        settings = await GetSettings(device)
    #                        settings["connection"]["autoconnect"] = Variant(
    #                            "b", e.value
    #                        )
    #                        # await connection.call_update2(settings, 0x1, {})
    #                        # await device.call_reapply(settings, 0, 0)
#
    #                    ui.checkbox(
    #                        "Connect automatically", on_change=auto_connect_cb
    #                    ).props("flat color=accent dense").bind_value(
    #                        interface, "AutoConnect"
    #                    )
    #                    
    #                    
    #                with ui.row().classes("flex-1 gap-16"):
    #                    ui.label("IPv4").classes("font-bold w-8")
    #                    ui.label().bind_text_from(interface, "Ip4")
    #                    ui.label("Edit").classes(
    #                        "text-accent cursor-pointer hover:underline"
    #                    ).on("click", lambda: edit_and_refresh('ipv4'))
    #                    
    #                    
    #                with ui.row().classes("flex-1 gap-16"):
    #                    ui.label("IPv6").classes("font-bold w-8")
    #                    ui.label().bind_text_from(interface, "Ip6")
    #                    ui.label("Edit").classes(
    #                        "text-accent cursor-pointer hover:underline"
    #                    ).on("click", lambda: edit_and_refresh('ipv6'))
#
    #    return  # end of interface card
    #
    #
    #
    #
    #@ui.refreshable
    #async def header():
    #    with ui.row().classes("w-full items-center justify-between"):
    #            ui.label().classes("text-h6").bind_text(interface, "Name")
    #            ui.label().classes("text-h6").bind_text(interface, "HardwareAddress")
#
    #            async def connection_sw_cb(e):
    #                action = "enable" if e.sender.value else "disable"
    #                with ui.dialog() as dialog, ui.card():
    #                    ui.label(f"Are you sure you want to {action} this connection?")
    #                    with ui.row():
    #                        ui.button(
    #                            "Cancel", on_click=lambda: dialog.submit("Cancel")
    #                        ).props("flat color=accent align=left")
    #                        ui.button(
    #                            f"{action}", on_click=lambda: dialog.submit(action)
    #                        ).props("flat color=accent align=left")
    #                result = await dialog
    #                if result == "enable":
    #                    await nm.call_activate_connection("/", interface._dev_path, "/")
    #                elif result == "disable":
    #                    await nm.call_deactivate_connection(interface._act_con_path)
    #                
#
    #                #interface_card.refresh()
    #                #interface.Active = (await GetInterfaceData(nm, interface.Name)).Active
#
#
    #            ui.switch("Connected").on("click", lambda e: connection_sw_cb(e)).props(
    #                "flat color=accent"
    #            ).bind_value(interface, "Active")
    #
    #    
    #with ui.row():
    #    ui.link("Networking", "/networking")
    #    ui.label(">")
    #    ui.label(interface_name)
    #    
    #    with ui.column().classes("w-full"):
    #        await interface_card()
#



async def edit_ip_connection(version: str, device: ProxyInterface):

    settings = await GetSettings(device)

    ip = GetIp(version, settings)

    connection = await GetConnectionFromDevice(device)

    def add_ip_address(a: str = None, p: str = None, g: str = None):
        ip.AddressData.append(IpAddress(a, p))
        ip_address_list.refresh()

    def remove_ip_address(addr):
        ip.AddressData.remove(addr)
        ip_address_list.refresh()

    def add_dns_server(server: str = None):
        ip.DnsData.append(DnsServer(server))
        dns_server_list.refresh()

    def remove_dns_server(dns):
        ip.DnsData.remove(dns)
        dns_server_list.refresh()

    def add_dns_search(search: str = None):
        ip.DnsSearch.append(DnsServer(search))
        dns_search_list.refresh()

    def remove_dns_search(search):
        ip.DnsSearch.remove(search)
        dns_search_list.refresh()

    def add_route(
        Address: str = None, Prefix: str = None, NextHop: str = None, Metric: str = None
    ):
        ip.RouteData.append(IpRoute(Address, Prefix, NextHop, Metric))
        route_list.refresh()

    def remove_route(route):
        ip.RouteData.remove(route)
        route_list.refresh()

    @ui.refreshable
    async def ip_address_list():
        for addr in ip.AddressData:
            with ui.row():
                ui.input(label="Address").props("dense").classes("flex-1").bind_value(
                    addr, "Address"
                )
                ui.input(label="Prefix or netmask").props("dense").classes(
                    "flex-1"
                ).bind_value(addr, "Prefix")
                ui.input(label="Gateway").props("dense").classes("flex-1").bind_value(
                    ip, "Gateway"
                )
                ui.button(
                    icon="delete", on_click=lambda a=addr: remove_ip_address(a)
                ).props("flat color=accent").props("dense")

    @ui.refreshable
    async def dns_server_list():
        for dns in ip.DnsData:
            with ui.row():
                ui.input(label="Server").props("dense").classes("flex-1").bind_value(
                    dns, "Server"
                )
                ui.button(
                    icon="delete", on_click=lambda d=dns: remove_dns_server(d)
                ).props("flat color=accent").props("dense")

    @ui.refreshable
    async def dns_search_list():
        for search in ip.DnsSearch:
            with ui.row():
                ui.input(label="Server").props("dense").classes("flex-1").bind_value(
                    search, "Server"
                )
                ui.button(
                    icon="delete", on_click=lambda d=search: remove_dns_search(d)
                ).props("flat color=accent").props("dense")

    @ui.refreshable
    async def route_list():
        for route in ip.RouteData:
            with ui.row():
                ui.input(label="Server").props("dense").classes("flex-1").bind_value(
                    route, "Dest"
                )
                ui.input(label="Prefix or netmask").props("dense").classes(
                    "flex-1"
                ).bind_value(route, "Prefix")
                ui.input(label="Next Hop").props("dense").classes("flex-1").bind_value(
                    route, "NextHop"
                )
                ui.input(label="Metric").props("dense").classes("flex-1").bind_value(
                    route, "Metric"
                )

                ui.button(
                    icon="delete", on_click=lambda d=route: remove_route(d)
                ).props("flat color=accent").props("dense")

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
                            # SetIp4Method(settings, e.value)
                            return

                        ui.select(
                            options=["disabled", "auto", "manual"],
                            on_change=on_method_change,
                        ).props("dense").classes("w-24").bind_value(ip, "Method")

                        ip_address_button = ui.button(
                            icon="add", on_click=add_ip_address
                        ).props("flat color=accent dense")

                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await ip_address_list()
                    print()
                ###

                ### DNS SERVER
                ui.separator()
                with ui.row().classes("w-full justify-between"):
                    ui.label("DNS Servers")
                    with ui.row():

                        dns_server_switch = (
                            ui.switch("Automatic")
                            .props("flat color=accent dense")
                            .classes("w-24")
                            .bind_value(
                                ip,
                                "IgnoreAutoDns",
                                forward=lambda x: not x,
                                backward=lambda x: not x,
                            )
                        )
                        dns_server_button = ui.button(
                            icon="add",
                            on_click=add_dns_server,
                        ).props("flat color=accent dense")
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await dns_server_list()
                ###

                ### DNS SEARCH
                ui.separator()
                with ui.row().classes("w-full justify-between"):
                    ui.label("DNS Searches")
                    with ui.row():
                        dns_search_button = (
                            ui.button(
                                icon="add",
                                on_click=add_dns_search,
                            )
                            .props("flat color=accent")
                            .props("dense")
                        )
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await dns_search_list()
                ###

                ### ROUTES
                ui.separator()
                with ui.row().classes("w-full justify-between"):
                    ui.label("Routes")
                    with ui.row():
                        route_switch = (
                            ui.switch("Automatic")
                            .props("flat color=accent")
                            .props("dense")
                            .classes("w-24")
                            .bind_value(
                                ip,
                                "IgnoreAutoRoutes",
                                forward=lambda x: not x,
                                backward=lambda x: not x,
                            )
                        )
                        route_button = (
                            ui.button(icon="add", on_click=add_route)
                            .props("flat color=accent")
                            .props("dense")
                        )
                with ui.column().classes("items-center justify-between gap-4 w-full"):
                    await route_list()
                ###

                with ui.row().classes("items-center justify-between gap-4 w-full"):

                    async def on_save_cb():
                        try:

                            _settings = SetIp(ip, version, settings)

                            _settings = ApplyModes(version, _settings)

                            await connection.call_update2(_settings, 0x1, {})

                            await device.call_reapply(_settings, 0, 0)

                            dialog.close()

                        except DBusError as e:
                            ui.notify(e, type="negative")
                            # dialog.close()

                        except Exception as e:
                            print(e)
                            ui.notify("Please correct the errors", type="negative")

                    def on_cancel_cb():
                        dialog.close()

                    save_button = ui.button("save", on_click=on_save_cb).props(
                        "flat color=accent align=left"
                    )
                    cancel_button = ui.button("cancel", on_click=on_cancel_cb).props(
                        "flat color=accent align=left"
                    )
    await dialog
