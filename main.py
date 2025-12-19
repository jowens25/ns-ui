
from nicegui import ui, app
import time
from lib.date import get_date


from network_manager import nm

from networking import network_page, interface_page
from accounts import accounts_page
from theme import init_colors
from login import login_page
from root import root_page
from snmp import snmp_page, snmp_user_page
from ntp import ntp_page


from dbus_next.aio import MessageBus
from dbus_next import BusType
import asyncio

@ui.page('/networking')
@ui.page('/networking/{interface_name}')

@ui.page('/snmp')
@ui.page('/snmp/{user}')

@ui.page('/ntp')


@ui.page('/')
async def root():
    

    init_colors()
        
    if not app.storage.user.get("authenticated", False):
        
        ui.navigate.to("/login")
        return


    with ui.header().classes("items-center justify-between").classes("bg-dark"):
        ui.button(on_click=lambda: left_drawer.toggle(), icon="menu").props(
            "flat color=white"
        )
        ui.image("assets/NOVUS_LOGO.svg").classes("w-48")
        ui.label(f'Welcome {app.storage.user["username"]}!')

        label = ui.label()

        async def update_date():
            await get_date(label)

        ui.timer(1.0, update_date)







    with ui.left_drawer(bordered=True).classes("bg-dark") as left_drawer:


        ui.button(
            "Overview - root",
            on_click=lambda: ui.navigate.to('/'),
            icon="dashboard",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Networking",
            on_click=lambda: ui.navigate.to('/networking'),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")


        ui.button(
            "NTP",
            on_click=lambda: ui.navigate.to('/ntp'),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")


        ui.button(
            "Protocols",
            on_click=lambda: ui.navigate.to('/protocols'),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Access",
            on_click=lambda: ui.navigate.to('/access'),
            icon="settings_ethernet",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "SNMP",
            on_click=lambda: ui.navigate.to('/snmp'),
            icon="settings_applications",
        ).props("flat color=white align=left").classes("full-width")

        ui.button(
            "Accounts",
            on_click=lambda: ui.navigate.to('/accounts'),
            icon="group",
        ).props("flat color=white align=left").classes("full-width")

        ui.separator()

        ui.button(
            "Logout",
            on_click=lambda: (app.storage.user.clear(), ui.navigate.to("/login")),
            icon="logout",
        ).props("flat color=negative align=left").classes("full-width")

    # Footer
    with ui.footer().classes("bg-dark"):
        ui.label("FOOTER")


    ui.sub_pages({
                    '/': root_page, 
                  '/networking': network_page, 
                  '/networking/{interface_name}': interface_page,
                  '/ntp' : ntp_page,
                  '/snmp': snmp_page, 
                  '/snmp/{user}': snmp_user_page,
                  '/accounts': accounts_page, 
                  })





@app.on_startup
async def startup():
    bus = MessageBus(bus_type=BusType.SYSTEM)
    bus._loop = asyncio.get_running_loop()
    await nm.connect(bus)


@app.on_shutdown
async def shutdown():
    nm.disconnect()


if __name__ in {"__main__", "__mp_main__"}:

    ui.run(
        reload=True,
        storage_secret="your-secret-key",
        title="Novus Configuration Tool",
        favicon="assets/favicon.png",
    )


